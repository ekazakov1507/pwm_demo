library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity updown_counter_signed is
  generic (
    r      : integer   := 7;   -- Resolution
    init   : integer   := 0;
    start  : integer   := -64; -- -1 2^R / 2
    stop   : integer   := 63;  -- +1 * 2^R / 2 - 1
    step   : integer   := 1;
    updown : std_logic := '1'
  );
  port (
    clk    : in    std_logic;
    rst    : in    std_logic;
    enable : in    std_logic;
    cnt    : out   std_logic_vector(r - 1 downto 0)
  );
end entity updown_counter_signed;

architecture src of updown_counter_signed is

  -- Registered counter limits (removes combinatorial to_signed() calls)
  constant counter_min_reg : signed(r - 1 downto 0) := to_signed(start, r);
  constant counter_max_reg : signed(r - 1 downto 0) := to_signed(stop, r);
  constant counter_step_reg : signed(r - 1 downto 0) := to_signed(step, r);

begin

  up_down_counter : process (clk, rst) is

    variable counter_updown : std_logic              := updown;
    variable counter        : signed(r - 1 downto 0) := to_signed(init, r);

  begin

    if rising_edge(clk) then
      if (rst = '1') then
        counter := to_signed(init, r);
      elsif (rst = '0' and enable = '1') then
        if (counter_updown = '1' and counter < counter_max_reg + 1 - counter_step_reg) then
          counter := counter + counter_step_reg;
        elsif (counter_updown = '0' and counter > counter_min_reg) then
          counter := counter - counter_step_reg;
        elsif (counter = counter_min_reg) then
          counter_updown := '1';
          counter        := counter + counter_step_reg;
        elsif (counter = counter_max_reg + 1 - counter_step_reg) then
          counter_updown := '0';
          counter        := counter - counter_step_reg;
        end if;
      end if;
      cnt <= std_logic_vector(counter(r - 1 downto 0));
    end if;

  end process up_down_counter;

end architecture src;
