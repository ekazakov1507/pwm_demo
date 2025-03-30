library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity delay_counter is
    generic (
        DELAY_CYCLES : integer := 5 -- Number of clock cycles to delay
    );
    port (
        clk : in  std_logic; -- Clock signal
        reset : in  std_logic; -- Reset signal
        input_signal : in  std_logic; -- Input signal to delay
        delayed_signal : out std_logic -- Delayed output signal
    );
end delay_counter;

architecture src of delay_counter is
    signal shift_reg : std_logic_vector(DELAY_CYCLES-1 downto 0) := (others => '0'); -- Shift register for delay
begin
    process(clk, reset)
    begin
        if rising_edge(clk) then
            if reset = '0' then
                -- Reset the shift register
                shift_reg <= (others => '0');
            elsif reset = '1' then
                -- Shift the input signal through the register
                shift_reg <= shift_reg(DELAY_CYCLES-2 downto 0) & input_signal;
            end if;
        end if;
    end process;

    -- Output the delayed signal
    delayed_signal <= shift_reg(DELAY_CYCLES-1);
end src;