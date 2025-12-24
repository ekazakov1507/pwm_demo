library ieee;
  use ieee.std_logic_1164.all;

entity tb_counters is
--  Port ( );
end entity tb_counters;

architecture tb of tb_counters is

  constant r                : integer   := 7; -- sse counters generic naps
  signal   clk              : std_logic := '0';
  signal   clk2             : std_logic := '0';
  signal   rst              : std_logic := '0';
  signal   enable           : std_logic := '1';
  signal   cnt_up_unsigned  : std_logic_vector(r - 1 downto 0);
  signal   cnt_up_signed    : std_logic_vector(r - 1 downto 0);
  signal   cnt_upd_unsigned : std_logic_vector(r - 1 downto 0);
  signal   cnt_upd_signed   : std_logic_vector(r - 1 downto 0);

begin

  up_unsigned_stand : entity work.up_counter_unsigned
    generic map (
      r     => R,
      init  => 0,
      start => 0,
      stop  => 2 ** R - 1,
      step  => 1
    )
    port map (
      clk    => clk,
      rst    => rst,
      enable => enable,
      cnt    => cnt_up_unsigned
    );

  up_signed_stand : entity work.up_counter_signed
    generic map (
      r     => R,
      init  => -2 ** R / 2,
      start => -2 ** R / 2,
      stop  => 2 ** R / 2 - 1,
      step  => 1
    )
    port map (
      clk    => clk,
      rst    => rst,
      enable => enable,
      cnt    => cnt_up_signed
    );

  updown_unsigned_stand : entity work.updown_counter_unsigned
    generic map (
      r     => R,
      init  => 0,
      start => 0,
      stop  => 2 ** R - 1,
      step  => 1
    )
    port map (
      clk    => clk2,
      rst    => rst,
      enable => enable,
      cnt    => cnt_upd_unsigned
    );

  updown_signed_stand : entity work.updown_counter_signed
    generic map (
      r     => R,
      init  => -2 ** R / 2,
      start => -2 ** R / 2,
      stop  => 2 ** R / 2 - 1,
      step  => 1
    )
    port map (
      clk    => clk2,
      rst    => rst,
      enable => enable,
      cnt    => cnt_upd_signed
    );

  -- res <= not res after 1 us;
  clk  <= not clk after 4 ns;  -- 125 MHz
  clk2 <= not clk2 after 2 ns; -- 125 MHz

end architecture tb;
