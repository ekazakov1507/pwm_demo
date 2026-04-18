library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity up_counter_signed is
  generic (
    r     : integer := 7;
    init  : integer := 0;
    start : integer := -64;
    stop  : integer := 63;
    step  : integer := 1
  );
  port (
    clk    : in    std_logic;
    rst    : in    std_logic;
    enable : in    std_logic;
    cnt    : out   std_logic_vector(r - 1 downto 0)
  );
end entity up_counter_signed;

architecture src of up_counter_signed is

  constant counter_min_reg  : signed(r - 1 downto 0) := to_signed(start, r);
  constant counter_max_reg  : signed(r - 1 downto 0) := to_signed(stop, r);
  constant counter_step_reg : signed(r - 1 downto 0) := to_signed(step, r);

  signal counter_reg : signed(r - 1 downto 0) := to_signed(init, r);

begin

  up_counter : process (clk, rst) is
  begin

    if rising_edge(clk) then
      if (rst = '1') then
        counter_reg <= to_signed(init, r);
      elsif (enable = '1') then
        if (counter_reg <= counter_max_reg - counter_step_reg) then
          counter_reg <= counter_reg + counter_step_reg;
        else
          counter_reg <= counter_min_reg;
        end if;
      end if;
      cnt <= std_logic_vector(counter_reg);
    end if;

  end process up_counter;

end architecture src;
