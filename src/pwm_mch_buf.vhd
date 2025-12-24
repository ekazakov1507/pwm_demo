library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity pwm_mch_buf is
  generic (
    r               : integer := 7;             -- PWM resolution bits
    d               : integer := 2;             -- Num dead-time cycles
    num_channels    : integer := 2;
    ref_type        : string  := "SYMMETRICAL"; -- Symmetrical and Asymmetrical
    input_data_type : string  := "SIGNED";      -- signed or unsigned
    buffer_depth    : integer := 1024;
    ref_init        : integer := 0;             -- TO DO integer_vector
    ref_step        : integer := 1
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

  -- signal buf_in : std_logic_vector(R-1 downto 0) := (others => '0');
  signal buf_input  : std_logic_vector(r - 1 downto 0) := (others => '0');
  signal buf_output : std_logic_vector(r - 1 downto 0) := (others => '0');
  signal buf_rd_en  : std_logic                        := '0';
  signal buf_wr_en  : std_logic                        := '0';
  signal buf_full   : std_logic                        := '0';
  signal buf_empty  : std_logic                        := '0';
  -- signal buf_count ;

  signal duty_cycle_state : std_logic                        := '0';
  signal duty_cycle       : std_logic_vector(r - 1 downto 0) := (others => '0');

  signal cnt_out_test : std_logic_vector(r - 1 downto 0) := (others => '0');

begin

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

  input_buffer_wr_ctrl : process (clk, rst, buf_wr_en, input_wave) is

    variable prebuf_reg : std_logic_vector(r - 1 downto 0) := (others => '0');

  begin

    if rising_edge(clk) then
      if (rst = '1') then
        buf_wr_en  <= '0';
        prebuf_reg := (others => '0');
      elsif (rst = '0' and buf_full = '0') then
        if (prebuf_reg /= input_wave) then
          prebuf_reg := input_wave;
          buf_wr_en  <= '1';
        else
          buf_wr_en <= '0';
        end if;
      elsif (buf_full = '1') then
        buf_wr_en <= '0';
      end if;
    end if;

    buf_input <= prebuf_reg;

  end process input_buffer_wr_ctrl;

  input_buffer_rd_ctrl : process (clk, rst, buf_rd_en, buf_empty) is

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

  pwm_reg_ctrl : process (clk, rst, duty_cycle, duty_cycle_state, buf_output, buf_rd_en) is
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

    pwm2 : entity work.pwm_1ch
      generic map (
        r               => r,
        d               => d,
        ref_type        => ref_type,
        ref_init        => ref_init,
        ref_step        => ref_step,
        input_data_type => input_data_type
      )
      port map (
        clk    => clk_pwm,
        rst    => rst,
        enable => enable,
        -- input_wave => buf_out,
        input_wave   => duty_cycle,
        cnt_out_test => cnt_out_test,
        pwm          => pwm(i),
        pwm_n        => pwm_n(i)
      );

  end generate channels_gen;

end architecture src;
