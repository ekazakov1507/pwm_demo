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
  signal scaled_out_unsigned : std_logic_vector(15 downto 0);
  signal scaled_out_signed   : std_logic_vector(15 downto 0);

  constant clk_period                : time     := 10 ns;
  constant ramp_test_wave_length     : positive := 16;
  constant ramp_test_length          : positive := 16;
  constant ramp_unsigned_midpoint    : integer  := (2 ** 16 - 1) / 2;
  constant ramp_signed_partial_limit : integer  := 12000;
  constant ramp_unsigned_partial_max : integer  := 45000;
  constant ramp_signed_full_min      : integer  := 30000;
  constant ramp_unsigned_full_min    : integer  := 60000;

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

    report "Simulation finished. Check waveform!";
    wait;

  end process;

-- process(clk)
-- begin
--     if rising_edge(clk) and reset = '0' then
--         report "Sine: " & real'image(to_real(sine_out)) &
--                " → Scaled: " & real'image(to_real(scaled_out));
--     end if;
-- end process;

end architecture tb;
