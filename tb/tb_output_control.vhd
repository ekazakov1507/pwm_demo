library ieee;
  use ieee.std_logic_1164.all;

entity tb_output_control is
--  Port ( );
end entity tb_output_control;

architecture tb of tb_output_control is

  constant clk_period : time := 10 ns;

  signal clk    : std_logic := '0';
  signal rst    : std_logic := '0';
  signal input  : std_logic := '0';
  signal output : std_logic := '0';

  component output_control is
    port (
      clk    : in    std_logic;
      rst    : in    std_logic;
      input  : in    std_logic;
      output : out   std_logic
    );
  end component output_control;

begin

  stand : component output_control
    port map (
      clk    => clk,
      rst    => rst,
      input  => input,
      output => output
    );

  clk <= not clk after clk_period / 2;

  stim_proc : process is
  begin

    rst   <= '1';
    wait for clk_period * 2;
    rst   <= '0';
    wait for 2 * clk_period;
    input <= '1';
    wait for clk_period;
    input <= '0';
    wait;

  end process stim_proc;

end architecture tb;
