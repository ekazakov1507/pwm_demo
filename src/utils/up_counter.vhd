library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.ALL;
use ieee.std_logic_arith.all;

entity up_counter is
	generic(
		N : integer := 16;
		START : integer := 0;
		STOP : integer := 2**8 - 1;
		STEP : integer := 1
	);
	port(
		clk : in std_logic;
		rst : in std_logic;
		cnt : out std_logic_vector(N - 1 downto 0)
	);
end up_counter;

architecture src of up_counter is

	signal s_start : std_logic_vector(N - 1 downto 0) := conv_std_logic_vector(START, N);
	signal s_stop : std_logic_vector(N - 1 downto 0) := conv_std_logic_vector(STOP, N);
	signal s_step : std_logic_vector(N - 1 downto 0) := conv_std_logic_vector(STEP, N);

	signal tmp : std_logic_vector(N - 1 downto 0) := conv_std_logic_vector(START, N);


begin

	up_cnt : process(clk, rst, tmp)
		begin
		if rising_edge(clk) then 
			if rst = '1' then
				tmp <= s_start;
			elsif rst = '0' then
				if tmp < s_stop then 
					tmp <= tmp + s_step;
				elsif tmp >= s_stop then 
					tmp <= s_start;
				end if;
			end if;
		end if;
	end process;

	cnt <= tmp;

end src; 