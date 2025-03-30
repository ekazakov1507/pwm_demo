library ieee;
use ieee.std_logic_1164.all;

entity stretcher is
    generic (
        MAX_STRETCH : integer := 8  -- Maximum stretch amount
    );
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        data_in   : in  std_logic;
        data_out  : out std_logic
    );
end stretcher;

architecture Behavioral of stretcher is
    signal stretch : integer := MAX_STRETCH;
    signal stretch_counter : integer range 0 to MAX_STRETCH-1 := 0;
    signal prev_input : std_logic := '0';
begin
    process(clk, reset)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                stretch_counter <= 0;
                -- prev_input <= '0';
                data_out <= '0';
            elsif reset = '0' then
                prev_input <= data_in;
                
                -- Detect rising edge
                if data_in = '1' and prev_input = '0' then
                -- if falling_edge(data_in) and prev_input = '0' then
                    stretch_counter <= stretch;
                    -- data_out <= '1';
                elsif stretch_counter > 0 then
                    stretch_counter <= stretch_counter - 1;
                    data_out <= '1';
                else
                    data_out <= '0';
                end if;

                -- if falling_edge(data_in) then
                --     stretch_counter <= MAX_STRETCH;
                --     if stretch_counter > 0 then
                --         stretch_counter <= stretch_counter - 1;
                --         data_out <= '1';
                --     else
                --         data_out <= '0';
                --     end if;
                -- end if;
            end if;
        end if;
    end process;
end Behavioral;