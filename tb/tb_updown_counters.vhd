library ieee;
use ieee.std_logic_1164.ALL;

entity tb_updown_counter_unsigned is
--  Port ( );
end tb_updown_counter_unsigned;

architecture tb of tb_updown_counters is

	signal clk : std_logic := '0';
	signal rst : std_logic := '1';
	signal enable : std_logic := '1';
	signal cnt_unsigned : std_logic_vector(6 downto 0);
	signal cnt_signed : std_logic_vector(6 downto 0);

component updown_counter_unsigned
    generic (
        R : integer := 7
    );
	port ( 
        clk : in std_logic;
        rst : in std_logic;
        enable : in std_logic;
        cnt : out std_logic_vector
		);
end component updown_counter_unsigned;

component updown_counter_signed
    generic (
        R : integer := 7
    );
	port ( 
        clk : in std_logic;
        rst : in std_logic;
        enable : in std_logic;
        cnt : out std_logic_vector
		);
end component updown_counter_signed;

begin

    unsigned_stand : updown_counter_unsigned
    port map (
        clk => clk,
   		rst => rst,
   		enable => enable,
        cnt => cnt_unsigned
    );

    signed_stand : updown_counter_signed
    port map (
        clk => clk,
   		rst => rst,
   		enable => enable,
        cnt => cnt_signed
    );

    -- res <= not res after 1 us;
    clk <= not clk after 4 ns; -- 125 MHz

end tb;