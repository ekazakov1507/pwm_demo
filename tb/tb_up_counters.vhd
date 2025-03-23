library ieee;
use ieee.std_logic_1164.ALL;

entity tb_up_counter is
--  Port ( );
end tb_up_counter;

architecture tb of tb_up_counters is

	signal clk : std_logic := '0';
	signal rst : std_logic := '1';
	signal enable : std_logic := '1';
	signal cnt : std_logic_vector(6 downto 0);

component up_counter_unsigned
    generic (
        R : integer := 7
    );
	port ( 
        clk : in std_logic;
		rst : in std_logic;
		enable : in std_logic;
        cnt : out std_logic_vector
		);
end component up_counter_unsigned;

begin

	 stand : up_counter
     port map (
        clk => clk,
   		res => res,
        cnt => cnt
      );

    -- res <= not res after 1 us;
    clk <= not clk after 4 ns; -- 125 MHz

end tb;