library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.ALL;
use ieee.std_logic_arith.all;

entity updown_counter is
	generic(
		N : integer := 16;
		START : integer := 0;
		STOP : integer := 2**16 - 1;
		STEP : integer := 1
	);
	port(
		clk : in std_logic;
		rst : in std_logic;
		cnt : out std_logic_vector(N - 1 downto 0)
	);
end updown_counter;

architecture src of updown_counter is

	signal s_start : std_logic_vector(N - 1 downto 0) := conv_std_logic_vector(START, N);
	signal s_stop : std_logic_vector(N - 1 downto 0) := conv_std_logic_vector(STOP, N);
	signal s_step : std_logic_vector(N - 1 downto 0) := conv_std_logic_vector(STEP, N);

	signal tmp : std_logic_vector(N - 1 downto 0) := conv_std_logic_vector(START, N);

	signal updown : std_logic := '0';
    
begin

	updown_cnt : process(clk, rst, updown, tmp, s_start, s_step, s_stop) 
		begin
        if rising_edge(clk) then 
            if rst = '0' then 
                if updown = '1' and tmp < s_stop then
                    tmp <= tmp + s_step;
                elsif updown = '0' and tmp > s_start then
                    tmp <= tmp - s_step;
                elsif tmp = s_start then
                    updown <= '1';
                    tmp <= tmp + s_step;
                elsif tmp = s_stop then
                    updown <= '0';
                    tmp <= tmp - s_step;
                end if;
            elsif rst = '1' then 
                tmp <= s_start;
                updown <= '1';
            end if;
		end if;
	end process;
    
    cnt <= tmp;

end src;