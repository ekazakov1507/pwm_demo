library ieee;
use ieee.std_logic_1164.ALL;

entity tb_counters is
--  Port ( );
end tb_counters;

architecture tb of tb_counters is

    constant R : integer := 7; -- sse counters generic naps
	signal clk : std_logic := '0';
	signal rst : std_logic := '1';
	signal enable : std_logic := '1';
	signal cnt_up_unsigned : std_logic_vector(R-1 downto 0);
	signal cnt_up_signed : std_logic_vector(R-1 downto 0);
	signal cnt_upd_unsigned : std_logic_vector(R-1 downto 0);
	signal cnt_upd_signed : std_logic_vector(R-1 downto 0);

begin

    up_unsigned_stand : entity work.up_counter_unsigned
    port map (
        clk => clk,
   		rst => rst,
   		enable => enable,
        cnt => cnt_up_unsigned
    );

    up_signed_stand : entity work.up_counter_signed
    port map (
        clk => clk,
   		rst => rst,
   		enable => enable,
        cnt => cnt_up_signed
    );

    updown_unsigned_stand : entity work.updown_counter_unsigned
    port map (
        clk => clk,
   		rst => rst,
   		enable => enable,
        cnt => cnt_upd_unsigned
    );

    updown_signed_stand : entity work.updown_counter_signed
    port map (
        clk => clk,
   		rst => rst,
   		enable => enable,
        cnt => cnt_upd_signed
    );

    -- res <= not res after 1 us;
    clk <= not clk after 4 ns; -- 125 MHz

end tb;