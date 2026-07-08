library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity main_reset_ctrl is
  generic (
    pwm_mode_switch_delay_cycles : natural  := 25_000_000;
    reset_release_cycles         : positive := 5;
    button_debounce_cycles       : positive := 1_000_000;
    min_pwm_resolution_bits      : positive := 4;
    max_pwm_resolution_bits      : positive := 8;
    default_pwm_resolution_bits  : positive := 6
  );
  port (
    clk              : in    std_logic;
    mmcm_clk_lock    : in    std_logic;
    rst_request      : in    std_logic;
    resolution_step  : in    std_logic;
    sine_rst         : out   std_logic;
    pwm_rst          : out   std_logic;
    resolution_sel   : out   std_logic_vector(2 downto 0)
  );
end entity main_reset_ctrl;

architecture src of main_reset_ctrl is

  constant resolution_mode_count : positive := max_pwm_resolution_bits - min_pwm_resolution_bits + 1;
  constant default_resolution_index : natural := default_pwm_resolution_bits - min_pwm_resolution_bits;

  signal mmcm_lock_sync       : std_logic_vector(1 downto 0) := "00";
  signal sys_rst_sync         : std_logic_vector(1 downto 0) := "11";
  signal step_sync            : std_logic_vector(2 downto 0) := "000";
  signal step_stable          : std_logic := '0';
  signal step_debounce_count  : natural range 0 to button_debounce_cycles := 0;

  signal sine_reset_count     : natural range 0 to reset_release_cycles := reset_release_cycles;
  signal pwm_reset_count      : natural range 0 to reset_release_cycles := reset_release_cycles;
  signal resolution_sel_reg   : natural range 0 to resolution_mode_count - 1 := default_resolution_index;
  signal pending_resolution_sel : natural range 0 to resolution_mode_count - 1 := default_resolution_index;
  signal resolution_delay_active : std_logic := '0';
  signal resolution_delay_count : natural range 0 to pwm_mode_switch_delay_cycles := 0;

  function next_resolution_index (
    current_index : natural
  ) return natural is
  begin
    if (current_index = resolution_mode_count - 1) then
      return 0;
    end if;

    return current_index + 1;
  end function next_resolution_index;

begin

  pwm_mode_switch_delay_valid : assert (pwm_mode_switch_delay_cycles > 0)
    report "main_reset_ctrl: pwm_mode_switch_delay_cycles must be greater than 0"
    severity failure;

  reset_release_cycles_valid : assert (reset_release_cycles >= 5)
    report "main_reset_ctrl: reset_release_cycles must be at least 5"
    severity failure;

  resolution_range_valid : assert (max_pwm_resolution_bits >= min_pwm_resolution_bits)
    report "main_reset_ctrl: max_pwm_resolution_bits must be >= min_pwm_resolution_bits"
    severity failure;

  resolution_mode_count_valid : assert (resolution_mode_count <= 8)
    report "main_reset_ctrl: resolution selector only supports up to 8 runtime modes"
    severity failure;

  default_resolution_valid : assert ((default_pwm_resolution_bits >= min_pwm_resolution_bits) and
                                     (default_pwm_resolution_bits <= max_pwm_resolution_bits))
    report "main_reset_ctrl: default_pwm_resolution_bits must be inside the runtime range"
    severity failure;

  sine_rst       <= '1' when (sine_reset_count > 0) else '0';
  pwm_rst        <= '1' when (pwm_reset_count > 0) else '0';
  resolution_sel <= std_logic_vector(to_unsigned(resolution_sel_reg, resolution_sel'length));

  rst_gen : process (clk) is
    variable step_event : boolean;
    variable next_sel   : natural range 0 to resolution_mode_count - 1;
  begin

    if rising_edge(clk) then
      step_event := false;
      mmcm_lock_sync <= mmcm_lock_sync(0) & mmcm_clk_lock;
      sys_rst_sync   <= sys_rst_sync(0) & rst_request;
      step_sync      <= step_sync(1 downto 0) & resolution_step;

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
        resolution_sel_reg <= default_resolution_index;
        pending_resolution_sel <= default_resolution_index;
        resolution_delay_active <= '0';
        resolution_delay_count <= 0;
        step_stable <= '0';
        step_debounce_count <= 0;
      elsif (resolution_delay_active = '1') then
        sine_reset_count <= reset_release_cycles;
        pwm_reset_count <= reset_release_cycles;

        if (resolution_delay_count = 0) then
          resolution_sel_reg <= pending_resolution_sel;
          resolution_delay_active <= '0';
        else
          resolution_delay_count <= resolution_delay_count - 1;
        end if;
      elsif (step_event) then
        next_sel := next_resolution_index(resolution_sel_reg);
        sine_reset_count <= reset_release_cycles;
        pwm_reset_count <= reset_release_cycles;
        pending_resolution_sel <= next_sel;
        resolution_delay_active <= '1';
        resolution_delay_count <= pwm_mode_switch_delay_cycles - 1;
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
    pwm_mode_switch_delay_cycles : natural := 25_000_000;
    button_debounce_cycles       : positive := 1_000_000;
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
    sys_pwm      : out   std_logic_vector(num_channels - 1 downto 0);
    sys_pwm_n    : out   std_logic_vector(num_channels - 1 downto 0)
  );
end entity main;

architecture src of main is

  constant source_data_width           : integer   := 16;
  constant min_pwm_resolution_bits     : integer   := 4;
  constant max_pwm_resolution_bits     : integer   := 8;
  constant default_pwm_resolution_bits : integer   := 6;
  constant num_dead_time_cycles        : integer   := 4;
  constant buffer_depth                : integer   := 16384;
  constant wave_length                 : integer   := sine_wave_length;
  constant input_data_type             : string    := "SIGNED";
  constant ref_type                    : string    := "SYMMETRICAL";
  constant scale_factor                : real      := 0.8;
  constant offset_factor               : real      := 0.0;
  constant ref_step                    : integer   := 1;
  constant ref_updwn                   : std_logic := '1';
  constant pwm_idle                    : std_logic_vector(num_channels - 1 downto 0) := (others => '0');

  constant resolution_sel_4 : std_logic_vector(2 downto 0) := "000";
  constant resolution_sel_5 : std_logic_vector(2 downto 0) := "001";
  constant resolution_sel_6 : std_logic_vector(2 downto 0) := "010";
  constant resolution_sel_7 : std_logic_vector(2 downto 0) := "011";
  constant resolution_sel_8 : std_logic_vector(2 downto 0) := "100";

  constant decimation_factor_4 : positive := 16;
  constant decimation_factor_5 : positive := 32;
  constant decimation_factor_6 : positive := 64;
  constant decimation_factor_7 : positive := 128;
  constant decimation_factor_8 : positive := 256;

  constant debug_force_bit          : natural := 0;
  constant debug_override_en_bit    : natural := 1;
  constant debug_override_value_bit : natural := 2;

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
      clk_pwm_freq_hz : integer   := 200_000_000
    );
    port (
      clk        : in    std_logic;
      clk_pwm    : in    std_logic;
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
  signal resolution_sel : std_logic_vector(2 downto 0) := resolution_sel_6;
  signal rst_request    : std_logic := '0';
  signal resolution_step_request : std_logic := '0';
  signal enable         : std_logic := '1';

  signal source_sine_out   : std_logic_vector(source_data_width - 1 downto 0) := (others => '0');
  signal source_sine_valid : std_logic := '0';
  signal source_sine_sample_ce : std_logic := '0';

  signal source_sample_4 : std_logic_vector(3 downto 0) := (others => '0');
  signal source_sample_5 : std_logic_vector(4 downto 0) := (others => '0');
  signal source_sample_6 : std_logic_vector(5 downto 0) := (others => '0');
  signal source_sample_7 : std_logic_vector(6 downto 0) := (others => '0');
  signal source_sample_8 : std_logic_vector(7 downto 0) := (others => '0');

  signal rst_pwm_4 : std_logic := '1';
  signal rst_pwm_5 : std_logic := '1';
  signal rst_pwm_6 : std_logic := '1';
  signal rst_pwm_7 : std_logic := '1';
  signal rst_pwm_8 : std_logic := '1';

  signal enable_pwm_4 : std_logic := '0';
  signal enable_pwm_5 : std_logic := '0';
  signal enable_pwm_6 : std_logic := '0';
  signal enable_pwm_7 : std_logic := '0';
  signal enable_pwm_8 : std_logic := '0';

  signal sample_ce_4 : std_logic := '0';
  signal sample_ce_5 : std_logic := '0';
  signal sample_ce_6 : std_logic := '0';
  signal sample_ce_7 : std_logic := '0';
  signal sample_ce_8 : std_logic := '0';

  signal p_buf_4   : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_buf_5   : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_buf_6   : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_buf_7   : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_buf_8   : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_n_buf_4 : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_n_buf_5 : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_n_buf_6 : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_n_buf_7 : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_n_buf_8 : std_logic_vector(num_channels - 1 downto 0) := (others => '0');

  signal p_mux        : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_n_mux      : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_selected   : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_n_selected : std_logic_vector(num_channels - 1 downto 0) := (others => '0');

  signal vio_rst_ctrl             : std_logic_vector(2 downto 0) := (others => '0');
  signal vio_resolution_step_ctrl : std_logic_vector(2 downto 0) := (others => '0');
  signal debug_probe_rst_ctrl     : std_logic_vector(7 downto 0) := (others => '0');
  signal debug_probe_resolution_ctrl : std_logic_vector(7 downto 0) := (others => '0');
  signal debug_probe_p_selected   : std_logic_vector(3 downto 0) := (others => '0');
  signal debug_probe_p_n_selected : std_logic_vector(3 downto 0) := (others => '0');

begin

  debug_value_valid : assert ((debug = "NO_DEBUG") or (debug = "DEBUG"))
    report "main: debug generic must be NO_DEBUG or DEBUG"
    severity failure;

  source_sample_4 <= source_sine_out(source_data_width - 1 downto source_data_width - 4);
  source_sample_5 <= source_sine_out(source_data_width - 1 downto source_data_width - 5);
  source_sample_6 <= source_sine_out(source_data_width - 1 downto source_data_width - 6);
  source_sample_7 <= source_sine_out(source_data_width - 1 downto source_data_width - 7);
  source_sample_8 <= source_sine_out(source_data_width - 1 downto source_data_width - 8);

  no_debug_gen : if debug = "NO_DEBUG" generate

    rst_request             <= sys_rst;
    resolution_step_request <= sys_pwm_mode;

  end generate no_debug_gen;

  debug_gen : if debug = "DEBUG" generate

    rst_request <= vio_rst_ctrl(debug_override_value_bit) when
                   (vio_rst_ctrl(debug_override_en_bit) = '1') else
                   (sys_rst or vio_rst_ctrl(debug_force_bit));

    resolution_step_request <= vio_resolution_step_ctrl(debug_override_value_bit) when
                               (vio_resolution_step_ctrl(debug_override_en_bit) = '1') else
                               (sys_pwm_mode or vio_resolution_step_ctrl(debug_force_bit));

    debug_probe_rst_ctrl <= sys_rst &
                            vio_rst_ctrl(debug_override_value_bit) &
                            vio_rst_ctrl(debug_override_en_bit) &
                            vio_rst_ctrl(debug_force_bit) &
                            rst_request &
                            mmcm_clk_lock &
                            sine_rst &
                            pwm_rst;

    debug_probe_resolution_ctrl <= sys_pwm_mode &
                                   vio_resolution_step_ctrl(debug_override_value_bit) &
                                   vio_resolution_step_ctrl(debug_override_en_bit) &
                                   vio_resolution_step_ctrl(debug_force_bit) &
                                   resolution_step_request &
                                   resolution_sel;

    debug_probe_p_selected   <= lower_debug_bits(p_selected);
    debug_probe_p_n_selected <= lower_debug_bits(p_n_selected);

    debug_vio : component vio_pwm_debug
      port map (
        clk        => clk,
        probe_out0 => vio_rst_ctrl,
        probe_out1 => vio_resolution_step_ctrl
      );

    debug_ila : component ila_pwm_debug
      port map (
        clk    => clk,
        probe0 => debug_probe_rst_ctrl,
        probe1 => debug_probe_resolution_ctrl,
        probe2 => debug_probe_p_selected,
        probe3 => debug_probe_p_n_selected
      );

  end generate debug_gen;

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
      clkin1_period   => 8.0,
      clkin2_period   => 8.0,
      clkout1_phase   => 0.0,
      clkout1_divide  => 16,
      clkout2_phase   => 0.0,
      clkout2_divide  => 8
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

  rst_pwm_4 <= pwm_rst when (resolution_sel = resolution_sel_4) else '1';
  rst_pwm_5 <= pwm_rst when (resolution_sel = resolution_sel_5) else '1';
  rst_pwm_6 <= pwm_rst when (resolution_sel = resolution_sel_6) else '1';
  rst_pwm_7 <= pwm_rst when (resolution_sel = resolution_sel_7) else '1';
  rst_pwm_8 <= pwm_rst when (resolution_sel = resolution_sel_8) else '1';

  enable_pwm_4 <= enable when (resolution_sel = resolution_sel_4) else '0';
  enable_pwm_5 <= enable when (resolution_sel = resolution_sel_5) else '0';
  enable_pwm_6 <= enable when (resolution_sel = resolution_sel_6) else '0';
  enable_pwm_7 <= enable when (resolution_sel = resolution_sel_7) else '0';
  enable_pwm_8 <= enable when (resolution_sel = resolution_sel_8) else '0';

  source_sine_sample_ce <= sample_ce_4 when (resolution_sel = resolution_sel_4) else
                           sample_ce_5 when (resolution_sel = resolution_sel_5) else
                           sample_ce_6 when (resolution_sel = resolution_sel_6) else
                           sample_ce_7 when (resolution_sel = resolution_sel_7) else
                           sample_ce_8 when (resolution_sel = resolution_sel_8) else
                           '0';

  buffered_pwm_4 : component pwm_mch_buf
    generic map (
      r               => 4,
      d               => num_dead_time_cycles,
      num_channels    => num_channels,
      ref_type        => ref_type,
      scale_factor    => scale_factor,
      offset_factor   => offset_factor,
      input_data_type => input_data_type,
      buffer_depth    => buffer_depth,
      input_mode      => "VALID",
      input_data_decimation_factor => decimation_factor_4,
      pulse_period_samples => sine_pulse_period_cycles,
      prefill_pulses       => sine_buffer_prefill_pulses,
      resume_pulses        => sine_buffer_resume_pulses,
      refill_batch_pulses  => sine_buffer_refill_batch_pulses,
      min_safe_pulses      => sine_buffer_min_safe_pulses,
      fifo_margin_samples  => sine_buffer_margin_samples,
      ref_step        => ref_step,
      ref_updwn       => ref_updwn
    )
    port map (
      clk        => clk,
      clk_pwm    => clk_pwm,
      rst        => rst_pwm_4,
      enable     => enable_pwm_4,
      input_wave => source_sample_4,
      input_valid => source_sine_valid,
      input_sample_ce => sample_ce_4,
      pwm        => p_buf_4,
      pwm_n      => p_n_buf_4
    );

  buffered_pwm_5 : component pwm_mch_buf
    generic map (
      r               => 5,
      d               => num_dead_time_cycles,
      num_channels    => num_channels,
      ref_type        => ref_type,
      scale_factor    => scale_factor,
      offset_factor   => offset_factor,
      input_data_type => input_data_type,
      buffer_depth    => buffer_depth,
      input_mode      => "VALID",
      input_data_decimation_factor => decimation_factor_5,
      pulse_period_samples => sine_pulse_period_cycles,
      prefill_pulses       => sine_buffer_prefill_pulses,
      resume_pulses        => sine_buffer_resume_pulses,
      refill_batch_pulses  => sine_buffer_refill_batch_pulses,
      min_safe_pulses      => sine_buffer_min_safe_pulses,
      fifo_margin_samples  => sine_buffer_margin_samples,
      ref_step        => ref_step,
      ref_updwn       => ref_updwn
    )
    port map (
      clk        => clk,
      clk_pwm    => clk_pwm,
      rst        => rst_pwm_5,
      enable     => enable_pwm_5,
      input_wave => source_sample_5,
      input_valid => source_sine_valid,
      input_sample_ce => sample_ce_5,
      pwm        => p_buf_5,
      pwm_n      => p_n_buf_5
    );

  buffered_pwm_6 : component pwm_mch_buf
    generic map (
      r               => 6,
      d               => num_dead_time_cycles,
      num_channels    => num_channels,
      ref_type        => ref_type,
      scale_factor    => scale_factor,
      offset_factor   => offset_factor,
      input_data_type => input_data_type,
      buffer_depth    => buffer_depth,
      input_mode      => "VALID",
      input_data_decimation_factor => decimation_factor_6,
      pulse_period_samples => sine_pulse_period_cycles,
      prefill_pulses       => sine_buffer_prefill_pulses,
      resume_pulses        => sine_buffer_resume_pulses,
      refill_batch_pulses  => sine_buffer_refill_batch_pulses,
      min_safe_pulses      => sine_buffer_min_safe_pulses,
      fifo_margin_samples  => sine_buffer_margin_samples,
      ref_step        => ref_step,
      ref_updwn       => ref_updwn
    )
    port map (
      clk        => clk,
      clk_pwm    => clk_pwm,
      rst        => rst_pwm_6,
      enable     => enable_pwm_6,
      input_wave => source_sample_6,
      input_valid => source_sine_valid,
      input_sample_ce => sample_ce_6,
      pwm        => p_buf_6,
      pwm_n      => p_n_buf_6
    );

  buffered_pwm_7 : component pwm_mch_buf
    generic map (
      r               => 7,
      d               => num_dead_time_cycles,
      num_channels    => num_channels,
      ref_type        => ref_type,
      scale_factor    => scale_factor,
      offset_factor   => offset_factor,
      input_data_type => input_data_type,
      buffer_depth    => buffer_depth,
      input_mode      => "VALID",
      input_data_decimation_factor => decimation_factor_7,
      pulse_period_samples => sine_pulse_period_cycles,
      prefill_pulses       => sine_buffer_prefill_pulses,
      resume_pulses        => sine_buffer_resume_pulses,
      refill_batch_pulses  => sine_buffer_refill_batch_pulses,
      min_safe_pulses      => sine_buffer_min_safe_pulses,
      fifo_margin_samples  => sine_buffer_margin_samples,
      ref_step        => ref_step,
      ref_updwn       => ref_updwn
    )
    port map (
      clk        => clk,
      clk_pwm    => clk_pwm,
      rst        => rst_pwm_7,
      enable     => enable_pwm_7,
      input_wave => source_sample_7,
      input_valid => source_sine_valid,
      input_sample_ce => sample_ce_7,
      pwm        => p_buf_7,
      pwm_n      => p_n_buf_7
    );

  buffered_pwm_8 : component pwm_mch_buf
    generic map (
      r               => 8,
      d               => num_dead_time_cycles,
      num_channels    => num_channels,
      ref_type        => ref_type,
      scale_factor    => scale_factor,
      offset_factor   => offset_factor,
      input_data_type => input_data_type,
      buffer_depth    => buffer_depth,
      input_mode      => "VALID",
      input_data_decimation_factor => decimation_factor_8,
      pulse_period_samples => sine_pulse_period_cycles,
      prefill_pulses       => sine_buffer_prefill_pulses,
      resume_pulses        => sine_buffer_resume_pulses,
      refill_batch_pulses  => sine_buffer_refill_batch_pulses,
      min_safe_pulses      => sine_buffer_min_safe_pulses,
      fifo_margin_samples  => sine_buffer_margin_samples,
      ref_step        => ref_step,
      ref_updwn       => ref_updwn
    )
    port map (
      clk        => clk,
      clk_pwm    => clk_pwm,
      rst        => rst_pwm_8,
      enable     => enable_pwm_8,
      input_wave => source_sample_8,
      input_valid => source_sine_valid,
      input_sample_ce => sample_ce_8,
      pwm        => p_buf_8,
      pwm_n      => p_n_buf_8
    );

  p_mux <= p_buf_4 when (resolution_sel = resolution_sel_4) else
           p_buf_5 when (resolution_sel = resolution_sel_5) else
           p_buf_6 when (resolution_sel = resolution_sel_6) else
           p_buf_7 when (resolution_sel = resolution_sel_7) else
           p_buf_8 when (resolution_sel = resolution_sel_8) else
           pwm_idle;

  p_n_mux <= p_n_buf_4 when (resolution_sel = resolution_sel_4) else
             p_n_buf_5 when (resolution_sel = resolution_sel_5) else
             p_n_buf_6 when (resolution_sel = resolution_sel_6) else
             p_n_buf_7 when (resolution_sel = resolution_sel_7) else
             p_n_buf_8 when (resolution_sel = resolution_sel_8) else
             pwm_idle;

  p_selected   <= pwm_idle when (pwm_rst = '1') else p_mux;
  p_n_selected <= pwm_idle when (pwm_rst = '1') else p_n_mux;

  reset_ctrl : entity work.main_reset_ctrl
    generic map (
      pwm_mode_switch_delay_cycles => pwm_mode_switch_delay_cycles,
      reset_release_cycles         => reset_release_cycles,
      button_debounce_cycles       => button_debounce_cycles,
      min_pwm_resolution_bits      => min_pwm_resolution_bits,
      max_pwm_resolution_bits      => max_pwm_resolution_bits,
      default_pwm_resolution_bits  => default_pwm_resolution_bits
    )
    port map (
      clk              => clk,
      mmcm_clk_lock    => mmcm_clk_lock,
      rst_request      => rst_request,
      resolution_step  => resolution_step_request,
      sine_rst         => sine_rst,
      pwm_rst          => pwm_rst,
      resolution_sel   => resolution_sel
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

end architecture src;
