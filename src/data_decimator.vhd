library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity data_decimator is
  generic (
    data_width        : integer := 16; -- Width of your sine data
    decimation_factor : integer := 100 -- 100MHz / 100 = 1MHz
  );
  port (
    clk : in    std_logic;
    rst : in    std_logic;
    -- Input Stream (Assumed continuous at 100MHz)
    data_in : in    std_logic_vector(data_width - 1 downto 0);
    -- Output Stream (Valid at 1MHz)
    data_out  : out   std_logic_vector(data_width - 1 downto 0);
    valid_out : out   std_logic
  );
end entity data_decimator;

architecture src of data_decimator is

  signal count_reg : integer range 0 to decimation_factor - 1 := 0;
  signal valid_int : std_logic                                := '0';

begin

  process (clk, rst) is
  begin

    if (rst = '1') then
      count_reg <= 0;
      valid_int <= '0';
      data_out  <= (others => '0');
    elsif rising_edge(clk) then
      -- Default
      valid_int <= '0';

      -- Counter Logic
      if (count_reg = decimation_factor - 1) then
        count_reg <= 0;
        valid_int <= '1';                         -- Assert valid for 1 clock cycle
        data_out  <= data_in;                     -- Capture new data
      else
        count_reg <= count_reg + 1;
      end if;
    end if;

  end process;

  valid_out <= valid_int;

end architecture src;
