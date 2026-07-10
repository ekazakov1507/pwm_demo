library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

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
  constant scale_factor         : real    := 0.8;
  constant offset_factor        : real    := 0.1;

  signal clk     : std_logic                                 := '0';
  signal rst     : std_logic                                 := '0';
  signal enable  : std_logic                                 := '0';
  signal data_in : std_logic_vector(data_width - 1 downto 0) := (others => '0');

  signal p_comp   : std_logic := '0';
  signal p_n_comp : std_logic := '0';

  signal saw_pwm_hi   : boolean := false;
  signal saw_pwm_n_hi : boolean := false;
  signal saw_both_on  : boolean := false;

begin

  dut_sine : entity work.sine_gen_simple
    generic map (
      wave_length => 2048,
      bit_width   => data_width,
      data_type   => input_data_type
    )
    port map (
      clk         => clk,
      reset       => rst,
      output_data => data_in
    );

  pwm_comp : entity work.pwm_1ch
    generic map (
      r               => data_width,
      input_width     => data_width,
      d               => num_dead_time_cycles,
      ref_type        => ref_type,
      ref_init        => ref_init,
      ref_step        => ref_step,
      input_data_type => input_data_type,
      scale_factor    => scale_factor,
      offset_factor   => offset_factor,
      fp23_binary_point => data_width - 1
    )
    port map (
      clk        => clk,
      rst        => rst,
      enable     => enable,
      tick_ce    => '1',
      input_wave => data_in,
      pwm        => p_comp,
      pwm_n      => p_n_comp
    );

  clk <= not clk after clk_period / 2;

  stim_proc : process is
  begin

    rst    <= '1';
    wait for clk_period * 2;
    rst    <= '0';
    wait for clk_period;
    enable <= '1';
    wait for 100 us;

    assert saw_pwm_hi
      report "pwm_1ch: expected pwm activity"
      severity failure;
    assert saw_pwm_n_hi
      report "pwm_1ch: expected pwm_n activity"
      severity failure;
    assert not saw_both_on
      report "pwm_1ch: pwm and pwm_n must not be high together"
      severity failure;

    wait for clk_period;
    wait;

  end process stim_proc;

  complementary_monitor : process (clk) is
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        saw_pwm_hi   <= false;
        saw_pwm_n_hi <= false;
        saw_both_on  <= false;
      elsif (enable = '1') then
        if (p_comp = '1') then
          saw_pwm_hi <= true;
        end if;
        if (p_n_comp = '1') then
          saw_pwm_n_hi <= true;
        end if;
        if ((p_comp = '1') and (p_n_comp = '1')) then
          saw_both_on <= true;
        end if;
      end if;
    end if;
  end process complementary_monitor;

end architecture tb;
