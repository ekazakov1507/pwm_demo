
library ieee;
  use ieee.std_logic_1164.all;

entity sine_gen_simple is
  generic (
    wave_length              : positive := 1024;
    bit_width                : positive := 16;
    data_type                : string   := "UNSIGNED";
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
    clk         : in    std_logic;
    reset       : in    std_logic;
    enable      : in    std_logic := '1';
    sample_ce   : in    std_logic := '1';
    output_valid : out  std_logic;
    output_data : out   std_logic_vector(bit_width - 1 downto 0)
  );
end entity sine_gen_simple;

architecture src of sine_gen_simple is
begin

  data_type_valid : assert (data_type = "SIGNED" or data_type = "signed" or
                            data_type = "UNSIGNED" or data_type = "unsigned")
    report "sine_gen_simple: data_type must be SIGNED or UNSIGNED"
    severity failure;

  set_signed : if (data_type = "SIGNED" or data_type = "signed") generate

    source : entity work.sine_gen_signed
      generic map (
        wave_length              => wave_length,
        bit_width                => bit_width,
        ramp_enable              => ramp_enable,
        ramp_length              => ramp_length,
        pulse_enable             => pulse_enable,
        pulse_period_cycles      => pulse_period_cycles,
        pulse_start_delay_cycles => pulse_start_delay_cycles,
        pulse_duration_cycles    => pulse_duration_cycles,
        pulse_front_cycles       => pulse_front_cycles,
        pulse_fall_cycles        => pulse_fall_cycles
      )
      port map (
        clk          => clk,
        reset        => reset,
        enable       => enable,
        sample_ce    => sample_ce,
        output_valid => output_valid,
        output_data  => output_data
      );

  end generate set_signed;

  set_unsigned : if (data_type = "UNSIGNED" or data_type = "unsigned") generate

    source : entity work.sine_gen_unsigned
      generic map (
        wave_length              => wave_length,
        bit_width                => bit_width,
        ramp_enable              => ramp_enable,
        ramp_length              => ramp_length,
        pulse_enable             => pulse_enable,
        pulse_period_cycles      => pulse_period_cycles,
        pulse_start_delay_cycles => pulse_start_delay_cycles,
        pulse_duration_cycles    => pulse_duration_cycles,
        pulse_front_cycles       => pulse_front_cycles,
        pulse_fall_cycles        => pulse_fall_cycles
      )
      port map (
        clk          => clk,
        reset        => reset,
        enable       => enable,
        sample_ce    => sample_ce,
        output_valid => output_valid,
        output_data  => output_data
      );

  end generate set_unsigned;

end architecture src;
