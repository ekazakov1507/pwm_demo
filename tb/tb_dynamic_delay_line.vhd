library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity delay_line_tb is
--  Port ( );
end delay_line_tb;

architecture Behavioral of delay_line_tb is
    constant CLK_PERIOD : time := 10 ns;
    
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '1';
    signal data_in   : std_logic := '0';
    signal delay_sel : natural := 2;
    signal data_out  : std_logic;
    
begin
    -- Instantiate the DUT
    dut: entity work.dynamic_delay_line
        generic map (
            MAX_DELAY_CYCLES => 8
        )
        port map (
            clk => clk,
            reset => reset,
            data_in => data_in,
            delay_sel => delay_sel,
            data_out => data_out
        );
    
    -- Clock generation
    clk <= not clk after CLK_PERIOD/2;
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Initial reset
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        
        -- Test different pulse durations with fixed delay
        delay_sel <= 7;  -- 3 clock cycle delay
        
        -- Short pulse (1 cycle)
        data_in <= '1';
        wait for CLK_PERIOD;
        data_in <= '0';
        wait for 10*CLK_PERIOD;
        
        -- Medium pulse (3 cycles)
        data_in <= '1';
        wait for 3*CLK_PERIOD;
        data_in <= '0';
        wait for 10*CLK_PERIOD;
        
        -- Long pulse (5 cycles)
        data_in <= '1';
        wait for 5*CLK_PERIOD;
        data_in <= '0';
        wait for 10*CLK_PERIOD;
        
        -- Test different delay settings with fixed pulse
        data_in <= '1';
        wait for 2*CLK_PERIOD;
        data_in <= '0';
        
        for i in 0 to 7 loop
            delay_sel <= i;
            wait for 5*CLK_PERIOD;
        end loop;
        
        wait;
    end process;
end Behavioral;