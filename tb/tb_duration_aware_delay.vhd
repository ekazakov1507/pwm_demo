library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

entity tb_duration_aware_delay is
--  Port ( );
end tb_duration_aware_delay;

architecture Behavioral of tb_duration_aware_delay is
    constant CLK_PERIOD : time := 10 ns;
    constant MAX_DURATION : integer := 2;
    
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '1';
    signal data_in   : std_logic := '0';
    signal data_out  : std_logic;
    signal duration  : natural range 0 to MAX_DURATION-1;  -- Measured duration


begin

    -- Instantiate the DUT
    dut: entity work.duration_aware_delay
        generic map (
            CLK_PERIOD => CLK_PERIOD,
            MAX_DURATION => MAX_DURATION
        )
        port map (
            clk => clk,
            reset => reset,
            data_in => data_in,
            data_out => data_out,
            duration => duration
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
        
        wait;
    end process;
end Behavioral;