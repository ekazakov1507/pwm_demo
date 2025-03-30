library ieee;
use ieee.std_logic_1164.all;

entity stretcher_tb is
--  Port ( );
end stretcher_tb;

architecture Behavioral of stretcher_tb is
    constant CLK_PERIOD : time := 10 ns;
    constant MAX_STRETCH : positive := 3;
    
    signal clk      : std_logic := '0';
    signal reset    : std_logic := '1';
    signal data_in  : std_logic := '0';
    signal data_out : std_logic;
    
begin

    uut: entity work.stretcher
        generic map (
            MAX_STRETCH => MAX_STRETCH -- Stretch to 3 cycles
        )
        port map (
            clk => clk,
            reset => reset,
            data_in => data_in,
            data_out => data_out
        );
    
    clk <= not clk after CLK_PERIOD/2;
    
    stim_proc: process
    begin
        -- Initial reset
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        
        -- Test single cycle pulses
        for i in 1 to 5 loop
            data_in <= '1';
            wait for CLK_PERIOD;
            data_in <= '0';
            wait for 5*CLK_PERIOD;
        end loop;
        
        -- Test back-to-back pulses
        for i in 1 to 3 loop
            data_in <= '1';
            wait for CLK_PERIOD;
            data_in <= '0';
            wait for CLK_PERIOD;
        end loop;
        
        wait for 10*CLK_PERIOD;
        
        -- Test longer input pulse
        data_in <= '1';
        wait for 2*CLK_PERIOD;
        data_in <= '0';
        wait for 10*CLK_PERIOD;
        
        report "Simulation completed";
        wait;
    end process;
end Behavioral;