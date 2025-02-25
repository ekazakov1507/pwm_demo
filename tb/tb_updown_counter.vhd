library ieee;
use ieee.std_logic_1164.ALL;

entity tb_updown_counter is
--  Port ( );
end tb_updown_counter;

architecture tb of tb_updown_counter is

	signal clk : std_logic := '0';
	signal res : std_logic := '1';
	signal cnt : std_logic_vector(6 downto 0);

component updown_counter
    generic (
        R : integer := 7
    );
	port ( 
        clk : in std_logic;
        res : in std_logic;
        cnt : out std_logic_vector
		);
end component updown_counter;

begin

	 stand : updown_counter
     port map (
        clk => clk,
   		res => res,
        cnt => cnt
      );

    -- res <= not res after 1 us;
    clk <= not clk after 4 ns; -- 125 MHz

end tb;