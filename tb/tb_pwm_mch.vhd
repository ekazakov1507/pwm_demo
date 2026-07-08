library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity tb_pwm_mch is
--  Port ( );
end entity tb_pwm_mch;

architecture tb of tb_pwm_mch is

  constant clk_period           : time      := 10 ns;
  constant data_width           : integer   := 7;
  constant ref_init             : integer   := -2 ** data_width / 2;
  constant num_dead_time_cycles : integer   := 1;
  constant buffer_depth         : integer   := 256;
  constant num_channels         : integer   := 2;
  constant input_data_type      : string    := "SIGNED";
  constant ref_type             : string    := "SYMMETRICAL";
  constant ref_step             : integer   := 1;
  constant ref_updwn            : std_logic := '1';
  constant sine_wave_length              : positive := 1024;
  constant sine_pulse_period_cycles      : positive := 4096;
  constant sine_pulse_start_delay_cycles : natural  := 256;
  constant sine_pulse_duration_cycles    : positive := 1024;
  constant sine_pulse_front_cycles       : natural  := 128;
  constant sine_pulse_fall_cycles        : natural  := 128;
  constant sine_pulse_active_probe_cycle : natural  := sine_pulse_start_delay_cycles +
                                                       sine_pulse_front_cycles +
                                                       sine_wave_length / 8;
  constant sine_pulse_trailing_empty_cycle : natural := sine_pulse_start_delay_cycles +
                                                       sine_pulse_duration_cycles;
  constant sine_pulse_repeat_probe_cycle : natural := sine_pulse_period_cycles +
                                                      sine_pulse_active_probe_cycle;
  constant sine_pulse_active_min         : integer := 20;
  constant valid_input_decimation_factor : positive := 4;
  constant valid_pulse_period_samples    : positive := 16;
  constant valid_buffer_prefill_pulses   : positive := 2;
  constant valid_buffer_resume_pulses    : positive := 1;
  constant valid_buffer_refill_pulses    : positive := 1;
  constant valid_buffer_margin_samples   : natural  := 4;
  constant valid_prefill_sample_count    : natural  := valid_pulse_period_samples *
                                                       valid_buffer_prefill_pulses;

  signal clk     : std_logic                                 := '0';
  signal clk_pwm : std_logic                                 := '0';
  signal rst     : std_logic                                 := '0';
  signal enable  : std_logic                                 := '0';
  signal data_in : std_logic_vector(data_width - 1 downto 0) := (others => '0');

  signal p        : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_n      : std_logic_vector(num_channels - 1 downto 0) := (others => '0');

  signal p_buf      : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_n_buf    : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_valid_buf      : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_n_valid_buf    : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal valid_sine_out   : std_logic_vector(data_width - 1 downto 0) := (others => '0');
  signal valid_sine_valid : std_logic := '0';
  signal valid_sine_sample_ce : std_logic := '0';

  signal saw_simple_pwm_hi   : boolean := false;
  signal saw_simple_pwm_n_hi : boolean := false;
  signal saw_simple_both_on  : boolean := false;

  signal saw_buf_pwm_hi   : boolean := false;
  signal saw_buf_pwm_n_hi : boolean := false;
  signal saw_buf_both_on  : boolean := false;
  signal saw_valid_buf_pwm_hi   : boolean := false;
  signal saw_valid_buf_pwm_n_hi : boolean := false;
  signal saw_valid_buf_both_on  : boolean := false;
  signal saw_valid_buf_before_prefill : boolean := false;
  signal valid_prefill_done : boolean := false;
  signal valid_sample_spacing_checks_done : boolean := false;
  signal source_pulse_checks_done : boolean := false;

begin

  dut_sine : entity work.sine_gen_simple
    generic map (
      wave_length              => sine_wave_length,
      bit_width                => data_width,
      data_type                => input_data_type,
      pulse_enable             => true,
      pulse_period_cycles      => sine_pulse_period_cycles,
      pulse_start_delay_cycles => sine_pulse_start_delay_cycles,
      pulse_duration_cycles    => sine_pulse_duration_cycles,
      pulse_front_cycles       => sine_pulse_front_cycles,
      pulse_fall_cycles        => sine_pulse_fall_cycles
    )
    port map (
      clk          => clk,
      reset        => rst,
      output_valid => open,
      output_data  => data_in
    );

  simple_pwm : entity work.pwm_mch
    generic map (
      r               => data_width,
      input_width     => data_width,
      d               => num_dead_time_cycles,
      num_channels    => num_channels,
      input_data_type => input_data_type,
      ref_type        => ref_type,
      ref_step        => ref_step,
      fp23_binary_point => data_width - 1
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
      r               => data_width,
      d               => num_dead_time_cycles,
      num_channels    => num_channels,
      ref_type        => ref_type,
      input_data_type => input_data_type,
      buffer_depth    => buffer_depth,
      ref_step        => ref_step,
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

  valid_sine : entity work.sine_gen_simple
    generic map (
      wave_length              => valid_pulse_period_samples,
      bit_width                => data_width,
      data_type                => input_data_type,
      pulse_enable             => true,
      pulse_period_cycles      => valid_pulse_period_samples,
      pulse_start_delay_cycles => 0,
      pulse_duration_cycles    => valid_pulse_period_samples,
      pulse_front_cycles       => 0,
      pulse_fall_cycles        => 0
    )
    port map (
      clk          => clk,
      reset        => rst,
      sample_ce    => valid_sine_sample_ce,
      output_valid => valid_sine_valid,
      output_data  => valid_sine_out
    );

  valid_adv_pwm : entity work.pwm_mch_buf
    generic map (
      r               => data_width,
      d               => num_dead_time_cycles,
      num_channels    => num_channels,
      ref_type        => ref_type,
      input_data_type => input_data_type,
      buffer_depth    => buffer_depth,
      input_mode      => "VALID",
      input_data_decimation_factor => valid_input_decimation_factor,
      pulse_period_samples => valid_pulse_period_samples,
      prefill_pulses       => valid_buffer_prefill_pulses,
      resume_pulses        => valid_buffer_resume_pulses,
      refill_batch_pulses  => valid_buffer_refill_pulses,
      fifo_margin_samples  => valid_buffer_margin_samples,
      ref_step        => ref_step,
      ref_updwn       => ref_updwn
    )
    port map (
      clk        => clk,
      clk_pwm    => clk_pwm,
      rst        => rst,
      enable     => enable,
      input_wave => valid_sine_out,
      input_valid => valid_sine_valid,
      input_sample_ce => valid_sine_sample_ce,
      pwm        => p_valid_buf,
      pwm_n      => p_n_valid_buf
    );

  clk <= not clk after clk_period / 2;

  -- Symmetric PWM + pwm_mch_buf expect faster pwm clock (2x main clk here).
  clk_pwm <= not clk_pwm after clk_period / 4;

  stim_proc : process is
  begin

    rst    <= '1';
    wait for clk_period * 2;
    rst    <= '0';
    wait for clk_period;
    enable <= '1';
    wait for 250 us;

    assert source_pulse_checks_done
      report "sine_gen_simple pulse source: pulse checks did not complete"
      severity failure;
    assert saw_simple_pwm_hi
      report "pwm_mch: expected pwm activity"
      severity failure;
    assert saw_simple_pwm_n_hi
      report "pwm_mch: expected pwm_n activity"
      severity failure;
    assert not saw_simple_both_on
      report "pwm_mch: pwm and pwm_n must not be high together"
      severity failure;

    assert saw_buf_pwm_hi
      report "pwm_mch_buf: expected pwm activity"
      severity failure;
    assert saw_buf_pwm_n_hi
      report "pwm_mch_buf: expected pwm_n activity"
      severity failure;
    assert not saw_buf_both_on
      report "pwm_mch_buf: pwm and pwm_n must not be high together"
      severity failure;
    assert valid_sample_spacing_checks_done
      report "pwm_mch_buf VALID: input_sample_ce spacing checks did not complete"
      severity failure;
    assert saw_valid_buf_pwm_hi
      report "pwm_mch_buf VALID: expected pwm activity after pulse-frame prefill"
      severity failure;
    assert saw_valid_buf_pwm_n_hi
      report "pwm_mch_buf VALID: expected pwm_n activity after pulse-frame prefill"
      severity failure;
    assert not saw_valid_buf_both_on
      report "pwm_mch_buf VALID: pwm and pwm_n must not be high together"
      severity failure;
    assert not saw_valid_buf_before_prefill
      report "pwm_mch_buf VALID: output activity started before pulse-frame prefill"
      severity failure;

    wait for clk_period;
    wait;

  end process stim_proc;

  complementary_monitor : process (clk) is
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        saw_simple_pwm_hi   <= false;
        saw_simple_pwm_n_hi <= false;
        saw_simple_both_on  <= false;
      elsif (enable = '1') then
        if (p(0) = '1') then
          saw_simple_pwm_hi <= true;
        end if;
        if (p_n(0) = '1') then
          saw_simple_pwm_n_hi <= true;
        end if;
        if ((p(0) = '1') and (p_n(0) = '1')) then
          saw_simple_both_on <= true;
        end if;
      end if;
    end if;
  end process complementary_monitor;

  complementary_buf_monitor : process (clk_pwm) is
  begin
    if rising_edge(clk_pwm) then
      if (rst = '1') then
        saw_buf_pwm_hi   <= false;
        saw_buf_pwm_n_hi <= false;
        saw_buf_both_on  <= false;
      elsif (enable = '1') then
        if (p_buf(0) = '1') then
          saw_buf_pwm_hi <= true;
        end if;
        if (p_n_buf(0) = '1') then
          saw_buf_pwm_n_hi <= true;
        end if;
        if ((p_buf(0) = '1') and (p_n_buf(0) = '1')) then
          saw_buf_both_on <= true;
        end if;
      end if;
    end if;
  end process complementary_buf_monitor;

  valid_sample_ce_monitor : process (clk) is
    variable clk_cycle         : natural := 0;
    variable previous_ce_cycle : natural := 0;
    variable have_previous_ce  : boolean := false;
    variable ce_count          : natural := 0;
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        clk_cycle := 0;
        previous_ce_cycle := 0;
        have_previous_ce := false;
        ce_count := 0;
        valid_prefill_done <= false;
        valid_sample_spacing_checks_done <= false;
      else
        if (valid_sine_sample_ce = '1') then
          if (have_previous_ce and (not valid_sample_spacing_checks_done)) then
            assert (clk_cycle - previous_ce_cycle = valid_input_decimation_factor)
              report "pwm_mch_buf VALID: input_sample_ce spacing was "
                     & integer'image(clk_cycle - previous_ce_cycle)
                     & " cycles, expected "
                     & integer'image(valid_input_decimation_factor)
              severity failure;
          else
            have_previous_ce := true;
          end if;

          previous_ce_cycle := clk_cycle;
          ce_count := ce_count + 1;
          if (ce_count >= valid_prefill_sample_count) then
            valid_prefill_done <= true;
          end if;

          if (ce_count >= 6) then
            valid_sample_spacing_checks_done <= true;
          end if;
        end if;

        clk_cycle := clk_cycle + 1;
      end if;
    end if;
  end process valid_sample_ce_monitor;

  valid_buffer_monitor : process (clk_pwm) is
  begin
    if rising_edge(clk_pwm) then
      if (rst = '1') then
        saw_valid_buf_pwm_hi <= false;
        saw_valid_buf_pwm_n_hi <= false;
        saw_valid_buf_both_on <= false;
        saw_valid_buf_before_prefill <= false;
      elsif (enable = '1') then
        if ((p_valid_buf /= (p_valid_buf'range => '0')) or
            (p_n_valid_buf /= (p_n_valid_buf'range => '0'))) then
          if valid_prefill_done then
            saw_valid_buf_pwm_hi <= saw_valid_buf_pwm_hi or (p_valid_buf(0) = '1');
            saw_valid_buf_pwm_n_hi <= saw_valid_buf_pwm_n_hi or (p_n_valid_buf(0) = '1');
          else
            saw_valid_buf_before_prefill <= true;
          end if;
        end if;

        if ((p_valid_buf(0) = '1') and (p_n_valid_buf(0) = '1')) then
          saw_valid_buf_both_on <= true;
        end if;
      end if;
    end if;
  end process valid_buffer_monitor;

  pulse_source_monitor : process is
    variable sample : integer := 0;
  begin

    wait until rst = '0';

    for cycle in 0 to sine_pulse_repeat_probe_cycle loop
      wait until rising_edge(clk);
      wait for 1 ns;
      sample := to_integer(signed(data_in));

      if (cycle < sine_pulse_start_delay_cycles) then
        assert sample = 0
          report "sine_gen_simple pulse source: leading empty cycle was not zero at cycle "
                 & integer'image(cycle) & ", got " & integer'image(sample)
          severity failure;
      elsif (cycle = sine_pulse_active_probe_cycle) then
        assert sample > sine_pulse_active_min
          report "sine_gen_simple pulse source: active pulse did not reach positive sine amplitude, got "
                 & integer'image(sample)
          severity failure;
      elsif (cycle = sine_pulse_trailing_empty_cycle) then
        assert sample = 0
          report "sine_gen_simple pulse source: trailing empty cycle was not zero, got "
                 & integer'image(sample)
          severity failure;
      elsif (cycle = sine_pulse_repeat_probe_cycle) then
        assert sample > sine_pulse_active_min
          report "sine_gen_simple pulse source: repeated pulse did not reach positive sine amplitude, got "
                 & integer'image(sample)
          severity failure;
      end if;
    end loop;

    source_pulse_checks_done <= true;
    wait;

  end process pulse_source_monitor;

end architecture tb;
