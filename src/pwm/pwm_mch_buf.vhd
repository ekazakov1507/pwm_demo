library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

library work;
  use work.range_divider_pkg.get_chunk_end;
  use work.range_divider_pkg.value_flag_pair;

entity pwm_mch_buf is
  generic (
    r               : integer   := 7;
    d               : integer   := 2;
    num_channels    : integer   := 2;
    input_data_type : string    := "SIGNED";
    buffer_depth    : integer   := 1024;
    ref_type        : string    := "SYMMETRICAL";
    output_mode     : string    := "COMPLEMENTARY";
    ref_step        : integer   := 1;
    ref_updwn       : std_logic := '1';
    clk_freq_hz     : integer   := 100_000_000;
    clk_pwm_freq_hz : integer   := 200_000_000
  );
  port (
    clk        : in    std_logic;
    clk_pwm    : in    std_logic;
    rst        : in    std_logic;
    enable     : in    std_logic;
    input_wave : in    std_logic_vector(r - 1 downto 0);
    pwm        : out   std_logic_vector(num_channels - 1 downto 0);
    pwm_n      : out   std_logic_vector(num_channels - 1 downto 0)
  );
end entity pwm_mch_buf;

architecture src of pwm_mch_buf is

  function clamp_positive(value : integer) return positive is
  begin
    if value < 1 then
      return 1;
    else
      return value;
    end if;
  end function;

  function get_pwm_cycle_length return positive is
  begin
    if ref_type = "SYMMETRICAL" then
      return 2 ** (r + 1);
    else
      return 2 ** r;
    end if;
  end function;

  constant pwm_cycle_length : positive := get_pwm_cycle_length;

  -- Use real arithmetic for elaboration-time scaling so the product
  -- clk_freq_hz * pwm_cycle_length cannot overflow 32-bit integer.
  constant decimation_factor_real : real := (real(clk_freq_hz) * real(pwm_cycle_length)) / real(clk_pwm_freq_hz);

  constant decimation_factor_raw : integer := integer(round(decimation_factor_real));

  constant decimation_factor : positive := clamp_positive(integer(round(decimation_factor_real * 0.95)));

  signal buf_input  : std_logic_vector(r - 1 downto 0) := (others => '0');
  signal buf_output : std_logic_vector(r - 1 downto 0) := (others => '0');
  signal buf_rd_en  : std_logic                        := '0';
  signal buf_wr_en  : std_logic                        := '0';
  signal buf_full   : std_logic                        := '0';
  signal buf_empty  : std_logic                        := '0';

  signal dec_wave   : std_logic_vector(r - 1 downto 0) := (others => '0');
  signal valid_wave : std_logic                        := '0';

  signal duty_cycle : std_logic_vector(r - 1 downto 0) := (others => '0');

  signal rst_sync : std_logic_vector(2 downto 0) := "000";
  signal rst_pwm  : std_logic                    := '1';

  signal enable_sync : std_logic_vector(2 downto 0) := "000";
  signal enable_pwm  : std_logic                    := '0';
  signal buf_rd_valid : std_logic                   := '0';

begin

  assert num_channels > 0
    report "num_channels must be >= 1"
    severity failure;

  assert buffer_depth > 0
    report "buffer_depth must be >= 1"
    severity failure;

  assert decimation_factor_raw > 0
    report "decimation_factor must be >= 1. Check clock frequencies and resolution."
    severity failure;

  dec_sine : entity work.data_decimator
    generic map (
      data_width        => r,
      decimation_factor => decimation_factor
    )
    port map (
      clk       => clk,
      rst       => rst,
      data_in   => input_wave,
      data_out  => dec_wave,
      valid_out => valid_wave
    );

  input_buffer : entity work.async_fifo
    generic map (
      data_width => r,
      fifo_depth => buffer_depth
    )
    port map (
      wr_clk   => clk,
      wr_rst   => rst,
      wr_en    => buf_wr_en,
      full     => buf_full,
      data_in  => buf_input,
      rd_clk   => clk_pwm,
      rd_rst   => rst_pwm,
      rd_en    => buf_rd_en,
      empty    => buf_empty,
      data_out => buf_output
    );

  input_buffer_wr_ctrl : process (clk) is
  begin

    if rising_edge(clk) then
      if (rst = '1') then
        buf_wr_en <= '0';
        buf_input <= (others => '0');
      elsif ((buf_full = '0') and (valid_wave = '1')) then
        buf_wr_en <= '1';
        buf_input <= dec_wave;
      else
        buf_wr_en <= '0';
      end if;
    end if;

  end process input_buffer_wr_ctrl;

  rst_sync_proc : process (clk_pwm) is
  begin
    if rising_edge(clk_pwm) then
      rst_sync <= rst_sync(1 downto 0) & rst;
      rst_pwm  <= rst_sync(2);
    end if;
  end process rst_sync_proc;

  enable_sync_proc : process (clk_pwm) is
  begin
    if rising_edge(clk_pwm) then
      if (rst_pwm = '1') then
        enable_sync <= "000";
        enable_pwm  <= '0';
      else
        enable_sync <= enable_sync(1 downto 0) & enable;
        enable_pwm  <= enable_sync(2);
      end if;
    end if;
  end process enable_sync_proc;

  input_buffer_rd_ctrl : process (clk_pwm) is

    -- Count one full PWM frame before requesting next buffered sample.
    variable cnt : integer range 0 to pwm_cycle_length - 1 := 0;
  begin

    if rising_edge(clk_pwm) then
      if (rst_pwm = '1') then
        cnt          := 0;
        buf_rd_en    <= '0';
        buf_rd_valid <= '0';
      elsif (cnt = pwm_cycle_length - 1) then
        cnt          := 0;
        buf_rd_valid <= buf_rd_en;

        if (buf_empty = '0') then
          buf_rd_en <= '1';
        else
          buf_rd_en <= '0';
        end if;
      else
        buf_rd_en    <= '0';
        buf_rd_valid <= buf_rd_en;
        cnt          := cnt + 1;
      end if;
    end if;

  end process input_buffer_rd_ctrl;

  pwm_reg_ctrl : process (clk_pwm) is
  begin

    if rising_edge(clk_pwm) then
      if (rst_pwm = '1') then
        duty_cycle <= (others => '0');
      else
        if (buf_rd_valid = '1') then
          duty_cycle <= buf_output;
        end if;
      end if;
    end if;

  end process pwm_reg_ctrl;

  channels_gen : for i in 0 to NUM_CHANNELS - 1 generate

    constant chunk : value_flag_pair := get_chunk_end(
                                                      mode  => input_data_type,
                                                      r     => r,
                                                      index => i,
                                                      n     => num_channels);

  begin

    pwm_ich : entity work.pwm_1ch
      generic map (
        r               => r,
        input_width     => r,
        d               => d,
        ref_type        => ref_type,
        output_mode     => output_mode,
        fp23_binary_point => r - 1,
        ref_init        => chunk.val,
        ref_step        => ref_step,
        ref_updwn       => chunk.flag,
        input_data_type => input_data_type
      )
      port map (
        clk        => clk_pwm,
        rst        => rst_pwm,
        enable     => enable_pwm,
        input_wave => duty_cycle,
        pwm        => pwm(i),
        pwm_n      => pwm_n(i)
      );

  end generate channels_gen;

end architecture src;
