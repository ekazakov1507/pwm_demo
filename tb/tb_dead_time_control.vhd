library ieee;
use ieee.std_logic_1164.all;

entity tb_dead_time_control is
--  Port ( );
end tb_dead_time_control;

architecture tb of tb_dead_time_control is

	signal clk : std_logic := '0';
	signal rst : std_logic := '1';
	signal pwm_in : std_logic := '0';
	signal pwm_in_n : std_logic := '0';
	signal pwm_out : std_logic := '0';
	signal pwm_out_n : std_logic := '0';

begin

	 stand : entity work.dead_time_control
     port map (
        clk => clk,
        rst => rst,
        pwm_set => pwm_in,
        pwm_reset => pwm_in_n,
        pwm_chA => pwm_out,
        pwm_chB => pwm_out_n
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