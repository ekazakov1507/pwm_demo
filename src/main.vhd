library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity main_reset_ctrl is
  generic (
    pwm_mode_switch_delay_cycles : natural  := 25_000_000;
    reset_release_cycles         : positive := 5;
    button_debounce_cycles       : positive := 1_000_000;
    pwm_divider_mode_count       : positive := 4;
    default_pwm_divider_index    : natural  := 0
  );
  port (
    clk              : in    std_logic;
    mmcm_clk_lock    : in    std_logic;
    rst_request      : in    std_logic;
    pwm_divider_step : in    std_logic;
    sine_rst         : out   std_logic;
    pwm_rst          : out   std_logic;
    pwm_div_sel      : out   std_logic_vector(1 downto 0)
  );
end entity main_reset_ctrl;

architecture src of main_reset_ctrl is

  signal mmcm_lock_sync       : std_logic_vector(1 downto 0) := "00";
  signal sys_rst_sync         : std_logic_vector(1 downto 0) := "11";
  signal step_sync            : std_logic_vector(2 downto 0) := "000";
  signal step_stable          : std_logic := '0';
  signal step_debounce_count  : natural range 0 to button_debounce_cycles := 0;

  signal sine_reset_count     : natural range 0 to reset_release_cycles := reset_release_cycles;
  signal pwm_reset_count      : natural range 0 to reset_release_cycles := reset_release_cycles;
  signal pwm_div_sel_reg      : natural range 0 to pwm_divider_mode_count - 1 := default_pwm_divider_index;
  signal pending_pwm_div_sel  : natural range 0 to pwm_divider_mode_count - 1 := default_pwm_divider_index;
  signal divider_delay_active : std_logic := '0';
  signal divider_delay_count  : natural range 0 to pwm_mode_switch_delay_cycles := 0;

  function next_divider_index (
    current_index : natural
  ) return natural is
  begin
    if (current_index = pwm_divider_mode_count - 1) then
      return 0;
    end if;

    return current_index + 1;
  end function next_divider_index;

begin

  pwm_mode_switch_delay_valid : assert (pwm_mode_switch_delay_cycles > 0)
    report "main_reset_ctrl: pwm_mode_switch_delay_cycles must be greater than 0"
    severity failure;

  reset_release_cycles_valid : assert (reset_release_cycles >= 5)
    report "main_reset_ctrl: reset_release_cycles must be at least 5"
    severity failure;

  pwm_divider_mode_count_valid : assert ((pwm_divider_mode_count > 0) and
                                         (pwm_divider_mode_count <= 4))
    report "main_reset_ctrl: pwm divider selector supports 1 to 4 runtime modes"
    severity failure;

  default_pwm_divider_valid : assert (default_pwm_divider_index < pwm_divider_mode_count)
    report "main_reset_ctrl: default_pwm_divider_index must be inside the runtime range"
    severity failure;

  sine_rst    <= '1' when (sine_reset_count > 0) else '0';
  pwm_rst     <= '1' when (pwm_reset_count > 0) else '0';
  pwm_div_sel <= std_logic_vector(to_unsigned(pwm_div_sel_reg, pwm_div_sel'length));

  rst_gen : process (clk) is
    variable step_event : boolean;
    variable next_sel   : natural range 0 to pwm_divider_mode_count - 1;
  begin

    if rising_edge(clk) then
      step_event := false;
      mmcm_lock_sync <= mmcm_lock_sync(0) & mmcm_clk_lock;
      sys_rst_sync   <= sys_rst_sync(0) & rst_request;
      step_sync      <= step_sync(1 downto 0) & pwm_divider_step;

      if (step_sync(2) = step_stable) then
        step_debounce_count <= 0;
      elsif (step_debounce_count = button_debounce_cycles - 1) then
        if ((step_sync(2) = '1') and (step_stable = '0')) then
          step_event := true;
        end if;

        step_stable <= step_sync(2);
        step_debounce_count <= 0;
      else
        step_debounce_count <= step_debounce_count + 1;
      end if;

      if (sine_reset_count > 0) then
        sine_reset_count <= sine_reset_count - 1;
      end if;

      if (pwm_reset_count > 0) then
        pwm_reset_count <= pwm_reset_count - 1;
      end if;

      if ((mmcm_lock_sync(1) = '0') or
          (sys_rst_sync(1) = '1')) then
        sine_reset_count <= reset_release_cycles;
        pwm_reset_count <= reset_release_cycles;
        pwm_div_sel_reg <= default_pwm_divider_index;
        pending_pwm_div_sel <= default_pwm_divider_index;
        divider_delay_active <= '0';
        divider_delay_count <= 0;
        step_stable <= '0';
        step_debounce_count <= 0;
      elsif (divider_delay_active = '1') then
        sine_reset_count <= reset_release_cycles;
        pwm_reset_count <= reset_release_cycles;

        if (divider_delay_count = 0) then
          pwm_div_sel_reg <= pending_pwm_div_sel;
          divider_delay_active <= '0';
        else
          divider_delay_count <= divider_delay_count - 1;
        end if;
      elsif (step_event) then
        next_sel := next_divider_index(pwm_div_sel_reg);
        sine_reset_count <= reset_release_cycles;
        pwm_reset_count <= reset_release_cycles;
        pending_pwm_div_sel <= next_sel;
        divider_delay_active <= '1';
        divider_delay_count <= pwm_mode_switch_delay_cycles - 1;
      end if;
    end if;

  end process rst_gen;

end architecture src;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library unisim;
  use unisim.vcomponents.all;

entity main is
  generic (
    num_channels                 : integer := 4;
    debug                        : string  := "NO_DEBUG";
    pwm_resolution_bits          : positive := 8;
    pwm_mode_switch_delay_cycles : natural := 25_000_000;
    button_debounce_cycles       : positive := 1_000_000;
    resolution_led_on_cycles     : positive := 5_000_000;
    resolution_led_off_cycles    : positive := 5_000_000;
    resolution_led_pause_cycles  : positive := 25_000_000;
    sine_wave_length             : positive := 2048;
    sine_pulse_period_cycles      : positive := 4096;
    sine_pulse_start_delay_cycles : natural  := 1024;
    sine_pulse_duration_cycles    : positive := 2048;
    sine_pulse_front_cycles       : natural  := 256;
    sine_pulse_fall_cycles        : natural  := 256;
    sine_buffer_prefill_pulses    : positive := 2;
    sine_buffer_resume_pulses     : positive := 1;
    sine_buffer_refill_batch_pulses : positive := 1;
    sine_buffer_min_safe_pulses   : natural  := 0;
    sine_buffer_margin_samples    : natural  := 8;
    reset_release_cycles         : positive := 5
  );
  port (
    sys_clk      : in    std_logic;
    sys_rst      : in    std_logic;
    sys_pwm_mode : in    std_logic;
    sys_led      : out   std_logic;
    sys_pwm      : out   std_logic_vector(num_channels - 1 downto 0);
    sys_pwm_n    : out   std_logic_vector(num_channels - 1 downto 0)
  );
end entity main;

architecture src of main is

  constant source_data_width              : integer   := 16;
  constant num_dead_time_cycles           : integer   := 4;
  constant buffer_depth                   : integer   := 16384;
  constant wave_length                    : integer   := sine_wave_length;
  constant input_data_type                : string    := "SIGNED";
  constant ref_type                       : string    := "SYMMETRICAL";
  constant scale_factor                   : real      := 0.8;
  constant offset_factor                  : real      := 0.0;
  constant ref_step                       : integer   := 1;
  constant ref_updwn                      : std_logic := '1';
  constant clk_freq_hz                    : integer   := 50_000_000;
  constant clk_pwm_freq_hz                : integer   := 200_000_000;
  constant input_data_decimation_factor   : positive  := 2 ** pwm_resolution_bits;
  constant pwm_idle                       : std_logic_vector(num_channels - 1 downto 0) := (others => '0');

  constant pwm_div_sel_2  : std_logic_vector(1 downto 0) := "00";
  constant pwm_div_sel_4  : std_logic_vector(1 downto 0) := "01";
  constant pwm_div_sel_8  : std_logic_vector(1 downto 0) := "10";
  constant pwm_div_sel_16 : std_logic_vector(1 downto 0) := "11";
  constant pwm_divider_mode_count    : positive := 4;
  constant default_pwm_divider_index : natural := 0;

  function max_positive (
    left  : positive;
    right : positive
  ) return positive is
  begin
    if (left > right) then
      return left;
    end if;

    return right;
  end function max_positive;

  function divider_blink_count (
    value : std_logic_vector(1 downto 0)
  ) return natural is
  begin
    case value is
      when pwm_div_sel_2 =>
        return 1;
      when pwm_div_sel_4 =>
        return 2;
      when pwm_div_sel_8 =>
        return 3;
      when pwm_div_sel_16 =>
        return 4;
      when others =>
        return 0;
    end case;
  end function divider_blink_count;

  constant led_counter_limit : positive :=
    max_positive(max_positive(resolution_led_on_cycles, resolution_led_off_cycles),
                 resolution_led_pause_cycles);

  constant debug_force_bit          : natural := 0;
  constant debug_override_en_bit    : natural := 1;
  constant debug_override_value_bit : natural := 2;

  type led_state_t is (
    led_on_state,
    led_off_state,
    led_pause_state
  );

  component pwm_mch_buf is
    generic (
      r               : integer   := 7;
      d               : integer   := 2;
      num_channels    : integer   := 2;
      input_data_type : string    := "SIGNED";
      buffer_depth    : integer   := 1024;
      ref_type        : string    := "SYMMETRICAL";
      scale_factor    : real      := 0.8;
      offset_factor   : real      := 0.1;
      input_mode       : string    := "DECIMATED";
      input_data_decimation_factor : positive := 64;
      pulse_period_samples : positive := 1024;
      prefill_pulses       : positive := 2;
      resume_pulses        : positive := 1;
      refill_batch_pulses  : positive := 1;
      min_safe_pulses      : natural  := 0;
      fifo_margin_samples  : natural  := 4;
      ref_step        : integer   := 1;
      ref_updwn       : std_logic := '1';
      clk_freq_hz     : integer   := 100_000_000;
      clk_pwm_freq_hz : integer   := 200_000_000;
      use_post_scaler : boolean   := false
    );
    port (
      clk        : in    std_logic;
      clk_pwm    : in    std_logic;
      pwm_div_sel : in   std_logic_vector(1 downto 0) := (others => '0');
      rst        : in    std_logic;
      enable     : in    std_logic;
      input_wave : in    std_logic_vector(r - 1 downto 0);
      input_valid : in   std_logic := '1';
      input_sample_ce : out std_logic;
      pwm        : out   std_logic_vector(num_channels - 1 downto 0);
      pwm_n      : out   std_logic_vector(num_channels - 1 downto 0)
    );
  end component pwm_mch_buf;

  component vio_pwm_debug is
    port (
      clk        : in    std_logic;
      probe_out0 : out   std_logic_vector(2 downto 0);
      probe_out1 : out   std_logic_vector(2 downto 0)
    );
  end component vio_pwm_debug;

  component ila_pwm_debug is
    port (
      clk    : in    std_logic;
      probe0 : in    std_logic_vector(7 downto 0);
      probe1 : in    std_logic_vector(7 downto 0);
      probe2 : in    std_logic_vector(3 downto 0);
      probe3 : in    std_logic_vector(3 downto 0)
    );
  end component ila_pwm_debug;

  function lower_debug_bits (
    value : std_logic_vector
  ) return std_logic_vector is
    variable result : std_logic_vector(3 downto 0) := (others => '0');
  begin
    for i in result'range loop
      if ((i >= value'low) and (i <= value'high)) then
        result(i) := value(i);
      end if;
    end loop;

    return result;
  end function lower_debug_bits;

  signal obuf_clk  : std_logic := '0';
  signal gobuf_clk : std_logic := '0';

  signal mmcm_fb_in    : std_logic := '0';
  signal mmcm_clk_lock : std_logic := '0';

  signal clk            : std_logic := '0';
  signal clk_pwm        : std_logic := '0';
  signal sine_rst       : std_logic := '1';
  signal pwm_rst        : std_logic := '1';
  signal pwm_div_sel    : std_logic_vector(1 downto 0) := pwm_div_sel_2;
  signal rst_request    : std_logic := '0';
  signal pwm_divider_step_request : std_logic := '0';
  signal enable         : std_logic := '1';
  signal mode_led       : std_logic := '0';
  signal mode_led_state : led_state_t := led_pause_state;
  signal mode_led_timer : natural range 0 to led_counter_limit := 0;
  signal mode_led_remaining : natural range 0 to pwm_divider_mode_count := 0;

  signal source_sine_out   : std_logic_vector(source_data_width - 1 downto 0) := (others => '0');
  signal source_sine_valid : std_logic := '0';
  signal source_sine_sample_ce : std_logic := '0';
  signal source_sample : std_logic_vector(pwm_resolution_bits - 1 downto 0) := (others => '0');

  signal p_buf        : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_n_buf      : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_selected   : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_n_selected : std_logic_vector(num_channels - 1 downto 0) := (others => '0');

  signal vio_rst_ctrl             : std_logic_vector(2 downto 0) := (others => '0');
  signal vio_frequency_step_ctrl  : std_logic_vector(2 downto 0) := (others => '0');
  signal debug_probe_rst_ctrl     : std_logic_vector(7 downto 0) := (others => '0');
  signal debug_probe_frequency_ctrl : std_logic_vector(7 downto 0) := (others => '0');
  signal debug_probe_p_selected   : std_logic_vector(3 downto 0) := (others => '0');
  signal debug_probe_p_n_selected : std_logic_vector(3 downto 0) := (others => '0');

begin

  debug_value_valid : assert ((debug = "NO_DEBUG") or (debug = "DEBUG"))
    report "main: debug generic must be NO_DEBUG or DEBUG"
    severity failure;

  pwm_resolution_valid : assert ((pwm_resolution_bits >= 2) and
                                 (pwm_resolution_bits <= source_data_width))
    report "main: pwm_resolution_bits must be in range 2..16"
    severity failure;

  source_sample <= source_sine_out(source_data_width - 1 downto source_data_width - pwm_resolution_bits);

  no_debug_gen : if debug = "NO_DEBUG" generate

    rst_request              <= sys_rst;
    pwm_divider_step_request <= sys_pwm_mode;

  end generate no_debug_gen;

  debug_gen : if debug = "DEBUG" generate

    rst_request <= vio_rst_ctrl(debug_override_value_bit) when
                   (vio_rst_ctrl(debug_override_en_bit) = '1') else
                   (sys_rst or vio_rst_ctrl(debug_force_bit));

    pwm_divider_step_request <= vio_frequency_step_ctrl(debug_override_value_bit) when
                                (vio_frequency_step_ctrl(debug_override_en_bit) = '1') else
                                (sys_pwm_mode or vio_frequency_step_ctrl(debug_force_bit));

    debug_probe_rst_ctrl <= sys_rst &
                            vio_rst_ctrl(debug_override_value_bit) &
                            vio_rst_ctrl(debug_override_en_bit) &
                            vio_rst_ctrl(debug_force_bit) &
                            rst_request &
                            mmcm_clk_lock &
                            sine_rst &
                            pwm_rst;

    debug_probe_frequency_ctrl <= sys_pwm_mode &
                                  vio_frequency_step_ctrl(debug_override_value_bit) &
                                  vio_frequency_step_ctrl(debug_override_en_bit) &
                                  vio_frequency_step_ctrl(debug_force_bit) &
                                  pwm_divider_step_request &
                                  '0' &
                                  pwm_div_sel;

    debug_probe_p_selected   <= lower_debug_bits(p_selected);
    debug_probe_p_n_selected <= lower_debug_bits(p_n_selected);

    debug_vio : component vio_pwm_debug
      port map (
        clk        => clk,
        probe_out0 => vio_rst_ctrl,
        probe_out1 => vio_frequency_step_ctrl
      );

    debug_ila : component ila_pwm_debug
      port map (
        clk    => clk,
        probe0 => debug_probe_rst_ctrl,
        probe1 => debug_probe_frequency_ctrl,
        probe2 => debug_probe_p_selected,
        probe3 => debug_probe_p_n_selected
      );

  end generate debug_gen;

  mode_led_blinker : process (clk) is
    variable selected_blinks : natural range 0 to pwm_divider_mode_count;
  begin

    if rising_edge(clk) then
      selected_blinks := divider_blink_count(pwm_div_sel);

      if ((sine_rst = '1') or (pwm_rst = '1') or (selected_blinks = 0)) then
        mode_led <= '0';
        mode_led_state <= led_pause_state;
        mode_led_timer <= 0;
        mode_led_remaining <= 0;
      else
        case mode_led_state is
          when led_pause_state =>
            mode_led <= '0';

            if (mode_led_timer > 0) then
              mode_led_timer <= mode_led_timer - 1;
            else
              mode_led <= '1';
              mode_led_state <= led_on_state;
              mode_led_timer <= resolution_led_on_cycles - 1;
              mode_led_remaining <= selected_blinks;
            end if;

          when led_on_state =>
            mode_led <= '1';

            if (mode_led_timer > 0) then
              mode_led_timer <= mode_led_timer - 1;
            else
              mode_led <= '0';
              mode_led_state <= led_off_state;
              mode_led_timer <= resolution_led_off_cycles - 1;
            end if;

          when led_off_state =>
            mode_led <= '0';

            if (mode_led_timer > 0) then
              mode_led_timer <= mode_led_timer - 1;
            elsif (mode_led_remaining <= 1) then
              mode_led_state <= led_pause_state;
              mode_led_timer <= resolution_led_pause_cycles - 1;
              mode_led_remaining <= 0;
            else
              mode_led <= '1';
              mode_led_state <= led_on_state;
              mode_led_timer <= resolution_led_on_cycles - 1;
              mode_led_remaining <= mode_led_remaining - 1;
            end if;
        end case;
      end if;
    end if;

  end process mode_led_blinker;

  sys_clk_ibuffer : component ibuf
    port map (
      i => sys_clk,
      o => obuf_clk
    );

  clk_gbuffer : component bufg
    port map (
      i => obuf_clk,
      o => gobuf_clk
    );

  mmcm_adv : component mmcme2_adv
    generic map (
      clkfbout_mult_f => 8.0,
      clkin1_period   => 10.0,
      clkin2_period   => 10.0,
      clkout1_phase   => 0.0,
      clkout1_divide  => 16,
      clkout2_phase   => 0.0,
      clkout2_divide  => 4
    )
    port map (
      clkinsel => '1',
      clkin1   => gobuf_clk,
      clkin2   => gobuf_clk,
      daddr    => "0000000",
      dclk     => '0',
      den      => '0',
      di       => x"0000",
      dwe      => '0',
      psclk    => '0',
      psen     => '0',
      psincdec => '0',
      clkfbin  => mmcm_fb_in,
      pwrdwn   => '0',
      rst      => '0',
      clkfbout => mmcm_fb_in,
      clkout1  => clk,
      clkout2  => clk_pwm,
      locked   => mmcm_clk_lock
    );

  source_sine : entity work.sine_gen_simple
    generic map (
      wave_length => wave_length,
      bit_width   => source_data_width,
      data_type   => input_data_type,
      pulse_enable             => true,
      pulse_period_cycles      => sine_pulse_period_cycles,
      pulse_start_delay_cycles => sine_pulse_start_delay_cycles,
      pulse_duration_cycles    => sine_pulse_duration_cycles,
      pulse_front_cycles       => sine_pulse_front_cycles,
      pulse_fall_cycles        => sine_pulse_fall_cycles
    )
    port map (
      clk          => clk,
      reset        => sine_rst,
      sample_ce    => source_sine_sample_ce,
      output_valid => source_sine_valid,
      output_data  => source_sine_out
    );

  buffered_pwm : component pwm_mch_buf
    generic map (
      r               => pwm_resolution_bits,
      d               => num_dead_time_cycles,
      num_channels    => num_channels,
      ref_type        => ref_type,
      scale_factor    => scale_factor,
      offset_factor   => offset_factor,
      input_data_type => input_data_type,
      buffer_depth    => buffer_depth,
      input_mode      => "VALID",
      input_data_decimation_factor => input_data_decimation_factor,
      pulse_period_samples => sine_pulse_period_cycles,
      prefill_pulses       => sine_buffer_prefill_pulses,
      resume_pulses        => sine_buffer_resume_pulses,
      refill_batch_pulses  => sine_buffer_refill_batch_pulses,
      min_safe_pulses      => sine_buffer_min_safe_pulses,
      fifo_margin_samples  => sine_buffer_margin_samples,
      ref_step        => ref_step,
      ref_updwn       => ref_updwn,
      clk_freq_hz     => clk_freq_hz,
      clk_pwm_freq_hz => clk_pwm_freq_hz,
      use_post_scaler => true
    )
    port map (
      clk        => clk,
      clk_pwm    => clk_pwm,
      pwm_div_sel => pwm_div_sel,
      rst        => pwm_rst,
      enable     => enable,
      input_wave => source_sample,
      input_valid => source_sine_valid,
      input_sample_ce => source_sine_sample_ce,
      pwm        => p_buf,
      pwm_n      => p_n_buf
    );

  p_selected   <= pwm_idle when (pwm_rst = '1') else p_buf;
  p_n_selected <= pwm_idle when (pwm_rst = '1') else p_n_buf;

  reset_ctrl : entity work.main_reset_ctrl
    generic map (
      pwm_mode_switch_delay_cycles => pwm_mode_switch_delay_cycles,
      reset_release_cycles         => reset_release_cycles,
      button_debounce_cycles       => button_debounce_cycles,
      pwm_divider_mode_count       => pwm_divider_mode_count,
      default_pwm_divider_index    => default_pwm_divider_index
    )
    port map (
      clk              => clk,
      mmcm_clk_lock    => mmcm_clk_lock,
      rst_request      => rst_request,
      pwm_divider_step => pwm_divider_step_request,
      sine_rst         => sine_rst,
      pwm_rst          => pwm_rst,
      pwm_div_sel      => pwm_div_sel
    );

  pwm_obufs : for i in 0 to num_channels - 1 generate

    pwm_channel_obuf : component obuf
      port map (
        i => p_selected(i),
        o => sys_pwm(i)
      );

    pwm_n_channel_obuf : component obuf
      port map (
        i => p_n_selected(i),
        o => sys_pwm_n(i)
      );

  end generate pwm_obufs;

  mode_led_obuf : component obuf
    port map (
      i => mode_led,
      o => sys_led
    );

end architecture src;
