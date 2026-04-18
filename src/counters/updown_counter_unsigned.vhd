library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity updown_counter_unsigned is
  generic (
    r      : integer   := 7;
    init   : integer   := 0;
    start  : integer   := 0;
    stop   : integer   := 127;
    step   : integer   := 1;
    updown : std_logic := '1'
  );
  port (
    clk    : in    std_logic;
    rst    : in    std_logic;
    enable : in    std_logic;
    cnt    : out   std_logic_vector(r - 1 downto 0)
  );
end entity updown_counter_unsigned;

architecture src of updown_counter_unsigned is

  constant counter_min_reg  : unsigned(r - 1 downto 0) := to_unsigned(start, r);
  constant counter_max_reg  : unsigned(r - 1 downto 0) := to_unsigned(stop, r);
  constant counter_step_reg : unsigned(r - 1 downto 0) := to_unsigned(step, r);

  signal counter_reg        : unsigned(r - 1 downto 0) := to_unsigned(init, r);
  signal counter_updown_reg : std_logic                := updown;

begin

  updown_counter : process (clk, rst) is
  begin

    if rising_edge(clk) then
      if (rst = '1') then
        counter_reg        <= to_unsigned(init, r);
        counter_updown_reg <= updown;
      elsif (enable = '1') then
        if (counter_updown_reg = '1') then
          if (counter_reg <= counter_max_reg - counter_step_reg) then
            counter_reg <= counter_reg + counter_step_reg;
          else
            counter_updown_reg <= '0';
            counter_reg        <= counter_reg - counter_step_reg;
          end if;
        else
          if (counter_reg >= counter_min_reg + counter_step_reg) then
            counter_reg <= counter_reg - counter_step_reg;
          else
            counter_updown_reg <= '1';
            counter_reg        <= counter_reg + counter_step_reg;
          end if;
        end if;
      end if;
      cnt <= std_logic_vector(counter_reg);
    end if;

  end process updown_counter;

end architecture src;
