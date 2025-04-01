library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_mch is
	generic(
		R : integer := 7; -- PWM resolution bits
        NUM_CHANNELS : integer := 2;
		REF_TYPE : string := "SYMMETRICAL"; -- Symmetrical and Asymmetrical
		INPUT_DATA_TYPE : string := "SIGNED"; -- signed or unsigned
		REF_INIT : integer := 0 -- TO DO integer_vector
	);
	port(
		clk : in std_logic;
		rst : in std_logic;
		enable : in std_logic;
		input_wave : in std_logic_vector(R-1 downto 0);
		pwm : out std_logic_vector(NUM_CHANNELS-1 downto 0);
		pwm_n : out std_logic_vector(NUM_CHANNELS-1 downto 0)
		);
end pwm_mch;

architecture src of pwm_mch is

begin

    channels_gen: for i in 0 to NUM_CHANNELS-1 generate 
        pwm_mod : entity work.pwm_1ch
        -- pwm_ch : pwm_1ch
            generic map (
                R => R,
                REF_TYPE => REF_TYPE,
                REF_INIT => REF_INIT,
                INPUT_DATA_TYPE => INPUT_DATA_TYPE
            )   
            port map (
                clk => clk,
                rst => rst,
                enable => enable,
                input_wave => input_wave,
                pwm => pwm(i),
                pwm_n => pwm_n(i)
            );  
    end generate; 

end src;
