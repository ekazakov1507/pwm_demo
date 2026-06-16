library ieee;
  use ieee.std_logic_1164.all;

entity tb_main is
--  Port ( );
end entity tb_main;

architecture tb of tb_main is

  constant clk_period : time := 8 ns;

  constant num_channels                 : integer := 4;
  constant pwm_mode_switch_delay_cycles : natural := 16;
  constant sine_ramp_length             : positive := 32;
  constant reset_release_cycles         : positive := 5;
  constant pwm_zero                     : std_logic_vector(num_channels - 1 downto 0) := (others => '0');

  signal sys_clk      : std_logic := '0';
  signal sys_rst      : std_logic := '0';
  signal sys_pwm_mode : std_logic := '0';

  signal sys_pwm   : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal sys_pwm_n : std_logic_vector(num_channels - 1 downto 0) := (others => '0');

  signal test_phase         : integer range 0 to 3 := 0;
  signal saw_mode0_activity : boolean := false;
  signal saw_mode1_activity : boolean := false;
  signal saw_switch_blank   : boolean := false;

  signal ctrl_clk              : std_logic := '0';
  signal ctrl_mmcm_lock        : std_logic := '0';
  signal ctrl_rst_request      : std_logic := '0';
  signal ctrl_pwm_mode_request : std_logic := '0';
  signal ctrl_sine_rst         : std_logic := '1';
  signal ctrl_pwm_rst          : std_logic := '1';
  signal ctrl_pwm_mode_sel     : std_logic := '0';

begin

  main_pwm_demo : entity work.main
    generic map (
      num_channels                 => num_channels,
      pwm_mode_switch_delay_cycles => pwm_mode_switch_delay_cycles,
      sine_ramp_length             => sine_ramp_length,
      reset_release_cycles         => reset_release_cycles
    )
    port map (
      sys_clk      => sys_clk,
      sys_rst      => sys_rst,
      sys_pwm_mode => sys_pwm_mode,
      sys_pwm      => sys_pwm,
      sys_pwm_n    => sys_pwm_n
    );

  reset_ctrl_check : entity work.main_reset_ctrl
    generic map (
      pwm_mode_switch_delay_cycles => pwm_mode_switch_delay_cycles,
      reset_release_cycles         => reset_release_cycles
    )
    port map (
      clk              => ctrl_clk,
      mmcm_clk_lock    => ctrl_mmcm_lock,
      rst_request      => ctrl_rst_request,
      pwm_mode_request => ctrl_pwm_mode_request,
      sine_rst         => ctrl_sine_rst,
      pwm_rst          => ctrl_pwm_rst,
      pwm_mode_sel     => ctrl_pwm_mode_sel
    );

  sys_clk <= not sys_clk after clk_period / 2;
  ctrl_clk <= not ctrl_clk after clk_period / 2;

  stim_proc : process is
  begin

    wait for 1 us;

    sys_rst <= '1';
    test_phase <= 0;
    wait for 2 us;
    assert ((sys_pwm = pwm_zero) and (sys_pwm_n = pwm_zero))
      report "main: expected outputs blanked while sys_rst is asserted"
      severity failure;

    sys_pwm_mode <= '0';
    sys_rst      <= '0';
    test_phase   <= 1;
    wait for 5 us;
    assert saw_mode0_activity
      report "main: expected direct pwm_mch activity in mode 0"
      severity failure;

    sys_pwm_mode <= '1';
    test_phase   <= 2;
    wait for 200 ns;
    assert ((sys_pwm = pwm_zero) and (sys_pwm_n = pwm_zero))
      report "main: expected outputs blanked during delayed runtime mode switch"
      severity failure;

    wait for 1 us;
    assert saw_switch_blank
      report "main: expected a blanking interval after runtime mode switch"
      severity failure;

    test_phase <= 3;
    wait for 5 us;
    assert saw_mode1_activity
      report "main: expected buffered pwm_mch_buf activity in mode 1"
      severity failure;

    sys_rst    <= '1';
    test_phase <= 0;
    wait for 500 ns;
    assert ((sys_pwm = pwm_zero) and (sys_pwm_n = pwm_zero))
      report "main: reset button must blank outputs"
      severity failure;

    sys_rst <= '0';

    wait;

  end process stim_proc;

  reset_ctrl_stim_proc : process is
    variable held_cycles : natural := 0;
  begin

    wait for clk_period * 4;
    assert ctrl_sine_rst = '1'
      report "main_reset_ctrl: MMCM unlock must reset sine generator"
      severity failure;
    assert ctrl_pwm_rst = '1'
      report "main_reset_ctrl: MMCM unlock must reset PWM"
      severity failure;

    ctrl_mmcm_lock <= '1';
    held_cycles := 0;

    while (ctrl_sine_rst = '1' or ctrl_pwm_rst = '1') loop
      wait until rising_edge(ctrl_clk);
      wait for 1 ns;
      held_cycles := held_cycles + 1;
    end loop;

    assert held_cycles >= reset_release_cycles
      report "main_reset_ctrl: initial reset release was shorter than minimum"
      severity failure;

    ctrl_pwm_mode_request <= '1';
    wait until ctrl_pwm_rst = '1';
    wait for 1 ns;
    assert ctrl_sine_rst = '0'
      report "main_reset_ctrl: PWM mode switch must not reset sine generator"
      severity failure;

    held_cycles := 0;

    while (ctrl_pwm_rst = '1') loop
      wait until rising_edge(ctrl_clk);
      wait for 1 ns;
      held_cycles := held_cycles + 1;
      assert ctrl_sine_rst = '0'
        report "main_reset_ctrl: sine reset asserted during PWM mode switch blanking"
        severity failure;
    end loop;

    assert held_cycles >= reset_release_cycles
      report "main_reset_ctrl: PWM mode switch blanking was shorter than minimum"
      severity failure;
    assert ctrl_sine_rst = '0'
      report "main_reset_ctrl: sine reset must stay inactive after PWM mode switch"
      severity failure;
    assert ctrl_pwm_mode_sel = '1'
      report "main_reset_ctrl: PWM mode switch must commit selected mode"
      severity failure;

    ctrl_rst_request <= '1';
    wait until (ctrl_sine_rst = '1' and ctrl_pwm_rst = '1');
    wait for 1 ns;
    assert ctrl_sine_rst = '1'
      report "main_reset_ctrl: reset button must restart sine generator"
      severity failure;
    assert ctrl_pwm_rst = '1'
      report "main_reset_ctrl: reset button must reset PWM"
      severity failure;

    ctrl_rst_request <= '0';
    held_cycles := 0;

    while (ctrl_sine_rst = '1' or ctrl_pwm_rst = '1') loop
      wait until rising_edge(ctrl_clk);
      wait for 1 ns;
      held_cycles := held_cycles + 1;
    end loop;

    assert held_cycles >= reset_release_cycles
      report "main_reset_ctrl: reset button release was shorter than minimum"
      severity failure;

    wait;

  end process reset_ctrl_stim_proc;

  activity_monitor : process (sys_pwm, sys_pwm_n, test_phase) is
  begin

    if ((sys_pwm = pwm_zero) and (sys_pwm_n = pwm_zero)) then
      if (test_phase = 2) then
        saw_switch_blank <= true;
      end if;
    else
      if (test_phase = 1) then
        saw_mode0_activity <= true;
      elsif (test_phase = 3) then
        saw_mode1_activity <= true;
      end if;
    end if;

  end process activity_monitor;

end architecture tb;

