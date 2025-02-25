library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity updown_counter is
	generic(
		R : integer := 7
	);
	port(
		clk : in std_logic;
		res : in std_logic;
		cnt : out std_logic_vector(R-1 downto 0)
		);
end updown_counter;

architecture src of updown_counter is
	
begin

	up_down_counter : process(clk, res)
			constant counter_min : unsigned(R-1 downto 0) := (0 => '1', others => '0');
			constant counter_max : unsigned(R-1 downto 0) := (0 => '0', others => '1');
			constant counter_step : unsigned(R-1 downto 0) := (0 => '1', others => '0');
            variable counter_updown : std_logic := '0';
            variable counter : unsigned(R-1 downto 0) := (others => '0');
		begin
			if res = '0' then
				counter := (others => '0');
				counter_updown := '1';
			elsif rising_edge(clk) then 
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

	end process;

end src;