library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_1ch is
	generic(
		R : integer := 7; -- PWM resolution bits
		REF_TYPE : string := "SYMMETRICAL"; -- Symmetrical and Asymmetrical
		INPUT_DATA_TYPE : string := "SIGNED"; -- signed or unsigned
		REF_INIT : integer := 0
	);
	port(
		clk : in std_logic;
		rst : in std_logic;
		enable : in std_logic;
		input_wave : in std_logic_vector(R-1 downto 0);
		pwm : out std_logic;
		pwm_n : out std_logic
		);
end pwm_1ch;

architecture src of pwm_1ch is
	
	signal counter : std_logic_vector(R-1 downto 0) := (others => '0');

	signal pwm_set : std_logic := '0';
	signal pwm_reset : std_logic := '0';

	signal Q_set : std_logic := '0';
	signal Q_reset : std_logic := '0';


begin

	set_PWM_S_UNSIGNED: if (REF_TYPE = "ASYMMETRICAL" and INPUT_DATA_TYPE = "UNSIGNED") generate
		cnt : entity work.up_counter_unsigned
			generic map (
				R => R,
				INIT => REF_INIT,
				START => 0,
				STOP => 2**R - 1,
				STEP => 1
			)
			port map (
				clk => clk,
				rst => rst,
				enable => enable,
				cnt => counter
			);
	end generate;

	set_PWM_S_SIGNED: if (REF_TYPE = "ASYMMETRICAL" and INPUT_DATA_TYPE = "SIGNED") generate
		cnt : entity work.up_counter_signed
			generic map (
				R => R,
				INIT => REF_INIT, 
				START => -2**R / 2,
				STOP => 2**R / 2 - 1,
				STEP => 1
			)
			port map (
				clk => clk,
				rst => rst,
				enable => enable,
				cnt => counter
			);
	end generate;

	set_PWM_T_UNSIGNED: if (REF_TYPE = "SYMMETRICAL" and INPUT_DATA_TYPE = "UNSIGNED") generate
		cnt : entity work.updown_counter_unsigned
			generic map (
				R => R,
				INIT => REF_INIT, 
				START => 0,
				STOP => 2**R - 1,
				STEP => 1
			)
			port map (
				clk => clk,
				rst => rst,
				enable => enable,
				cnt => counter
			);
	end generate;
		
	set_PWM_T_SIGNED: if (REF_TYPE = "SYMMETRICAL" and INPUT_DATA_TYPE = "SIGNED") generate
		cnt : entity work.updown_counter_signed
			generic map (
				R => R,
				INIT => REF_INIT, 
				START => -2**R / 2,
				STOP => 2**R / 2 - 1,
				STEP => 1
			)
			port map (
				clk => clk,
				rst => rst,
				enable => enable,
				cnt => counter
			);
	end generate;

	pwm_set_control : process(clk, rst, counter, input_wave)
		begin 
			if rising_edge(clk) then
				if rst = '0' then 
					pwm <= '0';
					pwm_set <= '0'; 
					pwm_n <= '1';
					-- counter <= b"0000000";
				else
					if counter <= input_wave then
						pwm <= '1';
						pwm_n <= '0';
					else
						pwm <= '0';
						pwm_n <= '1';
					end if;
				end if;
			end if;
	end process;

end src;