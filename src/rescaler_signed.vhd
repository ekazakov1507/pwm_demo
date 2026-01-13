library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity rescaler_signed is
  generic (
    r            : integer := 16;
    scale_factor : real    := 0.9
  );
  port (
    clk         : in    std_logic;
    reset       : in    std_logic;
    input_data  : in    std_logic_vector(r - 1 downto 0); -- Q1.15 signed: -1.0 to +1.0
    output_data : out   std_logic_vector(r - 1 downto 0)  -- Q1.15 signed: scaled to ≈ -0.9 to +0.9
  );
end entity rescaler_signed;

architecture src of rescaler_signed is

  constant max_val   : integer := 2 ** (r - 1) - 1;
  constant scale_int : integer := integer(scale_factor * real(max_val));

  -- Scale factor: 0.9 in Q1.15 format
  -- 0.9 * 32768 ≈ 29491.2 → use 29491
  constant scale : signed(r - 1 downto 0) := to_signed(scale_int, r);

  signal input_sig : signed(r - 1 downto 0)     := (others => '0');
  signal product   : signed(2 * r - 1 downto 0) := (others => '0');
  signal scaled    : signed(r - 1 downto 0)     := (others => '0');

begin

  input_sig <= signed(input_data);

  process (clk, reset) is
  begin

    if (reset = '1') then
      output_data <= (others => '0');
    elsif rising_edge(clk) then
      -- Signed multiplication: 16 x 16 → 32 bits
      product <= input_sig * scale;

      -- Divide by 32768: take upper 16 bits (bits 31 downto 16)
      -- This correctly handles sign extension
      scaled <= product(2 * r - 2 downto r - 1);  -- Note: 30, not 31! (because Q1.15 * Q1.15 = Q2.30)

      output_data <= std_logic_vector(scaled);
    end if;

  end process;

end architecture src;
