-- vhdl-linter-disable not-declared

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_unsigned.all;

entity edge_delay is
  generic (
    r : integer := 7;
    d : integer := 4
  );
  port (
    clk    : in    std_logic;
    input  : in    std_logic;
    output : out   std_logic
  );
end entity edge_delay;

architecture src of edge_delay is

  constant dead_cycles_cons : integer := d;
  signal   counter_delay    : std_logic_vector(r - 1 downto 0);

begin

  main : process (clk) is
  begin

    if rising_edge(clk) then
      if (input = '0') then
        output        <= '0';
        counter_delay <= (others => '0');
      else
        if (counter_delay < dead_cycles_cons - 1) then
          counter_delay <= counter_delay + 1;
        else
          output <= '1';
        end if;
      end if;
    end if;

  end process main;

end architecture src;
