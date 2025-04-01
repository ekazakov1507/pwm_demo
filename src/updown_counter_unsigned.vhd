library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity updown_counter_unsigned is
	generic(
		R : integer := 7; -- Resolution
		INIT : integer := 0;
		START : integer := 0; -- 0
		STOP : integer := 127; -- 2^R-1
		STEP : integer := 1
	);
	port(
		clk : in std_logic;
		rst : in std_logic;
		enable : in std_logic;
		cnt : out std_logic_vector(R-1 downto 0)
		);
end updown_counter_unsigned;

architecture src of updown_counter_unsigned is
	
begin

	up_down_counter : process(clk, rst)
			constant counter_min : unsigned(R-1 downto 0) := to_unsigned(START, R);-- (0 => '1', others => '0');
			constant counter_max : unsigned(R-1 downto 0) := to_unsigned(STOP, R);-- (0 => '0', others => '1');
			constant counter_step : unsigned(R-1 downto 0) := to_unsigned(STEP, R); -- (0 => '1', others => '0');
            variable counter_updown : std_logic := '0';
            variable counter : unsigned(R-1 downto 0) := to_unsigned(INIT, R);
		begin
			if rising_edge(clk) then 
				if rst = '0' then
					counter := (others => '0');
					counter_updown := '1';
				elsif rst = '1' and enable = '1' then 
					if counter_updown = '1' and counter < counter_max then
						counter := counter + counter_step;
					elsif counter_updown = '0' and counter > counter_min then
						counter := counter - counter_step;
					elsif counter = counter_min then
						counter_updown := '1';
						counter := counter + counter_step;
					elsif counter = counter_max then
						counter_updown := '0';
						counter := counter - counter_step;
					end if;
				end if;
				cnt <= std_logic_vector(counter);
			end if;
	end process;

end src;