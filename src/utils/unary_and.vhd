library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity unary_AND IS
    generic(
        N: positive := 8
    );
    port(
        inp: in std_logic_vector(N - 1 downto 0);
        outp: out std_logic
    );
end entity;

architecture src of unary_AND is

    signal temp: std_logic_vector(N-1 downto 0);


begin

    temp(0) <= inp(0);
    gen: for i in 1 to N-1 generate
        temp(i) <= temp(i-1) and inp(i);
    end generate; 
    outp <= temp(N-1); 

end src;
