library ieee;
  use ieee.std_logic_1164.all;

entity tb_pwm_platform is
--  Port ( );
end entity tb_pwm_platform;

architecture tb of tb_pwm_platform is

  signal clk          : std_logic := '0';
  signal pwm_channels : std_logic_vector(3 downto 0);

  component pwm_platform is
    port (
      sys_clk          : in    std_logic;
      sys_pwm_channels : out   std_logic_vector(3 downto 0)
    );
  end component pwm_platform;

begin

  stand : component pwm_platform
    port map (
      sys_clk          => clk,
      sys_pwm_channels => pwm_channels
    );

  -- clk <= not clk after 5 ns; -- 100 MHz
  clk <= not clk after 4 ns; -- 125 MHz

end architecture tb;
