library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_sync_fifo is
--  Port ( );
end tb_sync_fifo;

architecture tb of tb_sync_fifo is
    constant DATA_WIDTH : positive := 8;
    constant FIFO_DEPTH : positive := 4;
    
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';
    signal wr_en    : std_logic := '0';
    signal rd_en    : std_logic := '0';
    signal data_in  : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal data_out : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal full     : std_logic;
    signal empty    : std_logic;
    signal count    : integer range 0 to FIFO_DEPTH;
    
    constant CLK_PERIOD : time := 10 ns;
begin
    -- Instantiate the FIFO
    uut: entity work.sync_fifo
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            FIFO_DEPTH => FIFO_DEPTH
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
    clk <= not clk after CLK_PERIOD/2;
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Reset the FIFO
        rst <= '1';
        wait for CLK_PERIOD*2;
        rst <= '0';
        wait for CLK_PERIOD;
        
        -- Test 1: Write until full
        for i in 1 to FIFO_DEPTH loop
            wr_en <= '1';
            data_in <= std_logic_vector(to_unsigned(i, DATA_WIDTH));
            wait for CLK_PERIOD;
        end loop;
        wr_en <= '0';
        wait for CLK_PERIOD*2;
        
        -- Test 2: Read until empty
        for i in 1 to FIFO_DEPTH loop
            rd_en <= '1';
            wait for CLK_PERIOD;
        end loop;
        rd_en <= '0';
        wait for CLK_PERIOD*2;
        
        -- Test 3: Simultaneous read and write
        for i in 1 to FIFO_DEPTH*2 loop
            wr_en <= '1';
            rd_en <= '1';
            data_in <= std_logic_vector(to_unsigned(i+10, DATA_WIDTH));
            wait for CLK_PERIOD;
        end loop;
        wr_en <= '0';
        rd_en <= '0';
        wait for CLK_PERIOD*2;
        
        -- End simulation
        wait;
    end process;
end tb;