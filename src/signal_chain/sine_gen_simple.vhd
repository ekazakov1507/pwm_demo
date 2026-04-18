
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity sine_gen_simple is
  generic (
    wave_length : positive := 1024;
    bit_width   : positive := 16;
    data_type   : string   := "UNSIGNED"
  );
  port (
    clk         : in    std_logic;
    reset       : in    std_logic;
    output_data : out   std_logic_vector(bit_width - 1 downto 0)
  );
end entity sine_gen_simple;

architecture src of sine_gen_simple is

  type wave_array is array (0 to WAVE_LENGTH - 1) of signed(BIT_WIDTH - 1 downto 0);

  function generate_sine_wave return wave_array is

    variable wave       : wave_array;
    variable angle_step : real := 2.0 * MATH_PI / real(WAVE_LENGTH);
    variable theta      : real;
    variable sin_val    : real;
    variable scaled     : real;
    variable int_val    : integer;

  begin

    for i in 0 to WAVE_LENGTH - 1 loop

      theta   := real(i) * angle_step;
      sin_val := sin(theta);

      if (DATA_TYPE = "SIGNED" or DATA_TYPE = "signed") then
        scaled  := sin_val * real(2 ** (BIT_WIDTH - 1) - 1);
        int_val := integer(scaled);
        wave(i) := to_signed(int_val, BIT_WIDTH);
      else
        scaled  := (sin_val + 1.0) / 2.0;
        int_val := integer(scaled * real(2 ** BIT_WIDTH - 1));
        wave(i) := to_signed(int_val, BIT_WIDTH);
      end if;

    end loop;

    return wave;

  end function generate_sine_wave;

  constant sine_wave : wave_array := generate_sine_wave;

  signal index : integer range 0 to wave_length - 1 := 0;

begin

  process (clk, reset) is
  begin

    if (reset = '1') then
      index       <= 0;
      output_data <= (others => '0');
    elsif rising_edge(clk) then
      if (data_type = "SIGNED" or data_type = "signed") then
        output_data <= std_logic_vector(SINE_WAVE(index));
      else
        output_data <= std_logic_vector(
                                        unsigned(SINE_WAVE(index))
                                      );
      end if;

      if (index = wave_length - 1) then
        index <= 0;
      else
        index <= index + 1;
      end if;
    end if;

  end process;

end architecture src;
