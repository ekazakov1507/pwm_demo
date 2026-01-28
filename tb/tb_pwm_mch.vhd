library ieee;
  use ieee.std_logic_1164.all;

entity tb_pwm_mch is
--  Port ( );
end entity tb_pwm_mch;

architecture tb of tb_pwm_mch is

  constant clk_period           : time      := 10 ns;
  constant data_width           : integer   := 7;
  constant ref_init             : integer   := -2 ** data_width / 2;
  constant num_dead_time_cycles : integer   := 4;
  constant buffer_depth         : integer   := 128;
  constant num_channels         : integer   := 4;
  constant input_data_type      : string    := "SIGNED";
  constant ref_type             : string    := "SYMMETRICAL";
  constant ref_step             : integer   := 1;
  constant ref_updwn            : std_logic := '1';

  signal clk     : std_logic                                 := '0';
  signal clk_pwm : std_logic                                 := '0';
  signal rst     : std_logic                                 := '0';
  signal enable  : std_logic                                 := '0';
  signal data_in : std_logic_vector(data_width - 1 downto 0) := (others => '0');

  signal p   : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_n : std_logic_vector(num_channels - 1 downto 0) := (others => '0');

  signal p_buf   : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_n_buf : std_logic_vector(num_channels - 1 downto 0) := (others => '0');

begin

  dut_sine : entity work.sine_gen_simple
    generic map (
      wave_length => 1024,
      bit_width   => data_width,
      data_type   => input_data_type
    )
    port map (
      clk         => clk,
      reset       => rst,
      output_data => data_in
    );

  simple_pwm : entity work.pwm_mch
    generic map (
      r               => DATA_WIDTH,
      d               => NUM_DEAD_TIME_CYCLES,
      num_channels    => NUM_CHANNELS,
      input_data_type => INPUT_DATA_TYPE,
      ref_type        => REF_TYPE,
      ref_step        => REF_STEP,
      ref_updwn       => ref_updwn
    )
    port map (
      clk        => clk,
      rst        => rst,
      enable     => enable,
      input_wave => data_in,
      pwm        => p,
      pwm_n      => p_n
    );

  adv_pwm : entity work.pwm_mch_buf
    generic map (
      r               => DATA_WIDTH,
      d               => NUM_DEAD_TIME_CYCLES,
      num_channels    => NUM_CHANNELS,
      ref_type        => REF_TYPE,
      input_data_type => INPUT_DATA_TYPE,
      buffer_depth    => BUFFER_DEPTH,
      ref_step        => REF_STEP,
      ref_updwn       => ref_updwn
    )
    port map (
      clk        => clk,
      clk_pwm    => clk_pwm,
      rst        => rst,
      enable     => enable,
      input_wave => data_in,
      pwm        => p_buf,
      pwm_n      => p_n_buf
    );

  clk <= not clk after clk_period / 2;

  clk_pwm <= not clk_pwm after clk_period / 4; -- 2x for sym pwm

  stim_proc : process is
  begin

    rst    <= '1';
    wait for clk_period * 2;
    rst    <= '0';
    wait for clk_period;
    enable <= '1';
    wait for clk_period;
    wait;

  end process stim_proc;

end architecture tb;
