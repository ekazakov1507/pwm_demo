library ieee;
use ieee.std_logic_1164.all;

entity dynamic_delay_line is
    generic (
        MAX_DELAY_CYCLES : natural := 8  -- Maximum delay in clock cycles
    );
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        data_in   : in  std_logic;
        delay_sel : in  natural range 0 to MAX_DELAY_CYCLES-1;  -- Selectable delay
        data_out  : out std_logic
    );
end dynamic_delay_line;

architecture Behavioral of dynamic_delay_line is
    type delay_array is array (0 to MAX_DELAY_CYCLES-1) of std_logic;
    signal delay_regs : delay_array := (others => '0');
begin
    process(clk, reset)
    begin
        if reset = '1' then
            delay_regs <= (others => '0');
        elsif rising_edge(clk) then
            -- Shift register implementation
            delay_regs(0) <= data_in;
            for i in 1 to MAX_DELAY_CYCLES-1 loop
                delay_regs(i) <= delay_regs(i-1);
            end loop;
        end if;
    end process;
    
    -- Selectable output tap
    data_out <= delay_regs(delay_sel);
end Behavioral;