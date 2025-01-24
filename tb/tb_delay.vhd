library ieee;
use ieee.std_logic_1164.ALL;

entity tb_delay is
--  Port ( );
end tb_delay;

architecture tb of tb_delay is

	-- signal clk : std_logic := '0';
	-- signal rst : std_logic := '0';
	signal d_in : std_logic := '0';
	signal d_out : std_logic := '0';

    component delay
        generic(
            N : integer := 8
        );
        port(
            -- clk : in std_logic;
            -- rst : in std_logic;
            input : in std_logic;
            output : out std_logic
        );
    end component delay;


begin

    delay_stand : delay 
        generic map (
            N => 8
        )
        port map (
   		    -- clk => clk,
            -- rst => rst,
   		    input => d_in,
            output => d_out
        );

    -- clk <= not clk after 10 ns; -- 50 MHz for Microhpase z7lite
    -- rst <= not rst after 1000 ns;

    test_p : process
    begin
        wait for 20 ns;
        d_in <= '0';
        wait for 20 ns;
        d_in <= '0';
        wait for 20 ns;
        d_in <= '0';
        wait for 20 ns;
        d_in <= '1';
        wait for 20 ns;
        d_in <= '1';
        wait for 20 ns;
        d_in <= '0';
        wait for 20 ns;
        d_in <= '1';
        wait for 20 ns;
        d_in <= '0';
        wait for 20 ns;
        d_in <= '0';
        wait for 20 ns;
        d_in <= '1';
        wait for 20 ns;
        d_in <= '1';
        wait for 20 ns;
        d_in <= '0';
    end process;

end tb;