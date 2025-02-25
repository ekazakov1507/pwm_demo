library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity pwm_c is
	generic(
		R : integer := 7
	);
	port(
		clk : in std_logic;
		res : in std_logic;
		input_wave : in std_logic_vector(R-1 downto 0);
		pwm : out std_logic;
		pwm_n : out std_logic
		);
end pwm_c;

architecture src of pwm_c is
	
	signal counter : std_logic_vector(R-1 downto 0) := (others => '0');

	component updown_counter is
		generic (
			R : integer
		);
		port (
			clk : in std_logic;
			res : in std_logic;
			cnt : out std_logic_vector
		);
	end component updown_counter;

begin

	cnt : updown_counter
		generic map (
			R => R
		)
		port map (
			clk => clk,
			res => res,
			cnt => counter
		);

	triangle_pwmmod : process(clk, res, counter, input_wave)
		begin 
			if res = '0' then 
				pwm <= '0';
				pwm_n <= '1';
				-- counter <= b"0000000";
			elsif rising_edge(clk) then
				if counter < input_wave then
					pwm <= '1';
					pwm_n <= '0';
				else
					pwm <= '0';
					pwm_n <= '1';
				end if;
			end if;
	end process;

end src;