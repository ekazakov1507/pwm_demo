library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity up_counter_signed is
	generic(
		R : integer := 7; -- Resolution
		START : integer := -64; -- -1 * 2^R / 2
		STOP : integer := 63; -- +1 * 2^R /2 - 1
		STEP : integer := 1
	);
	port(
		clk : in std_logic;
		rst : in std_logic;
		enable : in std_logic;
		cnt : out std_logic_vector(R-1 downto 0)
		);
end up_counter_signed;

architecture src of up_counter_signed is
	
begin

	up_down_counter : process(clk, rst)
			constant counter_min : signed(R-1 downto 0) := to_signed(START, R);-- (0 => '1', others => '0');
			constant counter_max : signed(R-1 downto 0) := to_signed(STOP, R);-- (0 => '0', others => '1');
			constant counter_step : signed(R-1 downto 0) := to_signed(STEP, R); -- (0 => '1', others => '0');
            variable counter_updown : std_logic := '0';
            variable counter : signed(R-1 downto 0) := counter_min;
		begin
			if rst = '0' then
				counter := (others => '0');
				counter_updown := '1';
			elsif rising_edge(clk) and enable = '1' then 
				if counter < counter_max then
					counter := counter + counter_step;
				elsif counter = counter_max then
					counter := counter_min;
				end if;
			end if;

            cnt <= std_logic_vector(counter);

	end process;

end src;