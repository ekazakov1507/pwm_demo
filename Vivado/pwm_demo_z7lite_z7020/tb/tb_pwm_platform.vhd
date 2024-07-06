library ieee;
use ieee.std_logic_1164.ALL;

entity tb_pwm_platform is
--  Port ( );
end tb_pwm_platform;

architecture tb of tb_pwm_platform is

	signal clk : std_logic := '0';
	signal resolution_button : std_logic := '0';
	signal pwm_channels : std_logic_vector(1 downto 0);

component pwm_platform
	port ( 
			sys_clk : in std_logic;
			sys_resolution_button : in std_logic;
			sys_pwm_channels : out std_logic_vector(1 downto 0)
		);
end component pwm_platform;

begin

	 stand : pwm_platform
     port map (
   		sys_clk => clk,
   		sys_resolution_button => resolution_button,
   		sys_pwm_channels => pwm_channels
      );

    -- clk <= not clk after 4 ns; -- 125 MHz for Zybo z7
    clk <= not clk after 10 ns; -- 50 MHz for Microhpase z7lite

    test_pwm_resolution_button : process
     	begin
     		wait for 1 us;
     		resolution_button <= '1';
     		wait for 1 us;
     		resolution_button <= '0';
     		wait for 100 us;
     		resolution_button <= '1';
     		wait for 1 us;
     		resolution_button <= '0';
     		wait for 100 us;
     		resolution_button <= '1';
     		wait for 1 us;
     		resolution_button <= '0';
     		wait for 100 us;
     		resolution_button <= '1';
     		wait for 1 us;
     		resolution_button <= '0';
     		wait for 100 us;
     		resolution_button <= '1';
     		wait for 1 us;
     		resolution_button <= '0';
     		wait for 100 us;
     		resolution_button <= '1';
     		wait for 1 us;
     		resolution_button <= '0';
     		wait for 100 us;
     		resolution_button <= '1';
     		wait for 1 us;
     		resolution_button <= '0';
     		wait for 100 us;
     		resolution_button <= '1';
     		wait for 1 us;
     		resolution_button <= '0';
     		wait;
    end process;

end tb;
