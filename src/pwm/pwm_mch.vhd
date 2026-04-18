library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.range_divider_pkg.get_chunk_end;
  use work.range_divider_pkg.value_flag_pair;

entity pwm_mch is
  generic (
    r               : integer   := 7;
    d               : integer   := 2;
    num_channels    : integer   := 2;
    input_data_type : string    := "SIGNED";
    ref_type        : string    := "SYMMETRICAL";
    output_mode     : string    := "COMPLEMENTARY";
    ref_step        : integer   := 1;
    ref_updwn       : std_logic := '1'
  );
  port (
    clk        : in    std_logic;
    rst        : in    std_logic;
    enable     : in    std_logic;
    input_wave : in    std_logic_vector(r - 1 downto 0);
    pwm        : out   std_logic_vector(num_channels - 1 downto 0);
    pwm_n      : out   std_logic_vector(num_channels - 1 downto 0)
  );
end entity pwm_mch;

architecture src of pwm_mch is

begin

  channels_gen : for i in 0 to num_channels - 1 generate

    constant chunk : value_flag_pair := get_chunk_end(
                                                      mode  => input_data_type,
                                                      r     => r,
                                                      index => i,
                                                      n     => num_channels);

  begin

    pwm_ich : entity work.pwm_1ch
      generic map (
        r               => r,
        d               => d,
        ref_type        => ref_type,
        output_mode     => output_mode,
        ref_init        => chunk.val,
        ref_step        => ref_step,
        ref_updwn       => chunk.flag,
        input_data_type => input_data_type
      )
      port map (
        clk        => clk,
        rst        => rst,
        enable     => enable,
        input_wave => input_wave,
        pwm        => pwm(i),
        pwm_n      => pwm_n(i)
      );

  end generate channels_gen;

end architecture src;
