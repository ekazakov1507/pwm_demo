library ieee;
use ieee.std_logic_1164.ALL;

entity tb_vector_and is
--  Port ( );
end tb_vector_and;

architecture tb of tb_vector_and is
    constant R : integer := 4;

    signal input_vector : std_logic_vector(R-1 downto 0) := (others => '0');
    signal result : std_logic;


begin
    uut: entity work.vector_and
        Generic Map (
            R => R
        )
        Port Map (
            input_vector => input_vector,
            result => result
        );

    stim_proc: process
    begin
        input_vector <= "0000"; wait for 10 ns;
        assert result = '0' report "Test case 1 failed" severity error;

        input_vector <= "1111"; wait for 10 ns;
        assert result = '1' report "Test case 2 failed" severity error;

        input_vector <= "1011"; wait for 10 ns;
        assert result = '0' report "Test case 3 failed" severity error;

        input_vector <= "0100"; wait for 10 ns;
        assert result = '0' report "Test case 4 failed" severity error;

        report "All test cases passed" severity note;
        wait;
    end process;
end tb;