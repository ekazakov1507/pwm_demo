library ieee;
  use ieee.std_logic_1164.all;

entity tb_main is
--  Port ( );
end entity tb_main;

architecture tb of tb_main is

  constant clk_period : time := 10 ns;

  constant num_channels                 : integer := 4;
  constant pwm_resolution_bits          : positive := 8;
  constant pwm_mode_switch_delay_cycles : natural := 16;
  constant button_debounce_cycles       : positive := 2;
  constant resolution_led_on_cycles     : positive := 2;
  constant resolution_led_off_cycles    : positive := 2;
  constant resolution_led_pause_cycles  : positive := 12;
  constant led_gap_timeout              : time := clk_period * 12;
  constant sine_wave_length             : positive := 32;
  constant sine_pulse_period_cycles      : positive := 4;
  constant sine_pulse_start_delay_cycles : natural  := 0;
  constant sine_pulse_duration_cycles    : positive := 4;
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

  signal test_phase        : integer range 0 to 5 := 0;
  signal saw_div2_activity : boolean := false;
  signal saw_div4_activity : boolean := false;
  signal saw_div8_activity : boolean := false;
  signal saw_div16_activity : boolean := false;
  signal saw_div2_wrap_activity : boolean := false;

  signal ctrl_clk              : std_logic := '0';
  signal ctrl_mmcm_lock        : std_logic := '0';
  signal ctrl_rst_request      : std_logic := '0';
  signal ctrl_divider_step     : std_logic := '0';
  signal ctrl_sine_rst         : std_logic := '1';
  signal ctrl_pwm_rst          : std_logic := '1';
  signal ctrl_pwm_div_sel      : std_logic_vector(1 downto 0) := "00";

  signal scaler_rst     : std_logic := '1';
  signal scaler_div_sel : std_logic_vector(1 downto 0) := "00";
  signal scaler_tick_ce : std_logic := '0';

begin

  main_pwm_demo : entity work.main
    generic map (
      num_channels                 => num_channels,
      pwm_resolution_bits          => pwm_resolution_bits,
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
      pwm_divider_mode_count       => 4,
      default_pwm_divider_index    => 0
    )
    port map (
      clk              => ctrl_clk,
      mmcm_clk_lock    => ctrl_mmcm_lock,
      rst_request      => ctrl_rst_request,
      pwm_divider_step => ctrl_divider_step,
      sine_rst         => ctrl_sine_rst,
      pwm_rst          => ctrl_pwm_rst,
      pwm_div_sel      => ctrl_pwm_div_sel
    );

  post_scaler_check : entity work.pwm_clk_post_scaler
    port map (
      clk     => ctrl_clk,
      rst     => scaler_rst,
      div_sel => scaler_div_sel,
      tick_ce => scaler_tick_ce
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

    procedure press_frequency_button is
    begin
      sys_pwm_mode <= '1';
      wait for 2 us;
      sys_pwm_mode <= '0';
    end procedure press_frequency_button;

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
    wait for 140 us;
    assert saw_div2_activity
      report "main: expected buffered PWM activity in default /2 divider mode"
      severity failure;
    expect_led_pattern(1);

    test_phase <= 0;
    press_frequency_button;
    wait for 1 us;
    assert ((sys_pwm = pwm_zero) and (sys_pwm_n = pwm_zero))
      report "main: expected blanking while switching from /2 to /4"
      severity failure;
    test_phase <= 2;
    wait for 140 us;
    assert saw_div4_activity
      report "main: expected buffered PWM activity after switching to /4"
      severity failure;
    expect_led_pattern(2);

    test_phase <= 0;
    press_frequency_button;
    wait for 1 us;
    assert ((sys_pwm = pwm_zero) and (sys_pwm_n = pwm_zero))
      report "main: expected blanking while switching from /4 to /8"
      severity failure;
    test_phase <= 3;
    wait for 160 us;
    assert saw_div8_activity
      report "main: expected buffered PWM activity after switching to /8"
      severity failure;
    expect_led_pattern(3);

    test_phase <= 0;
    press_frequency_button;
    wait for 1 us;
    assert ((sys_pwm = pwm_zero) and (sys_pwm_n = pwm_zero))
      report "main: expected blanking while switching from /8 to /16"
      severity failure;
    test_phase <= 4;
    wait for 180 us;
    assert saw_div16_activity
      report "main: expected buffered PWM activity after switching to /16"
      severity failure;
    expect_led_pattern(4);

    test_phase <= 0;
    press_frequency_button;
    wait for 1 us;
    assert ((sys_pwm = pwm_zero) and (sys_pwm_n = pwm_zero))
      report "main: expected blanking while wrapping from /16 to /2"
      severity failure;
    test_phase <= 5;
    wait for 140 us;
    assert saw_div2_wrap_activity
      report "main: expected buffered PWM activity after wrapping to /2"
      severity failure;
    expect_led_pattern(1);

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
    expect_led_pattern(1);

    wait;

  end process stim_proc;

  reset_ctrl_stim_proc : process is

    procedure press_ctrl_step is
    begin
      ctrl_divider_step <= '1';
      wait for clk_period * 8;
      assert ((ctrl_sine_rst = '1') and (ctrl_pwm_rst = '1'))
        report "main_reset_ctrl: divider switch must reset sine generator and PWM"
        severity failure;
      ctrl_divider_step <= '0';
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
    assert ctrl_pwm_div_sel = "00"
      report "main_reset_ctrl: reset must select default /2 divider"
      severity failure;

    press_ctrl_step;
    wait for 1 ns;
    assert ((ctrl_sine_rst = '0') and (ctrl_pwm_rst = '0'))
      report "main_reset_ctrl: divider switch reset did not release"
      severity failure;
    assert ctrl_pwm_div_sel = "01"
      report "main_reset_ctrl: first step must select /4"
      severity failure;

    press_ctrl_step;
    wait for 1 ns;
    assert ctrl_pwm_div_sel = "10"
      report "main_reset_ctrl: second step must select /8"
      severity failure;

    press_ctrl_step;
    wait for 1 ns;
    assert ctrl_pwm_div_sel = "11"
      report "main_reset_ctrl: third step must select /16"
      severity failure;

    press_ctrl_step;
    wait for 1 ns;
    assert ctrl_pwm_div_sel = "00"
      report "main_reset_ctrl: fourth step must wrap to /2"
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
    assert ctrl_pwm_div_sel = "00"
      report "main_reset_ctrl: reset button must restore default /2 divider"
      severity failure;

    wait;

  end process reset_ctrl_stim_proc;

  post_scaler_stim_proc : process is

    procedure expect_tick_spacing (
      selected_divider : std_logic_vector(1 downto 0);
      expected_cycles  : natural
    ) is
      variable cycle_count : natural := 0;
    begin
      scaler_div_sel <= selected_divider;
      scaler_rst <= '1';
      wait for clk_period * 3;
      wait until rising_edge(ctrl_clk);
      scaler_rst <= '0';

      loop
        wait until rising_edge(ctrl_clk);
        exit when scaler_tick_ce = '1';
      end loop;

      for i in 1 to 3 loop
        cycle_count := 0;

        loop
          wait until rising_edge(ctrl_clk);
          cycle_count := cycle_count + 1;
          exit when scaler_tick_ce = '1';
        end loop;

        assert cycle_count = expected_cycles
          report "pwm_clk_post_scaler: tick spacing was " &
                 integer'image(cycle_count) & " cycles, expected " &
                 integer'image(expected_cycles)
          severity failure;
      end loop;
    end procedure expect_tick_spacing;

  begin

    expect_tick_spacing("00", 2);
    expect_tick_spacing("01", 4);
    expect_tick_spacing("10", 8);
    expect_tick_spacing("11", 16);

    wait;

  end process post_scaler_stim_proc;

  activity_monitor : process (sys_pwm, sys_pwm_n, test_phase) is
  begin

    if not ((sys_pwm = pwm_zero) and (sys_pwm_n = pwm_zero)) then
      if (test_phase = 1) then
        saw_div2_activity <= true;
      elsif (test_phase = 2) then
        saw_div4_activity <= true;
      elsif (test_phase = 3) then
        saw_div8_activity <= true;
      elsif (test_phase = 4) then
        saw_div16_activity <= true;
      elsif (test_phase = 5) then
        saw_div2_wrap_activity <= true;
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
