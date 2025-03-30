library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

entity sync_fifo is
    generic (
        DATA_WIDTH : positive := 8;     -- Width of each data word
        FIFO_DEPTH : positive := 16     -- Number of words in FIFO
    );
    port (
        clk      : in  std_logic;       -- Clock input
        rst      : in  std_logic;       -- Active-high reset
        wr_en    : in  std_logic;       -- Write enable
        rd_en    : in  std_logic;       -- Read enable
        data_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0);  -- Input data
        data_out : out std_logic_vector(DATA_WIDTH-1 downto 0);  -- Output data
        full     : out std_logic;       -- FIFO full flag
        empty    : out std_logic;       -- FIFO empty flag
        count    : out integer range 0 to FIFO_DEPTH  -- Current word count
    );
end sync_fifo;

architecture src of sync_fifo is
    type fifo_memory is array (0 to FIFO_DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal memory : fifo_memory := (others => (others => '0'));
    
    signal head : integer range 0 to FIFO_DEPTH-1 := 0;  -- Read pointer
    signal tail : integer range 0 to FIFO_DEPTH-1 := 0;  -- Write pointer
    
    signal num_items : integer range 0 to FIFO_DEPTH := 0;  -- Current item count
    signal full_signal : std_logic := '0';
    signal empty_signal : std_logic := '1';
begin
    full <= full_signal;
    empty <= empty_signal;
    count <= num_items;
    
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                head <= 0;
                tail <= 0;
                num_items <= 0;
                full_signal <= '0';
                empty_signal <= '1';
                memory <= (others => (others => '0'));
            else
                -- Handle write operation
                if wr_en = '1' and full_signal = '0' then
                    memory(tail) <= data_in;
                    if tail = FIFO_DEPTH-1 then
                        tail <= 0;
                    else
                        tail <= tail + 1;
                    end if;
                end if;
                
                -- Handle read operation
                if rd_en = '1' and empty_signal = '0' then
                    if head = FIFO_DEPTH-1 then
                        head <= 0;
                    else
                        head <= head + 1;
                    end if;
                end if;
                
                -- Update item count
                if wr_en = '1' and rd_en = '0' and full_signal = '0' then
                    num_items <= num_items + 1;
                elsif rd_en = '1' and wr_en = '0' and empty_signal = '0' then
                    num_items <= num_items - 1;
                end if;
                
                -- Update flags
                if num_items = 0 then
                    empty_signal <= '1';
                else
                    empty_signal <= '0';
                end if;
                
                if num_items = FIFO_DEPTH then
                    full_signal <= '1';
                else
                    full_signal <= '0';
                end if;
            end if;
        end if;
    end process;
    
    data_out <= memory(head);
end src;