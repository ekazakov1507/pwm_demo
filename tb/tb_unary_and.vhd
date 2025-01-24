library ieee;
use ieee.std_logic_1164.ALL;

entity tb_unary_and is
--  Port ( );
end tb_unary_and;

architecture tb of tb_unary_ANd is

	signal uand_in : std_logic_vector(8-1 downto 0) := (others => '0');
    signal uand_out : std_logic := '0';

    component unary_AND
        generic(
            N: positive := 8
        );
        port(
            inp: in std_logic_vector(N - 1 downto 0);
            outp: out std_logic
        );
    end component;


begin

    up_cnt_stand : unary_AND
        generic map (
            N => 8
        )
        port map (
   		    inp => uand_in,
            outp => uand_out
        );

    test_p : process
    begin
        wait for 20 ns;
        uand_in <= b"00000000";
        wait for 20 ns;
        uand_in <= b"00000001";
        wait for 20 ns;
        uand_in <= b"01001010";
        wait for 20 ns;
        uand_in <= b"11111111";
        wait for 20 ns;
        uand_in <= b"11111101";
    end process;

end tb;