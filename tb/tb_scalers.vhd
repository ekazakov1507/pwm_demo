library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity tb_scalers is
end entity tb_scalers;

architecture tb of tb_scalers is

  signal clk                   : std_logic := '0';
  signal reset                 : std_logic := '1';
  signal sine_out_unsigned     : std_logic_vector(15 downto 0);
  signal sine_out_signed       : std_logic_vector(15 downto 0);
  signal scaled_out_unsigned : std_logic_vector(15 downto 0);
  signal scaled_out_signed   : std_logic_vector(15 downto 0);

  constant clk_period : time := 10 ns;

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

  clk <= not clk after clk_period / 2;

  process is
  begin

    report "Starting simple sine (math_real) + scaler simulation";
    wait for 40 ns;
    reset <= '0';

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
