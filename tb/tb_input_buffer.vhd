library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

entity tb_input_buffer is
--  Port ( );
end tb_input_buffer;

architecture tb of tb_input_buffer is
    constant CLK_PERIOD : time := 10 ns;
    constant DATA_WIDTH : positive := 7;
    constant FIFO_DEPTH : positive := 128;
    
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';
    signal wr_en    : std_logic := '0';
    signal rd_en    : std_logic := '0';
    signal data_in  : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal data_out : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal full     : std_logic;
    signal empty    : std_logic;
    signal count    : integer range 0 to FIFO_DEPTH;
    

begin

    cos_tab_gen : entity work.cos_table_gen
        port map (
            clk => clk,
            reset => rst,
            cosine_out_unsigned => data_in
        );

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
    

    clk <= not clk after CLK_PERIOD/2;

    stim_proc: process
    begin
        rst <= '1';
        wait for CLK_PERIOD*2;
        rst <= '0';
        wait for CLK_PERIOD;
        wr_en <= '1';
        wait for CLK_PERIOD;
        rd_en <= '1';
        wait for 100000*CLK_PERIOD;
        wr_en <= '0';
        rd_en <= '0';
        wait for CLK_PERIOD;
        wait;
    end process;

end tb;