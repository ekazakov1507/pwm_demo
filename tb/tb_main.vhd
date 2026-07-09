library ieee;
  use ieee.std_logic_1164.all;

entity tb_main is
--  Port ( );
end entity tb_main;

architecture tb of tb_main is

  constant clk_period : time := 8 ns;

  constant num_channels                 : integer := 4;
  constant pwm_mode_switch_delay_cycles : natural := 16;
  constant button_debounce_cycles       : positive := 2;
  constant resolution_led_on_cycles     : positive := 2;
  constant resolution_led_off_cycles    : positive := 2;
  constant resolution_led_pause_cycles  : positive := 12;
  constant led_gap_timeout              : time := clk_period * 12;
  constant sine_wave_length             : positive := 32;
  constant sine_pulse_period_cycles      : positive := 8;
  constant sine_pulse_start_delay_cycles : natural  := 0;
  constant sine_pulse_duration_cycles    : positive := 8;
  constant sine_pulse_front_cycles       : natural  := 0;
  constant sine_pulse_fall_cycles        : natural  := 0;
  constant sine_buffer_prefill_pulses    : positive := 2;
  constant sine_buffer_resume_pulses     : positive := 1;
  constant sine_buffer_refill_batch_pulses : positive := 1;
  constant sine_buffer_min_safe_pulses   : natural  := 0;
  constant sine_buffer_margin_samples    : natural  := 4;
  constant reset_release_cycles         : positive := 5;
  constant pwm_zero                     : std_logic_vector(num_channels - 1 downto 0) := (others => '0');

  signal sys_clk      : std_logic := '0';
  signal sys_rst      : std_logic := '0';
  signal sys_pwm_mode : std_logic := '0';
  signal sys_led      : std_logic := '0';

  signal sys_pwm   : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal sys_pwm_n : std_logic_vector(num_channels - 1 downto 0) := (others => '0');

  signal test_phase           : integer range 0 to 6 := 0;
  signal saw_default_activity : boolean := false;
  signal saw_res7_activity    : boolean := false;
  signal saw_res8_activity    : boolean := false;
  signal saw_res4_activity    : boolean := false;
  signal saw_res5_activity    : boolean := false;
  signal saw_res6_activity    : boolean := false;

  signal ctrl_clk              : std_logic := '0';
  signal ctrl_mmcm_lock        : std_logic := '0';
  signal ctrl_rst_request      : std_logic := '0';
  signal ctrl_resolution_step  : std_logic := '0';
  signal ctrl_sine_rst         : std_logic := '1';
  signal ctrl_pwm_rst          : std_logic := '1';
  signal ctrl_resolution_sel   : std_logic_vector(2 downto 0) := "010";

begin

  main_pwm_demo : entity work.main
    generic map (
      num_channels                 => num_channels,
      pwm_mode_switch_delay_cycles => pwm_mode_switch_delay_cycles,
      button_debounce_cycles       => button_debounce_cycles,
      resolution_led_on_cycles     => resolution_led_on_cycles,
      resolution_led_off_cycles    => resolution_led_off_cycles,
      resolution_led_pause_cycles  => resolution_led_pause_cycles,
      sine_wave_length             => sine_wave_length,
      sine_pulse_period_cycles      => sine_pulse_period_cycles,
      sine_pulse_start_delay_cycles => sine_pulse_start_delay_cycles,
      sine_pulse_duration_cycles    => sine_pulse_duration_cycles,
      sine_pulse_front_cycles       => sine_pulse_front_cycles,
      sine_pulse_fall_cycles        => sine_pulse_fall_cycles,
      sine_buffer_prefill_pulses    => sine_buffer_prefill_pulses,
      sine_buffer_resume_pulses     => sine_buffer_resume_pulses,
      sine_buffer_refill_batch_pulses => sine_buffer_refill_batch_pulses,
      sine_buffer_min_safe_pulses   => sine_buffer_min_safe_pulses,
      sine_buffer_margin_samples    => sine_buffer_margin_samples,
      reset_release_cycles         => reset_release_cycles
    )
    port map (
      sys_clk      => sys_clk,
      sys_rst      => sys_rst,
      sys_pwm_mode => sys_pwm_mode,
      sys_led      => sys_led,
      sys_pwm      => sys_pwm,
      sys_pwm_n    => sys_pwm_n
    );

  reset_ctrl_check : entity work.main_reset_ctrl
    generic map (
      pwm_mode_switch_delay_cycles => pwm_mode_switch_delay_cycles,
      reset_release_cycles         => reset_release_cycles,
      button_debounce_cycles       => button_debounce_cycles,
      min_pwm_resolution_bits      => 4,
      max_pwm_resolution_bits      => 8,
      default_pwm_resolution_bits  => 6
    )
    port map (
      clk              => ctrl_clk,
      mmcm_clk_lock    => ctrl_mmcm_lock,
      rst_request      => ctrl_rst_request,
      resolution_step  => ctrl_resolution_step,
      sine_rst         => ctrl_sine_rst,
      pwm_rst          => ctrl_pwm_rst,
      resolution_sel   => ctrl_resolution_sel
    );

  sys_clk <= not sys_clk after clk_period / 2;
  ctrl_clk <= not ctrl_clk after clk_period / 2;

  stim_proc : process is

    procedure wait_for_led_pause is
    begin
      loop
        if (sys_led = '0') then
          wait until sys_led = '1' for led_gap_timeout;

          if (sys_led = '0') then
            exit;
          end if;
        else
          wait until sys_led = '0';
        end if;
      end loop;
    end procedure wait_for_led_pause;

    procedure expect_led_pattern (
      expected_blinks : natural
    ) is
      variable blink_count : natural := 0;
    begin
      wait_for_led_pause;
      wait until sys_led = '1';

      loop
        blink_count := blink_count + 1;
        wait until sys_led = '0';
        wait until sys_led = '1' for led_gap_timeout;

        if (sys_led = '0') then
          exit;
        end if;
      end loop;

      assert blink_count = expected_blinks
        report "main: expected sys_led to blink " &
               integer'image(integer(expected_blinks)) & " times, got " &
               integer'image(integer(blink_count))
        severity failure;
    end procedure expect_led_pattern;

    procedure press_resolution_button is
    begin
      sys_pwm_mode <= '1';
      wait for 2 us;
      sys_pwm_mode <= '0';
    end procedure press_resolution_button;

  begin

    wait for 1 us;

    sys_rst <= '1';
    test_phase <= 0;
    wait for 2 us;
    assert ((sys_pwm = pwm_zero) and (sys_pwm_n = pwm_zero))
      report "main: expected outputs blanked while sys_rst is asserted"
      severity failure;
    assert sys_led = '0'
      report "main: expected sys_led off while sys_rst is asserted"
      severity failure;

    sys_pwm_mode <= '0';
    sys_rst      <= '0';
    test_phase   <= 1;
    wait for 80 us;
    assert saw_default_activity
      report "main: expected buffered PWM activity in default 6-bit resolution"
      severity failure;
    expect_led_pattern(6);

    test_phase <= 0;
    press_resolution_button;
    wait for 1 us;
    assert ((sys_pwm = pwm_zero) and (sys_pwm_n = pwm_zero))
      report "main: expected blanking while switching from 6-bit to 7-bit resolution"
      severity failure;
    test_phase <= 2;
    wait for 80 us;
    assert saw_res7_activity
      report "main: expected buffered PWM activity after switching to 7-bit resolution"
      severity failure;
    expect_led_pattern(7);

    test_phase <= 0;
    press_resolution_button;
    wait for 1 us;
    assert ((sys_pwm = pwm_zero) and (sys_pwm_n = pwm_zero))
      report "main: expected blanking while switching from 7-bit to 8-bit resolution"
      severity failure;
    test_phase <= 3;
    wait for 100 us;
    assert saw_res8_activity
      report "main: expected buffered PWM activity after switching to 8-bit resolution"
      severity failure;
    expect_led_pattern(8);

    test_phase <= 0;
    press_resolution_button;
    wait for 1 us;
    assert ((sys_pwm = pwm_zero) and (sys_pwm_n = pwm_zero))
      report "main: expected blanking while wrapping from 8-bit to 4-bit resolution"
      severity failure;
    test_phase <= 4;
    wait for 80 us;
    assert saw_res4_activity
      report "main: expected buffered PWM activity after switching to 4-bit resolution"
      severity failure;
    expect_led_pattern(4);

    test_phase <= 0;
    press_resolution_button;
    wait for 1 us;
    assert ((sys_pwm = pwm_zero) and (sys_pwm_n = pwm_zero))
      report "main: expected blanking while switching from 4-bit to 5-bit resolution"
      severity failure;
    test_phase <= 5;
    wait for 80 us;
    assert saw_res5_activity
      report "main: expected buffered PWM activity after switching to 5-bit resolution"
      severity failure;
    expect_led_pattern(5);

    test_phase <= 0;
    press_resolution_button;
    wait for 1 us;
    assert ((sys_pwm = pwm_zero) and (sys_pwm_n = pwm_zero))
      report "main: expected blanking while switching from 5-bit to 6-bit resolution"
      severity failure;
    test_phase <= 6;
    wait for 80 us;
    assert saw_res6_activity
      report "main: expected buffered PWM activity after switching back to 6-bit resolution"
      severity failure;
    expect_led_pattern(6);

    sys_rst    <= '1';
    test_phase <= 0;
    wait for 500 ns;
    assert ((sys_pwm = pwm_zero) and (sys_pwm_n = pwm_zero))
      report "main: reset button must blank outputs"
      severity failure;
    assert sys_led = '0'
      report "main: reset button must blank sys_led"
      severity failure;

    sys_rst <= '0';
    expect_led_pattern(6);

    wait;

  end process stim_proc;

  reset_ctrl_stim_proc : process is

    procedure press_ctrl_step is
    begin
      ctrl_resolution_step <= '1';
      wait for clk_period * 8;
      assert ((ctrl_sine_rst = '1') and (ctrl_pwm_rst = '1'))
        report "main_reset_ctrl: resolution switch must reset sine generator and PWM"
        severity failure;
      ctrl_resolution_step <= '0';
      wait for clk_period * (pwm_mode_switch_delay_cycles + reset_release_cycles + 8);
    end procedure press_ctrl_step;

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
    assert ctrl_resolution_sel = "010"
      report "main_reset_ctrl: reset must select default 6-bit resolution"
      severity failure;

    press_ctrl_step;
    wait for 1 ns;
    assert ((ctrl_sine_rst = '0') and (ctrl_pwm_rst = '0'))
      report "main_reset_ctrl: resolution switch reset did not release"
      severity failure;
    assert ctrl_resolution_sel = "011"
      report "main_reset_ctrl: first step must select 7-bit resolution"
      severity failure;

    press_ctrl_step;
    wait for 1 ns;
    assert ctrl_resolution_sel = "100"
      report "main_reset_ctrl: second step must select 8-bit resolution"
      severity failure;

    press_ctrl_step;
    wait for 1 ns;
    assert ctrl_resolution_sel = "000"
      report "main_reset_ctrl: third step must wrap to 4-bit resolution"
      severity failure;

    press_ctrl_step;
    wait for 1 ns;
    assert ctrl_resolution_sel = "001"
      report "main_reset_ctrl: fourth step must select 5-bit resolution"
      severity failure;

    press_ctrl_step;
    wait for 1 ns;
    assert ctrl_resolution_sel = "010"
      report "main_reset_ctrl: fifth step must return to 6-bit resolution"
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
    assert ctrl_resolution_sel = "010"
      report "main_reset_ctrl: reset button must restore default 6-bit resolution"
      severity failure;

    wait;

  end process reset_ctrl_stim_proc;

  activity_monitor : process (sys_pwm, sys_pwm_n, test_phase) is
  begin

    if not ((sys_pwm = pwm_zero) and (sys_pwm_n = pwm_zero)) then
      if (test_phase = 1) then
        saw_default_activity <= true;
      elsif (test_phase = 2) then
        saw_res7_activity <= true;
      elsif (test_phase = 3) then
        saw_res8_activity <= true;
      elsif (test_phase = 4) then
        saw_res4_activity <= true;
      elsif (test_phase = 5) then
        saw_res5_activity <= true;
      elsif (test_phase = 6) then
        saw_res6_activity <= true;
      end if;
    end if;

  end process activity_monitor;

  complementary_monitor : process (sys_pwm, sys_pwm_n) is
  begin
    for i in 0 to num_channels - 1 loop
      assert not ((sys_pwm(i) = '1') and (sys_pwm_n(i) = '1'))
        report "main: pwm and pwm_n must not be high together"
        severity failure;
    end loop;
  end process complementary_monitor;

end architecture tb;
