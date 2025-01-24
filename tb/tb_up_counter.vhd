library ieee;
use ieee.std_logic_1164.ALL;

entity tb_up_counter is
--  Port ( );
end tb_up_counter;

architecture tb of tb_up_counter is

	signal clk : std_logic := '0';
	signal rst : std_logic := '0';
	signal upcnt : std_logic_vector(8 - 1 downto 0) := (others => '0');

    component up_counter
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
    end component up_counter;


begin

    up_cnt_stand : up_counter
        generic map (
            N => 8,
            START => 0,
            STOP => 254,
            STEP => 1
        )
        port map (
   		    clk => clk,
            rst => rst,
   		    cnt => upcnt 
            );

    clk <= not clk after 10 ns; -- 50 MHz for Microhpase z7lite
    rst <= not rst after 1000 ns;

end tb;