library ieee;
  use ieee.std_logic_1164.all;

entity tb_pwm_1ch is
--  Port ( );
end entity tb_pwm_1ch;

architecture tb of tb_pwm_1ch is

  constant clk_period           : time    := 10 ns;
  constant data_width           : integer := 7;
  constant num_dead_time_cycles : integer := 2;
  constant ref_type             : string  := "SYMMETRICAL";
  constant ref_init             : integer := -2 ** data_width / 2;
  constant ref_step             : integer := 1;
  constant input_data_type      : string  := "SIGNED";

  signal clk     : std_logic                                 := '0';
  signal rst     : std_logic                                 := '0';
  signal enable  : std_logic                                 := '0';
  signal data_in : std_logic_vector(data_width - 1 downto 0) := (others => '0');

  signal p   : std_logic := '0';
  signal p_n : std_logic := '0';

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

  pwm_mod : entity work.pwm_1ch
    generic map (
      r               => DATA_WIDTH,
      d               => NUM_DEAD_TIME_CYCLES,
      ref_type        => REF_TYPE,
      ref_init        => REF_INIT,
      ref_step        => REF_STEP,
      input_data_type => INPUT_DATA_TYPE
    )
    port map (
      clk        => clk,
      rst        => rst,
      enable     => enable,
      input_wave => data_in,
      pwm        => p,
      pwm_n      => p_n
    );

  clk <= not clk after clk_period / 2;

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
