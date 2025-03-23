library ieee;
use ieee.std_logic_1164.ALL;

entity tb_vector_and is
--  Port ( );
end tb_vector_and;

architecture tb of tb_vector_and is
    signal input_vector : std_logic_vector(7 downto 0) := (others => '0');
    signal result : std_logic;
begin
    uut: entity work.VectorAND
        Port Map (
            input_vector => input_vector,
            result => result
        );

    stim_proc: process
    begin
        input_vector <= "00000000"; wait for 10 ns;
        assert result = '0' report "Test case 1 failed" severity error;

        input_vector <= "11111111"; wait for 10 ns;
        assert result = '1' report "Test case 2 failed" severity error;

        input_vector <= "10101010"; wait for 10 ns;
        assert result = '0' report "Test case 3 failed" severity error;

        input_vector <= "11111110"; wait for 10 ns;
        assert result = '0' report "Test case 4 failed" severity error;

        report "All test cases passed" severity note;
        wait;
    end process;
end tb;