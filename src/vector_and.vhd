library ieee;
use ieee.std_logic_1164.all;

entity vector_and is
	generic(
		R : integer := 7
	);
    port (
        input_vector : in std_logic_vector(R-1 downto 0);
        result : out std_logic
    );
end vector_and;

architecture src of vector_and is
begin
    gen_and: process(input_vector)
        variable temp : std_logic := '1';
    begin
        for i in input_vector'range loop
            temp := temp and input_vector(i);
        end loop;
        result <= temp;
        temp := '1';
    end process;
end src;