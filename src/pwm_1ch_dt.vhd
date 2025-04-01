library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_1ch_dt is
	generic(
		R : integer := 7; -- PWM resolution bits
		PWM_TYPE : string := "SAWTOOTH"; -- TRIANGULAR or SAWTOOTH
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
end pwm_1ch_dt;

architecture src of pwm_1ch_dt is
	
	signal counter : std_logic_vector(R-1 downto 0) := (others => '0');

	signal pwm_set : std_logic := '0';
	signal pwm_reset : std_logic := '0';

	signal Q_set : std_logic := '0';
	signal Q_reset : std_logic := '0';


begin

	set_PWM_S_UNSIGNED: if (PWM_TYPE = "SAWTOOTH" and INPUT_DATA_TYPE = "UNSIGNED") generate
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

	set_PWM_S_SIGNED: if (PWM_TYPE = "SAWTOOTH" and INPUT_DATA_TYPE = "SIGNED") generate
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

	set_PWM_T_UNSIGNED: if (PWM_TYPE = "TRIANGULAR" and INPUT_DATA_TYPE = "UNSIGNED") generate
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
		
	set_PWM_T_SIGNED: if (PWM_TYPE = "TRIANGULAR" and INPUT_DATA_TYPE = "SIGNED") generate
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

	pwm_reset_instance_UNSIGNED: if (INPUT_DATA_TYPE = "UNSIGNED") generate
		pwm_reset_control : process(clk, counter)
		begin
			if rising_edge(clk) then
				if counter = std_logic_vector(to_unsigned(2**R - 1, R)) then
					pwm_reset <= '1';
				else
					pwm_reset <= '0';
				end if;
			end if;
		end process;
	end generate;

	pwm_reset_instance_SIGNED: if (INPUT_DATA_TYPE = "SIGNED") generate
		pwm_reset_control : process(clk, counter)
		begin
			if rising_edge(clk) then
				if counter = std_logic_vector(to_signed(2**R / 2 - 1, R)) then
					pwm_reset <= '1';
				else
					pwm_reset <= '0';
				end if;
			end if;
		end process;
	end generate;

    RS_trigger : entity work.sync_rs_flipflop
		port map (
			clk => clk,
			S => pwm_reset,
			R => pwm_set,
			Q => Q_set,
			Qn => Q_reset 
		); 

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

					if counter = input_wave then
						pwm_set <= '1';
					else
						pwm_set <= '0';
					end if;
				end if;
			end if;

	end process;

end src;