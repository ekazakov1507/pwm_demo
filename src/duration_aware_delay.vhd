library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

entity duration_aware_delay is
    generic (
        CLK_PERIOD   : time := 10 ns;  -- Clock period for duration calculation
        MAX_DURATION : natural := 16    -- Maximum duration in clock cycles
    );
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        data_in   : in  std_logic;
        data_out  : out std_logic;
        duration  : out natural range 0 to MAX_DURATION-1  -- Measured duration
    );
end duration_aware_delay;

architecture Behavioral of duration_aware_delay is
    signal prev_data : std_logic := '0';
    signal counter   : natural range 0 to MAX_DURATION-1 := 0;
    signal pulse_reg : std_logic_vector(MAX_DURATION-1 downto 0) := (others => '0');

begin
    -- Measure pulse duration
    process(clk, reset)
    begin
        if reset = '1' then
            counter <= 0;
            prev_data <= '0';
        elsif rising_edge(clk) then
            prev_data <= data_in;
            
            if data_in /= prev_data then  -- Edge detected
                duration <= counter;
                counter <= 0;
            elsif counter < MAX_DURATION-1 then
                counter <= counter + 1;
            end if;
        end if;
    end process;
    
    -- Delay line that maintains pulse duration
    process(clk)
    begin
        if rising_edge(clk) then
            pulse_reg <= pulse_reg(pulse_reg'high-1 downto 0) & data_in;
        end if;
    end process;
    
    data_out <= pulse_reg(pulse_reg'high);
end Behavioral;