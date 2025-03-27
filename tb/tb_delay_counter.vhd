library ieee;
use ieee.std_logic_1164.all;

entity tb_delay_counter is
--  Port ( );
end tb_delay_counter;

architecture tb of tb_delay_counter is
    signal clk, reset, input_signal, delayed_signal : STD_LOGIC := '0';
begin
    -- -- Instantiate the DelaySignal module
    -- uut: entity work.DelaySignal
    --     generic map (
    --         DELAY_CYCLES => 5 -- 5 clock cycles delay
    --     )
    --     port map (
    --         clk => clk,
    --         reset => reset,
    --         input_signal => input_signal,
    --         delayed_signal => delayed_signal
    --     );

    -- -- Clock generation process
    -- clk_process: process
    -- begin
    --     clk <= '0'; wait for 5 ns;
    --     clk <= '1'; wait for 5 ns;
    -- end process;

    -- -- Stimulus process
    -- stim_proc: process
    -- begin
    --     -- Apply reset
    --     reset <= '1'; wait for 20 ns;
    --     reset <= '0'; wait for 10 ns;

    --     -- Test case 1: Input signal goes high
    --     input_signal <= '1'; wait for 100 ns;

    --     -- Test case 2: Input signal goes low
    --     input_signal <= '0'; wait for 100 ns;

    --     -- End of simulation
    --     wait;
    -- end process;
end tb;