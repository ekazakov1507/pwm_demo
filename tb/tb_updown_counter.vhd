library ieee;
use ieee.std_logic_1164.ALL;

entity tb_updown_counter is
--  Port ( );
end tb_updown_counter;

architecture tb of tb_updown_counter is

	signal clk : std_logic := '0';
	signal rst : std_logic := '0';
	signal updwcnt : std_logic_vector(8 - 1 downto 0) := (others => '0');

    component updown_counter
        generic(
            N : integer;
            START : integer;
            STOP : integer;
            STEP : integer 
        ); 
        port( 
            clk : in std_logic;
            rst : in std_logic;
            cnt : out std_logic_vector(N - 1 downto 0)
            );
    end component updown_counter;


begin

    updw_cnt_stand : updown_counter
        generic map (
            N => 8,
            START => 0,
            STOP => 254,
            STEP => 1
        )
        port map (
   		    clk => clk,
            rst => rst,
   		    cnt => updwcnt 
            );

    clk <= not clk after 10 ns; -- 50 MHz for Microhpase z7lite
    rst <= not rst after 11 us;

end tb;