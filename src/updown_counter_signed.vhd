library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity updown_counter_signed is
  generic (
    r     : integer := 7;   -- Resolution
    init  : integer := 0;
    start : integer := -64; -- -1 2^R / 2
    stop  : integer := 63;  -- +1 * 2^R / 2 - 1
    step  : integer := 1
  );
  port (
    clk    : in    std_logic;
    rst    : in    std_logic;
    enable : in    std_logic;
    cnt    : out   std_logic_vector(r - 1 downto 0)
  );
end entity updown_counter_signed;

architecture src of updown_counter_signed is

begin

  up_down_counter : process (clk, rst) is

    -- constant WR : integer := 2**R - 1;
    constant counter_min    : signed(r - 1 downto 0) := to_signed(start, r); -- (R-1 => '1', others => '0');
    constant counter_max    : signed(r - 1 downto 0) := to_signed(stop, r);  -- (R-1 => '0', others => '1');
    constant counter_step   : signed(r - 1 downto 0) := to_signed(step, r);  -- (0 => '1', others => '0');
    variable counter_updown : std_logic              := '0';
    variable counter        : signed(r - 1 downto 0) := to_signed(init, r);

  begin

    if rising_edge(clk) then
      if (rst = '1') then
        counter        := to_signed(init, r);
        counter_updown := '1';
      elsif (rst = '0' and enable = '1') then
        if (counter_updown = '1' and counter < counter_max + 1 - counter_step) then
          counter := counter + counter_step;
        elsif (counter_updown = '0' and counter > counter_min) then
          counter := counter - counter_step;
        elsif (counter = counter_min) then
          counter_updown := '1';
          counter        := counter + counter_step;
        elsif (counter = counter_max + 1 - counter_step) then
          counter_updown := '0';
          counter        := counter - counter_step;
        end if;
      end if;
      cnt <= std_logic_vector(counter(r - 1 downto 0));
    end if;

  end process up_down_counter;

end architecture src;
