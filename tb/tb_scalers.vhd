library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity tb_scalers is
end entity tb_scalers;

architecture tb of tb_scalers is

  signal clk                 : std_logic := '0';
  signal reset               : std_logic := '1';
  signal sine_out_unsigned   : std_logic_vector(15 downto 0);
  signal sine_out_signed     : std_logic_vector(15 downto 0);
  signal sine_ramp_unsigned  : std_logic_vector(15 downto 0) := (others => '0');
  signal sine_ramp_signed    : std_logic_vector(15 downto 0) := (others => '0');
  signal sine_pulse_signed   : std_logic_vector(15 downto 0) := (others => '0');
  signal sine_pulse_unsigned : std_logic_vector(15 downto 0) := (others => '0');
  signal scaled_out_unsigned : std_logic_vector(15 downto 0);
  signal scaled_out_signed   : std_logic_vector(15 downto 0);
  signal pulse_checks_done   : boolean := false;

  constant clk_period                : time     := 10 ns;
  constant ramp_test_wave_length     : positive := 16;
  constant ramp_test_length          : positive := 16;
  constant ramp_unsigned_midpoint    : integer  := (2 ** 16 - 1) / 2;
  constant ramp_signed_partial_limit : integer  := 12000;
  constant ramp_unsigned_partial_max : integer  := 45000;
  constant ramp_signed_full_min      : integer  := 30000;
  constant ramp_unsigned_full_min    : integer  := 60000;
  constant pulse_test_wave_length              : positive := 16;
  constant pulse_test_period_cycles            : positive := 20;
  constant pulse_test_start_delay_cycles       : natural  := 2;
  constant pulse_test_duration_cycles          : positive := 12;
  constant pulse_test_front_cycles             : natural  := 4;
  constant pulse_test_fall_cycles              : natural  := 4;
  constant pulse_front_probe_cycle             : natural  := pulse_test_start_delay_cycles + 2;
  constant pulse_flat_probe_cycle              : natural  := pulse_test_start_delay_cycles +
                                                             pulse_test_front_cycles;
  constant pulse_fall_probe_cycle              : natural  := pulse_test_start_delay_cycles +
                                                             pulse_test_duration_cycles - 1;
  constant pulse_trailing_empty_cycle          : natural  := pulse_test_start_delay_cycles +
                                                             pulse_test_duration_cycles;
  constant pulse_repeat_front_probe_cycle      : natural  := pulse_test_period_cycles +
                                                             pulse_front_probe_cycle;
  constant pulse_unsigned_neutral              : integer  := 2 ** 15;
  constant pulse_front_probe_max               : integer  := 20000;
  constant pulse_flat_probe_min                : integer  := 30000;
  constant pulse_fall_probe_abs_max            : integer  := 10000;

  function to_real (
    slv : std_logic_vector(15 downto 0)
  ) return real is
  begin

    return real(to_integer(unsigned(slv))) / 65536.0;

  end function to_real;

begin

  dut_sine : entity work.sine_gen_simple
    generic map (
      wave_length => 1024,
      bit_width   => 16,
      data_type   => "UNSIGNED"
    )
    port map (
      clk         => clk,
      reset       => reset,
      output_data => sine_out_unsigned
    );

  dut_scaler : entity work.scaler_unsigned
    generic map (
      r             => 16,
      scale_factor  => 0.8,
      offset_factor => 0.1
    )
    port map (
      clk         => clk,
      reset       => reset,
      input_data  => sine_out_unsigned,
      output_data => scaled_out_unsigned
    );

  ut_sine : entity work.sine_gen_simple
    generic map (
      wave_length => 1024,
      bit_width   => 16,
      data_type   => "SIGNED"
    )
    port map (
      clk         => clk,
      reset       => reset,
      output_data => sine_out_signed
    );

  ut_scaler : entity work.scaler_signed
    generic map (
      r            => 16,
      scale_factor => 0.8 + 0.1
    )
    port map (
      clk         => clk,
      reset       => reset,
      input_data  => sine_out_signed,
      output_data => scaled_out_signed
    );

  ramp_sine_unsigned : entity work.sine_gen_simple
    generic map (
      wave_length => ramp_test_wave_length,
      bit_width   => 16,
      data_type   => "UNSIGNED",
      ramp_enable => true,
      ramp_length => ramp_test_length
    )
    port map (
      clk         => clk,
      reset       => reset,
      output_data => sine_ramp_unsigned
    );

  ramp_sine_signed : entity work.sine_gen_simple
    generic map (
      wave_length => ramp_test_wave_length,
      bit_width   => 16,
      data_type   => "SIGNED",
      ramp_enable => true,
      ramp_length => ramp_test_length
    )
    port map (
      clk         => clk,
      reset       => reset,
      output_data => sine_ramp_signed
    );

  pulse_sine_signed : entity work.sine_gen_simple
    generic map (
      wave_length              => pulse_test_wave_length,
      bit_width                => 16,
      data_type                => "SIGNED",
      pulse_enable             => true,
      pulse_period_cycles      => pulse_test_period_cycles,
      pulse_start_delay_cycles => pulse_test_start_delay_cycles,
      pulse_duration_cycles    => pulse_test_duration_cycles,
      pulse_front_cycles       => pulse_test_front_cycles,
      pulse_fall_cycles        => pulse_test_fall_cycles
    )
    port map (
      clk         => clk,
      reset       => reset,
      output_data => sine_pulse_signed
    );

  pulse_sine_unsigned : entity work.sine_gen_simple
    generic map (
      wave_length              => pulse_test_wave_length,
      bit_width                => 16,
      data_type                => "UNSIGNED",
      pulse_enable             => true,
      pulse_period_cycles      => pulse_test_period_cycles,
      pulse_start_delay_cycles => pulse_test_start_delay_cycles,
      pulse_duration_cycles    => pulse_test_duration_cycles,
      pulse_front_cycles       => pulse_test_front_cycles,
      pulse_fall_cycles        => pulse_test_fall_cycles
    )
    port map (
      clk         => clk,
      reset       => reset,
      output_data => sine_pulse_unsigned
    );

  clk <= not clk after clk_period / 2;

  process is
    variable signed_sample   : integer := 0;
    variable unsigned_sample : integer := 0;
  begin

    report "Starting simple sine (math_real) + scaler simulation";
    wait for 40 ns;
    reset <= '0';

    wait until rising_edge(clk);
    wait for 1 ns;
    signed_sample   := to_integer(signed(sine_ramp_signed));
    unsigned_sample := to_integer(unsigned(sine_ramp_unsigned));

    assert signed_sample = 0
      report "Ramp SIGNED: first post-reset sample must start at zero"
      severity failure;
    assert unsigned_sample = ramp_unsigned_midpoint
      report "Ramp UNSIGNED: first post-reset sample must start at midscale, got "
             & integer'image(unsigned_sample)
      severity failure;

    for i in 1 to 4 loop
      wait until rising_edge(clk);
    end loop;

    wait for 1 ns;
    signed_sample   := to_integer(signed(sine_ramp_signed));
    unsigned_sample := to_integer(unsigned(sine_ramp_unsigned));

    assert signed_sample > 0 and signed_sample < ramp_signed_partial_limit
      report "Ramp SIGNED: quarter-cycle sample was not amplitude-limited during launch, got "
             & integer'image(signed_sample)
      severity failure;
    assert unsigned_sample > ramp_unsigned_midpoint and unsigned_sample < ramp_unsigned_partial_max
      report "Ramp UNSIGNED: quarter-cycle sample was not amplitude-limited during launch, got "
             & integer'image(unsigned_sample)
      severity failure;

    for i in 1 to ramp_test_length loop
      wait until rising_edge(clk);
    end loop;

    wait for 1 ns;
    signed_sample   := to_integer(signed(sine_ramp_signed));
    unsigned_sample := to_integer(unsigned(sine_ramp_unsigned));

    assert signed_sample > ramp_signed_full_min
      report "Ramp SIGNED: quarter-cycle sample did not reach full amplitude after launch, got "
             & integer'image(signed_sample)
      severity failure;
    assert unsigned_sample > ramp_unsigned_full_min
      report "Ramp UNSIGNED: quarter-cycle sample did not reach full amplitude after launch, got "
             & integer'image(unsigned_sample)
      severity failure;

    wait for 3000 * clk_period;
    if (not pulse_checks_done) then
      wait until pulse_checks_done;
    end if;

    report "Simulation finished. Check waveform!";
    wait;

  end process;

  pulse_monitor : process is
    variable pulse_sample          : integer := 0;
    variable pulse_unsigned_sample : integer := 0;
  begin

    wait until reset = '0';

    for cycle in 0 to pulse_repeat_front_probe_cycle loop
      wait until rising_edge(clk);
      wait for 1 ns;
      pulse_sample          := to_integer(signed(sine_pulse_signed));
      pulse_unsigned_sample := to_integer(unsigned(sine_pulse_unsigned));

      if (cycle < pulse_test_start_delay_cycles) then
        assert pulse_sample = 0
          report "Pulse SIGNED: leading empty cycle was not zero at cycle "
                 & integer'image(cycle) & ", got " & integer'image(pulse_sample)
          severity failure;
        assert pulse_unsigned_sample = pulse_unsigned_neutral
          report "Pulse UNSIGNED: leading empty cycle was not neutral at cycle "
                 & integer'image(cycle) & ", got " & integer'image(pulse_unsigned_sample)
          severity failure;
      elsif (cycle = pulse_front_probe_cycle) then
        assert pulse_sample > 0 and pulse_sample < pulse_front_probe_max
          report "Pulse SIGNED: front ramp sample was not limited positive amplitude, got "
                 & integer'image(pulse_sample)
          severity failure;
      elsif (cycle = pulse_flat_probe_cycle) then
        assert pulse_sample > pulse_flat_probe_min
          report "Pulse SIGNED: flat-top sample did not reach full sine amplitude, got "
                 & integer'image(pulse_sample)
          severity failure;
      elsif (cycle = pulse_fall_probe_cycle) then
        assert pulse_sample < 0 and abs(pulse_sample) < pulse_fall_probe_abs_max
          report "Pulse SIGNED: fall ramp sample was not reduced negative amplitude, got "
                 & integer'image(pulse_sample)
          severity failure;
      elsif (cycle = pulse_trailing_empty_cycle) then
        assert pulse_sample = 0
          report "Pulse SIGNED: trailing empty cycle was not zero, got "
                 & integer'image(pulse_sample)
          severity failure;
        assert pulse_unsigned_sample = pulse_unsigned_neutral
          report "Pulse UNSIGNED: trailing empty cycle was not neutral, got "
                 & integer'image(pulse_unsigned_sample)
          severity failure;
      elsif (cycle = pulse_repeat_front_probe_cycle) then
        assert pulse_sample > 0 and pulse_sample < pulse_front_probe_max
          report "Pulse SIGNED: repeated period front ramp sample was wrong, got "
                 & integer'image(pulse_sample)
          severity failure;
      end if;
    end loop;

    pulse_checks_done <= true;
    wait;

  end process pulse_monitor;

-- process(clk)
-- begin
--     if rising_edge(clk) and reset = '0' then
--         report "Sine: " & real'image(to_real(sine_out)) &
--                " → Scaled: " & real'image(to_real(scaled_out));
--     end if;
-- end process;

end architecture tb;
