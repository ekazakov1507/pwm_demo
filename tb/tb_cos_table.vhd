library ieee;
  use ieee.std_logic_1164.all;

entity tb_cos_table is
--  Port ( );
end entity tb_cos_table;

architecture tb of tb_cos_table is

  signal clk                 : std_logic                    := '0';
  signal reset               : std_logic                    := '0';
  signal cosine_out_unsigned : std_logic_vector(6 downto 0) := (others => '0');
  signal cosine_out_signed   : std_logic_vector(6 downto 0) := (others => '0');

  component cos_table_gen is
    port (
      clk                 : in    std_logic;
      reset               : in    std_logic;
      cosine_out_unsigned : out   std_logic_vector(6 downto 0);
      cosine_out_signed   : out   std_logic_vector(6 downto 0)
    );
  end component cos_table_gen;

begin

  stand : component cos_table_gen
    port map (
      clk                 => clk,
      reset               => reset,
      cosine_out_unsigned => cosine_out_unsigned,
      cosine_out_signed   => cosine_out_signed
    );

  clk <= not clk after 4 ns; -- 125 MHz

end architecture tb;
