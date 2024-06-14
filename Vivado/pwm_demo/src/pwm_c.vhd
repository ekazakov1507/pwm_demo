library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.ALL;
use ieee.std_logic_arith.all;

entity pwm_c is
	port(
		enable : in std_logic;
		clk : in std_logic;
		modulated_wave : in std_logic_vector(15 downto 0);
		counter_step : in std_logic_vector(15 downto 0);
		counter_reset : in std_logic;
		pwm : out std_logic;
		pwm_i : out std_logic
		);
end pwm_c;

architecture src of pwm_c is
	
	signal counter : std_logic_vector(15 downto 0) := (others => '0');
	signal counter_updown : std_logic := '0';

begin

	leftside_pwmmod : process(clk, enable, counter, modulated_wave)
	begin 
		if rising_edge(clk) and enable = '1' then
				if counter < modulated_wave then
					pwm <= '1';
					pwm_i <= '0';
				else
					pwm <= '0';
					pwm_i <= '1';
				end if;
			end if;
	end process;

	up_down_counter : process(clk, enable, counter_step, counter_reset, counter_updown, counter)
		begin
		if rising_edge(clk) and enable = '1' then 
			if counter_reset = '1' then
				counter <= x"0000";
				counter_updown <= '1';
			elsif counter_updown = '1' and counter < x"ffff" then
				counter <= counter + counter_step;
			elsif counter_updown = '0' and counter > x"0000" then
				counter <= counter - counter_step;
			elsif counter = x"0000" then
				counter_updown <= '1';
				counter <= counter + counter_step;
			elsif counter = x"ffff" then
				counter_updown <= '0';
				counter <= counter - counter_step;
			end if;
		end if;
	end process;

end src;