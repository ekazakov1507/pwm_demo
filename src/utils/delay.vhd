library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.ALL;
use ieee.std_logic_arith.all;

entity delay is
	generic(
		N : integer := 8
	);
	port(
		-- clk : in std_logic;
		-- rst : in std_logic;
        input : in std_logic;
		output : out std_logic
	);
end delay;

architecture src of delay is

    signal dreg : std_logic_vector(N-1 downto 0) := (others => '0');


begin

    delay_line : process(input, dreg)
    begin
        dreg(0) <= input;
        for i in 1 to N-1 loop
            dreg(i) <= dreg(i-1);
        end loop;
        output <= dreg(N-1);
    end process;


    -- delay_line : process(clk, rst, input, dreg)
    -- begin
    --     if rising_edge(clk) then
    --         if rst = '1' then
    --             dreg <= (others => '0');
    --         else
    --             dreg(0) <= input;
    --             for i in 1 to N-1 loop
    --                 dreg(i) <= dreg(i-1);
    --             end loop;
    --             output <= dreg(N-1);
    --         end if;
    --     end if;
    -- end process;

end src;