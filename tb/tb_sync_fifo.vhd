library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity tb_sync_fifo is
--  Port ( );
end entity tb_sync_fifo;

architecture tb of tb_sync_fifo is

  constant clk_period : time     := 10 ns;
  constant data_width : positive := 8;
  constant fifo_depth : positive := 4;

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

  -- Instantiate the FIFO
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

  -- Clock generation
  clk <= not clk after clk_period / 2;

  -- Stimulus process
  stim_proc : process is
  begin

    -- Reset the FIFO
    rst <= '1';
    wait for clk_period * 2;
    rst <= '0';
    wait for clk_period;

    -- Test 1: Write until full
    for i in 1 to fifo_depth loop

      wr_en   <= '1';
      data_in <= std_logic_vector(to_unsigned(i, data_width));
      wait for clk_period;

    end loop;

    wr_en <= '0';
    wait for clk_period * 2;

    -- Test 2: Read until empty
    for i in 1 to fifo_depth loop

      rd_en <= '1';
      wait for clk_period;

    end loop;

    rd_en <= '0';
    wait for clk_period * 2;

    -- Test 3: Simultaneous read and write
    for i in 1 to fifo_depth * 2 loop

      wr_en   <= '1';
      rd_en   <= '1';
      data_in <= std_logic_vector(to_unsigned(i + 10, data_width));
      wait for clk_period;

    end loop;

    wr_en <= '0';
    rd_en <= '0';
    wait for clk_period * 2;

    -- End simulation
    wait;

  end process stim_proc;

end architecture tb;
