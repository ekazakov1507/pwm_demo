library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.range_divider_pkg.get_chunk_end;
  use work.range_divider_pkg.value_flag_pair;

entity pwm_mch_buf is
  generic (
    r               : integer   := 7;             -- PWM resolution bits
    d               : integer   := 2;             -- Num dead-time cycles
    num_channels    : integer   := 2;
    input_data_type : string    := "SIGNED";      -- signed or unsigned
    buffer_depth    : integer   := 1024;
    ref_type        : string    := "SYMMETRICAL"; -- Symmetrical and Asymmetrical
    ref_step        : integer   := 1;
    ref_updwn       : std_logic := '1'
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

  constant decimation_factor : integer := 10;

  -- signal buf_in : std_logic_vector(R-1 downto 0) := (others => '0');
  signal buf_input  : std_logic_vector(r - 1 downto 0) := (others => '0');
  signal buf_output : std_logic_vector(r - 1 downto 0) := (others => '0');
  signal buf_rd_en  : std_logic                        := '0';
  signal buf_wr_en  : std_logic                        := '0';
  signal buf_full   : std_logic                        := '0';
  signal buf_empty  : std_logic                        := '0';
  -- signal buf_count ;

  signal dec_wave   : std_logic_vector(r - 1 downto 0) := (others => '0');
  signal valid_wave : std_logic                        := '0';

  signal duty_cycle_state : std_logic                        := '0';
  signal duty_cycle       : std_logic_vector(r - 1 downto 0) := (others => '0');

begin

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
      rd_rst   => rst,
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

  input_buffer_rd_ctrl : process (clk) is

    variable cnt : integer := 0;

  begin

    if rising_edge(clk) then
      cnt := cnt + 1;
      if (rst = '1') then
        cnt       := 0;
        buf_rd_en <= '0';
      elsif (cnt = 2 ** r - 1 and buf_empty = '0') then
        buf_rd_en <= '1';
        cnt       := 0;
      elsif (cnt /= 2 ** r - 1 or buf_empty = '1') then
        buf_rd_en <= '0';
      end if;
    -- cnt := cnt + 1;
    end if;

  end process input_buffer_rd_ctrl;

  pwm_reg_ctrl : process (clk) is
  begin

    if rising_edge(clk) then
      if (rst = '1') then
        duty_cycle_state <= '0';
        duty_cycle       <= (others => '0');
      else
        duty_cycle_state <= buf_rd_en;
        if (duty_cycle_state = '1') then
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

    component pwm_1ch is
      generic (
        r               : integer := r;
        d               : integer := d;
        ref_type        : string  := ref_type;
        input_data_type : string  := input_data_type;
        ref_init        : integer := chunk.val;
        ref_step        : integer := ref_step;
        ref_updwn       : std_logic := chunk.flag
      );
      port (
        clk        : in    std_logic;
        rst        : in    std_logic;
        enable     : in    std_logic;
        input_wave : in    std_logic_vector(r - 1 downto 0);
        pwm        : out   std_logic;
        pwm_n      : out   std_logic
      );
    end component pwm_1ch;

  begin

    -- pwm_mod : entity work.pwm_1ch
    pwm_ich : component pwm_1ch
      generic map (
        r               => r,
        d               => d,
        ref_type        => ref_type,
        ref_init        => chunk.val,
        ref_step        => ref_step,
        ref_updwn       => chunk.flag,
        input_data_type => input_data_type
      )
      port map (
        clk        => clk_pwm,
        rst        => rst,
        enable     => enable,
        input_wave => duty_cycle,
        pwm        => pwm(i),
        pwm_n      => pwm_n(i)
      );

  end generate channels_gen;

end architecture src;
