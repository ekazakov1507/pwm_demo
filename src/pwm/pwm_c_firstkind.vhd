library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.ALL;
use ieee.std_logic_arith.all;

entity pwm_l1 is
	generic(
		N : integer := 16;
		START : integer := 0;
		STOP : integer := 2**16 - 1;
		STEP : integer := 1
	);
	port(
		clk : in std_logic;
		rst : in std_logic;
        input : in std_logic_vector(N - 1 downto 0);
		pwm : in std_logic;
		pwm_ : in std_logic
	);
end pwm_l1;

architecture src of pwm_l1 is

	signal cnt : std_logic_vector(N - 1 downto 0) := conv_std_logic_vector(START, N);

    
begin

    ref_counter : entity work.updown_counter
        generic map (
            N => N,
            START => START,
            STOP => STOP,
            STEP => STEP
        )
        port map (
            clk => clk,
            rst => rst,
            cnt => cnt,
        );

	first_kind_pwm_center : process(clk, rst, cnt, input)
	begin 
		if rising_edge(clk) then
				if cnt < input then
					pwm <= '1';
					pwm_ <= '0';
				else
					pwm <= '0';
					pwm_ <= '1';
				end if;
			end if;
	end process;
    
end src;