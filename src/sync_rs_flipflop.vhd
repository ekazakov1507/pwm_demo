library ieee;
use ieee.std_logic_1164.all;

entity sync_rs_flipflop is
    port (
        clk : in  std_logic;
        S   : in  std_logic;
        R   : in  std_logic;
        Q   : out std_logic;
        Qn  : out std_logic
    );
end sync_rs_flipflop;

architecture src of sync_rs_flipflop is
    signal Q_temp : std_logic := '0';
begin
    process(clk, R, S)
    begin
        if rising_edge(clk) then
            if S = '1' and R = '0' then
                Q_temp <= '1';
            elsif S = '0' and R = '1' then
                Q_temp <= '0';
            elsif S = '1' and R = '1' then
                Q_temp <= 'X';
            end if;
        end if;
    end process;

    Q  <= Q_temp;
    Qn <= not Q_temp;
end src;