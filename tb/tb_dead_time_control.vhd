library ieee;
use ieee.std_logic_1164.all;

entity tb_dead_time_control is
--  Port ( );
end tb_dead_time_control;

architecture tb of tb_dead_time_control is

	signal clk : std_logic := '0';
	signal rst : std_logic := '1';
	signal pwm_set : std_logic := '0';
	signal pwm_reset : std_logic := '0';
	signal pwm_chA : std_logic := '0';
	signal pwm_chB : std_logic := '0';

begin

	 stand : entity work.dead_time_control
     port map (
        clk => clk,
        rst => rst,
        pwm_set => pwm_set,
        pwm_reset => pwm_reset,
        pwm_chA => pwm_chA,
        pwm_chB => pwm_chB
      );

    pwm_signs : process
    begin 
        pwm_set <= '0'; pwm_reset <= '0'; wait for 16 ns;
        pwm_set <= '0'; pwm_reset <= '0'; wait for 16 ns;
        pwm_set <= '1'; pwm_reset <= '0'; wait for 16 ns;
        pwm_set <= '0'; pwm_reset <= '0'; wait for 16 ns;
        pwm_set <= '0'; pwm_reset <= '0'; wait for 16 ns;
        pwm_set <= '0'; pwm_reset <= '0'; wait for 16 ns;
        pwm_set <= '0'; pwm_reset <= '1'; wait for 16 ns;
        pwm_set <= '0'; pwm_reset <= '0'; wait for 16 ns;
    end process;
    
    -- res <= not res after 1 us;
    clk <= not clk after 4 ns; -- 125 MHz

end tb;