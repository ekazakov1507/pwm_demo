library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity pwm_mch is
  generic (
    r               : integer := 7;             -- PWM resolution bits
    d               : integer := 2;             -- Num dead-time cycles
    num_channels    : integer := 2;
    ref_type        : string  := "SYMMETRICAL"; -- Symmetrical and Asymmetrical
    input_data_type : string  := "SIGNED";      -- signed or unsigned
    ref_init        : integer := 0;             -- TO DO integer_vector
    ref_step        : integer := 1
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

  signal cnt_out_test : std_logic_vector(r - 1 downto 0) := (others => '0');

begin

  channels_gen : for i in 0 to NUM_CHANNELS - 1 generate

    pwm_mod : entity work.pwm_1ch
      -- pwm_ch : pwm_1ch
      generic map (
        r               => r,
        d               => d,
        ref_type        => ref_type,
        ref_init        => ref_init,
        ref_step        => ref_step,
        input_data_type => input_data_type
      )
      port map (
        clk          => clk,
        rst          => rst,
        enable       => enable,
        input_wave   => input_wave,
        cnt_out_test => cnt_out_test,
        pwm          => pwm(i),
        pwm_n        => pwm_n(i)
      );

  end generate channels_gen;

end architecture src;
