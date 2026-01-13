library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity rescaler_unsigned is
  generic (
    r             : integer := 16;
    scale_factor  : real    := 0.8;
    offset_factor : real    := 0.1
  );
  port (
    clk         : in    std_logic;
    reset       : in    std_logic;
    input_data  : in    std_logic_vector(r - 1 downto 0);
    output_data : out   std_logic_vector(r - 1 downto 0)
  );
end entity rescaler_unsigned;

architecture src of rescaler_unsigned is

  constant max_val    : integer := 2 ** (r - 1);
  constant scale_int  : integer := integer(scale_factor * real(max_val));
  constant offset_int : integer := integer(offset_factor * real(max_val));

  constant offset : unsigned(r - 1 downto 0) := to_unsigned(offset_int, r); -- 0.1
  constant scale  : unsigned(r - 1 downto 0) := to_unsigned(scale_int, r);  -- 0.8

  signal input_uns : unsigned(r - 1 downto 0)     := (others => '0');
  signal product   : unsigned(2 * r - 1 downto 0) := (others => '0');
  signal scaled    : unsigned(r - 1 downto 0)     := (others => '0');
  signal result    : unsigned(r - 1 downto 0)     := (others => '0');

begin

  input_uns <= unsigned(input_data);

  process (clk, reset) is
  begin

    if (reset = '1') then
      output_data <= (others => '0');
    elsif rising_edge(clk) then
      product <= input_uns * scale;                     -- 16 x 16 → 32 bit
      scaled  <= product(2 * r - 1 downto r);           -- Divide by 65536 (take upper 16 bits)
      result  <= scaled + offset;                       -- Add 0.1 offset

      output_data <= std_logic_vector(result);
    end if;

  end process;

end architecture src;
