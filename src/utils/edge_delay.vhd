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
  signal   counter_delay    : unsigned(r - 1 downto 0);

  signal output_reg : std_logic := '0';

  -- 2-stage synchronizer for input signal (prevents metastability)
  signal input_sync : std_logic_vector(2 downto 0) := "000";

begin

  main : process (clk) is
  begin

    if rising_edge(clk) then
      -- Shift input through synchronizer
      input_sync <= input_sync(1 downto 0) & input;

      if (input_sync(2) = '0') then
        output_reg    <= '0';
        counter_delay <= (others => '0');
      else
        -- if (counter_delay < dead_cycles_cons - 1) then
        if (counter_delay < to_unsigned(dead_cycles_cons, r)) then
          counter_delay <= counter_delay + 1;
          output_reg    <= '0';
        else
          output_reg <= '1';
        end if;
      end if;
    end if;

  end process main;

  output <= output_reg;

end architecture src;
