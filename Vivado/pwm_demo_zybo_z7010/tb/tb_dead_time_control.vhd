library ieee;
use ieee.std_logic_1164.ALL;

entity tb_dead_time_control is
--  Port ( );
end tb_dead_time_control;

architecture tb of tb_dead_time_control is

	signal clk : std_logic := '0';
	signal res : std_logic := '1';
	signal pwm_in : std_logic := '0';
	signal pwm_in_n : std_logic := '0';
	signal pwm_out : std_logic := '0';
	signal pwm_out_n : std_logic := '0';

component dead_time_control is
 	generic(
		DEAD_TIME : integer := 4
	);
	port(
		clk : in std_logic;
		res : in std_logic;
		pwm_in : in std_logic;
		pwm_in_n : in std_logic;
		pwm_out : out std_logic;
		pwm_out_n : out std_logic
		);
end component dead_time_control;

begin

	 stand : dead_time_control
     port map (
        clk => clk,
   		res => res,
        pwm_in => pwm_in,
        pwm_in_n => pwm_in_n,
        pwm_out => pwm_out,
        pwm_out_n => pwm_out_n
      );

    pwm_signs : process
    begin 
        pwm_in <= '0'; pwm_in_n <= '1'; wait for 16 ns;
        pwm_in <= '1'; pwm_in_n <= '0'; wait for 16 ns;
        pwm_in <= '1'; pwm_in_n <= '0'; wait for 16 ns;
        pwm_in <= '0'; pwm_in_n <= '1'; wait for 16 ns;
        pwm_in <= '0'; pwm_in_n <= '1'; wait for 16 ns;
        pwm_in <= '1'; pwm_in_n <= '0'; wait for 16 ns;
        pwm_in <= '0'; pwm_in_n <= '1'; wait for 16 ns;
        pwm_in <= '0'; pwm_in_n <= '1'; wait for 16 ns;
    end process;
    
    -- res <= not res after 1 us;
    clk <= not clk after 4 ns; -- 125 MHz

end tb;