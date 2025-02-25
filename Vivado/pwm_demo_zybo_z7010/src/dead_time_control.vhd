library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity dead_time_control is
 	generic(
		DEAD_TIME : integer := 10
	);
	port(
		clk : in std_logic;
		res : in std_logic;
		pwm_in : in std_logic;
		pwm_in_n : in std_logic;
		pwm_out : out std_logic;
		pwm_out_n : out std_logic
		);
end dead_time_control;

architecture src of dead_time_control is

    signal pwm_signal : std_logic := '0';
    signal pwm_signal_n : std_logic := '1';
 
begin

    dead_time_main : process(clk, res, 
                            pwm_in, pwm_in_n,
                            pwm_signal, pwm_signal_n)

            variable dead_state : std_logic := '0';
            variable dead_counter : unsigned(DEAD_TIME-1 downto 0) := (others => '0');
            constant dead_counter_start : unsigned(DEAD_TIME-1 downto 0) := (others => '0');
            constant dead_counter_stop : unsigned(DEAD_TIME-1 downto 0) := (others => '1');
            constant dead_counter_step : unsigned(DEAD_TIME-1 downto 0) := (0 => '1', others => '0');
        begin 
			if res = '0' then 
				pwm_signal <= '0';
				pwm_signal_n <= '1';
			elsif rising_edge(clk) then
                pwm_signal <= pwm_in;
                -- pwm_signal_n <= pwm_in_n;
                if pwm_signal = '0' and dead_state = '0' then
                    if dead_counter < dead_counter_stop then
                        dead_counter := dead_counter + dead_counter_step;
                    else
                        dead_state := '1';
                        pwm_signal_n <= '0';
                        dead_counter := dead_counter_start;
                    end if;
                elsif pwm_signal = '1' and dead_state = '1' then
                    if dead_counter < dead_counter_stop then
                        dead_counter := dead_counter + dead_counter_step;
                    else
                        dead_state := '0';
                        pwm_signal_n <= '1';
                        dead_counter := dead_counter_start;
                    end if;
                end if;
            end if;

    end process;

    pwm_out <= pwm_signal;
    pwm_out_n <= pwm_signal_n;

end src;