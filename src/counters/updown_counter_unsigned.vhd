library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity updown_counter_unsigned is
  generic (
    r      : integer   := 7;   -- Resolution
    init   : integer   := 0;
    start  : integer   := 0;   -- 0
    stop   : integer   := 127; -- 2^R-1
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

begin

  up_down_counter : process (clk, rst) is

    constant counter_min    : unsigned(r - 1 downto 0) := to_unsigned(start, r); -- (0 => '1', others => '0');
    constant counter_max    : unsigned(r - 1 downto 0) := to_unsigned(stop, r);  -- (0 => '0', others => '1');
    constant counter_step   : unsigned(r - 1 downto 0) := to_unsigned(step, r);  -- (0 => '1', others => '0');
    variable counter_updown : std_logic                := updown;
    variable counter        : unsigned(r - 1 downto 0) := to_unsigned(init, r);

  begin

    if rising_edge(clk) then
      if (rst = '1') then
        counter        := to_unsigned(init, r);
        counter_updown := '1';
      elsif (rst = '0' and enable = '1') then
        if (counter_updown = '1' and counter < counter_max) then
          counter := counter + counter_step;
        elsif (counter_updown = '0' and counter > counter_min) then
          counter := counter - counter_step;
        elsif (counter = counter_min) then
          counter_updown := '1';
          counter        := counter + counter_step;
        elsif (counter = counter_max) then
          counter_updown := '0';
          counter        := counter - counter_step;
        end if;
      end if;
      cnt <= std_logic_vector(counter);
    end if;

  end process up_down_counter;

end architecture src;
