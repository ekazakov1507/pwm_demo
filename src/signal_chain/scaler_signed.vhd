library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity scaler_signed is
  generic (
    r            : integer := 16;
    scale_factor : real    := 0.8;
    offset_factor: real    := 0.1
  );
  port (
    clk         : in    std_logic;
    reset       : in    std_logic;
    input_data  : in    std_logic_vector(r - 1 downto 0);
    output_data : out   std_logic_vector(r - 1 downto 0)
  );
end entity scaler_signed;

architecture src of scaler_signed is

  constant max_val    : integer := 2 ** (r - 1) - 1;
  constant scale_int  : integer := integer(scale_factor * real(max_val));
  constant offset_int : integer := integer(offset_factor * real(max_val));

  constant scale  : signed(r - 1 downto 0) := to_signed(scale_int, r);
  constant offset : signed(r - 1 downto 0) := to_signed(offset_int, r);

  signal input_sig : signed(r - 1 downto 0)     := (others => '0');
  signal product   : signed(2 * r - 1 downto 0) := (others => '0');
  signal scaled    : signed(r - 1 downto 0)     := (others => '0');
  signal result    : signed(r - 1 downto 0)     := (others => '0');

begin

  input_sig <= signed(input_data);

  process (clk, reset) is
  begin

    if (reset = '1') then
      output_data <= (others => '0');
    elsif rising_edge(clk) then
      product <= input_sig * scale;
      scaled  <= product(2 * r - 1 downto r);
      result  <= scaled + offset;
      output_data <= std_logic_vector(result);
    end if;

  end process;

end architecture src;
