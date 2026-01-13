library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity tb_input_buffer is
--  Port ( );
end entity tb_input_buffer;

architecture tb of tb_input_buffer is

  constant clk_period : time     := 10 ns;
  constant data_width : positive := 7;
  constant fifo_depth : positive := 128;

  signal clk      : std_logic                                 := '0';
  signal rst      : std_logic                                 := '0';
  signal wr_en    : std_logic                                 := '0';
  signal rd_en    : std_logic                                 := '0';
  signal data_in  : std_logic_vector(data_width - 1 downto 0) := (others => '0');
  signal data_out : std_logic_vector(data_width - 1 downto 0);
  signal full     : std_logic;
  signal empty    : std_logic;
  signal count    : integer range 0 to fifo_depth;

begin

  dut_sine : entity work.sine_gen_simple
    generic map (
      wave_length => 1024,
      bit_width   => data_width,
      data_type   => "UNSIGNED"
    )
    port map (
      clk         => clk,
      reset       => rst,
      output_data => data_in
    );

  uut : entity work.sync_fifo
    generic map (
      data_width => DATA_WIDTH,
      fifo_depth => FIFO_DEPTH
    )
    port map (
      clk      => clk,
      rst      => rst,
      wr_en    => wr_en,
      rd_en    => rd_en,
      data_in  => data_in,
      data_out => data_out,
      full     => full,
      empty    => empty,
      count    => count
    );

  clk <= not clk after clk_period / 2;

  stim_proc : process is
  begin

    rst   <= '1';
    wait for clk_period * 2;
    rst   <= '0';
    wait for clk_period;
    wr_en <= '1';
    wait for clk_period;
    rd_en <= '1';
    wait for 100 * clk_period;
    wr_en <= '0';
    rd_en <= '1';
    wait for 100 * clk_period;
    wr_en <= '1';
    rd_en <= '0';
    wait for clk_period;
    wait;

  end process stim_proc;

end architecture tb;
