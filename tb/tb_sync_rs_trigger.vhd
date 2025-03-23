library ieee;
use ieee.std_logic_1164.ALL;

entity tb_sync_rs_trigger is
--  Port ( );
end tb_sync_rs_trigger;

architecture tb of tb_sync_rs_trigger is
    signal clk, R, S, Q, Qn : std_logic := '0';
begin
    -- Instantiate the Sync_RS_Trigger
    uut: entity work.Sync_RS_Trigger
        Port Map (
            clk => clk,
            R => R,
            S => S,
            Q => Q,
            Qn => Qn
        );

    -- Clock generation process
    clk_process: process
    begin
        clk <= '0'; wait for 5 ns;
        clk <= '1'; wait for 5 ns;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Apply reset
        R <= '1'; S <= '0'; wait for 20 ns;
        R <= '0'; S <= '0'; wait for 10 ns;

        -- Test case 1: Set (R = '0', S = '1')
        R <= '0'; S <= '1'; wait for 20 ns;
        assert Q = '1' and Qn = '0' report "Test case 1 failed" severity error;

        -- Test case 2: Reset (R = '1', S = '0')
        R <= '1'; S <= '0'; wait for 20 ns;
        assert Q = '0' and Qn = '1' report "Test case 2 failed" severity error;

        -- Test case 3: Invalid (R = '1', S = '1')
        R <= '1'; S <= '1'; wait for 20 ns;
        assert Q = 'X' and Qn = 'X' report "Test case 3 failed" severity error;

        -- Test case 4: No change (R = '0', S = '0')
        R <= '0'; S <= '0'; wait for 20 ns;
        assert Q = '0' and Qn = '1' report "Test case 4 failed" severity error;

        -- End of simulation
        report "All test cases passed" severity note;
        wait;
    end process;
end tb;