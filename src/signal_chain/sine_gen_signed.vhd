library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity sine_gen_signed is
  generic (
    wave_length              : positive := 1024;
    bit_width                : positive := 16;
    ramp_enable              : boolean  := false;
    ramp_length              : natural  := 0;
    pulse_enable             : boolean  := false;
    pulse_period_cycles      : positive := 1024;
    pulse_start_delay_cycles : natural  := 0;
    pulse_duration_cycles    : positive := 1024;
    pulse_front_cycles       : natural  := 0;
    pulse_fall_cycles        : natural  := 0
  );
  port (
    clk          : in    std_logic;
    reset        : in    std_logic;
    enable       : in    std_logic := '1';
    sample_ce    : in    std_logic := '1';
    output_valid : out   std_logic;
    output_data  : out   std_logic_vector(bit_width - 1 downto 0)
  );
end entity sine_gen_signed;

architecture src of sine_gen_signed is

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
      scaled  := sin_val * real(2 ** (BIT_WIDTH - 1) - 1);
      int_val := integer(scaled);
      wave(i) := to_signed(int_val, BIT_WIDTH);

    end loop;

    return wave;

  end function generate_sine_wave;

  constant sine_wave : wave_array := generate_sine_wave;

  function get_effective_ramp_length return positive is
  begin

    if (ramp_length = 0) then
      return WAVE_LENGTH;
    end if;

    return ramp_length;

  end function get_effective_ramp_length;

  constant effective_ramp_length : positive := get_effective_ramp_length;

  function ramp_sample (
    sample     : signed(BIT_WIDTH - 1 downto 0);
    ramp_count : natural
  ) return signed is
    variable scaled : integer := 0;
  begin

    if ((not ramp_enable) or (ramp_count >= effective_ramp_length)) then
      return sample;
    end if;

    scaled := (to_integer(sample) * integer(ramp_count)) / integer(effective_ramp_length);

    return to_signed(scaled, BIT_WIDTH);

  end function ramp_sample;

  function scale_sample (
    sample      : signed(BIT_WIDTH - 1 downto 0);
    numerator   : natural;
    denominator : positive
  ) return signed is
    variable scaled : integer := 0;
  begin

    if (numerator = 0) then
      return to_signed(0, BIT_WIDTH);
    elsif (numerator >= denominator) then
      return sample;
    end if;

    scaled := (to_integer(sample) * integer(numerator)) / integer(denominator);

    return to_signed(scaled, BIT_WIDTH);

  end function scale_sample;

  function pulse_count_active (
    pulse_count : natural
  ) return boolean is
  begin

    return (pulse_count >= pulse_start_delay_cycles) and
           (pulse_count < pulse_start_delay_cycles + pulse_duration_cycles);

  end function pulse_count_active;

  function pulse_sample (
    sample      : signed(BIT_WIDTH - 1 downto 0);
    pulse_count : natural
  ) return signed is
    variable active_pos : natural := 0;
    variable fall_pos   : natural := 0;
  begin

    if (not pulse_count_active(pulse_count)) then
      return to_signed(0, BIT_WIDTH);
    end if;

    active_pos := pulse_count - pulse_start_delay_cycles;

    if ((pulse_front_cycles > 0) and (active_pos < pulse_front_cycles)) then
      return scale_sample(sample, active_pos, pulse_front_cycles);
    elsif ((pulse_fall_cycles > 0) and
           (active_pos >= pulse_duration_cycles - pulse_fall_cycles)) then
      fall_pos := active_pos - (pulse_duration_cycles - pulse_fall_cycles);
      return scale_sample(sample, pulse_fall_cycles - fall_pos, pulse_fall_cycles);
    end if;

    return sample;

  end function pulse_sample;

  signal index       : integer range 0 to wave_length - 1          := 0;
  signal ramp_count  : natural range 0 to effective_ramp_length    := 0;
  signal pulse_count : natural range 0 to pulse_period_cycles - 1  := 0;

begin

  pulse_timing_valid : assert ((not pulse_enable) or
                               (pulse_start_delay_cycles + pulse_duration_cycles <= pulse_period_cycles))
    report "sine_gen_signed: pulse start delay plus duration must fit inside pulse period"
    severity failure;

  pulse_flat_top_valid : assert ((not pulse_enable) or
                                 (pulse_front_cycles + pulse_fall_cycles < pulse_duration_cycles))
    report "sine_gen_signed: pulse duration must leave at least one flat-top cycle"
    severity failure;

  process (clk, reset) is
    variable sample : signed(BIT_WIDTH - 1 downto 0);
  begin

    if (reset = '1') then
      index        <= 0;
      ramp_count   <= 0;
      pulse_count  <= 0;
      output_valid <= '0';
      output_data  <= (others => '0');
    elsif rising_edge(clk) then
      output_valid <= '0';

      if ((enable = '1') and (sample_ce = '1')) then
        output_valid <= '1';
        sample       := SINE_WAVE(index);

        if (pulse_enable) then
          output_data <= std_logic_vector(pulse_sample(sample, pulse_count));

          if (pulse_count = pulse_period_cycles - 1) then
            pulse_count <= 0;
          else
            pulse_count <= pulse_count + 1;
          end if;

          if (pulse_count_active(pulse_count)) then
            if (index = wave_length - 1) then
              index <= 0;
            else
              index <= index + 1;
            end if;
          else
            index <= 0;
          end if;
        else
          output_data <= std_logic_vector(ramp_sample(sample, ramp_count));

          if (ramp_enable and (ramp_count < effective_ramp_length)) then
            ramp_count <= ramp_count + 1;
          end if;

          if (index = wave_length - 1) then
            index <= 0;
          else
            index <= index + 1;
          end if;
        end if;
      end if;
    end if;

  end process;

end architecture src;
