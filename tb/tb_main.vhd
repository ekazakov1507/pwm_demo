library ieee;
  use ieee.std_logic_1164.all;

entity tb_main is
--  Port ( );
end entity tb_main;

architecture tb of tb_main is

  constant clk_period : time := 8 ns;

  constant num_channels : integer := 4;

  signal sys_clk : std_logic := '0';
  -- signal rst     : std_logic                                 := '0';

  signal sys_pwm   : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal sys_pwm_n : std_logic_vector(num_channels - 1 downto 0) := (others => '0');

begin

  main_pwm_demo : entity work.main
    generic map (
      num_channels => num_channels
    )
    port map (
      sys_clk   => sys_clk,
      sys_pwm   => sys_pwm,
      sys_pwm_n => sys_pwm_n
    );

  sys_clk <= not sys_clk after clk_period / 2;

end architecture tb;

