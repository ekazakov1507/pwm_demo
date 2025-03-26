library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

Library unisim;
use unisim.vcomponents.all;

entity pwm_c_dt_signed is
	generic(
		R : integer := 7; -- PWM resolution bits
		PWM_TYPE : string := "TRIANGLE"; -- TRIANGLE or LEFT
		INPUT_DATA_TYPE : string := "SIGNED"
	);
	port(
		clk : in std_logic;
		rst : in std_logic;
		enable : in std_logic;
		input_wave : in std_logic_vector(R-1 downto 0);
		pwm : out std_logic;
		pwm_n : out std_logic
		);
end pwm_c_dt_signed;

architecture src of pwm_c_dt_signed is
	
	signal counter : std_logic_vector(R-1 downto 0) := (others => '0');
	signal counter_updown : std_logic := '0';

	signal buffer_out : std_logic_vector(R-1 downto 0) := (others => '0');
	signal buffer_read : std_logic := '0';
	signal buffer_empty : std_logic := '0';
	signal buffer_full : std_logic := '0';


begin

	set_PWM_C_SIGNED: if (PWM_TYPE = "TRIANGLE" and INPUT_DATA_TYPE = "SIGNED") generate
		cnt : entity work.updown_counter_signed
			generic map (
				R => R
			)
			port map (
				clk => clk,
				rst => rst,
				enable => enable,
				cnt => counter
			);
	end generate;
		
	set_PWM_L_SIGNED: if (PWM_TYPE = "LEFT" and INPUT_DATA_TYPE = "SIGNED") generate
		cnt : entity work.up_counter_signed
			generic map (
				R => R
			)
			port map (
				clk => clk,
				rst => rst,
				enable => enable,
				cnt => counter
			);
	end generate;

    uut: entity work.sync_fifo
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            FIFO_DEPTH => FIFO_DEPTH
        )
        port map (
            clk      => clk,
            rst      => rst,
            wr_en    => enable,
            rd_en    => buffer_read,
            data_in  => input_wave,
            data_out => buffer_out,
            full     => buffer_full,
            empty    => buffer_empty
            -- count    => count
        );

	uut: entity work.vector_and
		Generic Map (
			R => R
		)
		Port Map (
			input_vector => input_vector,
			result => result
		);


	in_buf_control : process(clk, rst, enable, buffer_read)
	begin
		if< rising_edge(clk) then
			if rising_edge(counter_updown) then
				buffer_read <= '1';
			end if;
			buffer_read <= '0';
		end if;
	end process;

	triangle_pwm_mod : process(clk, rst, counter, buffer_out)
		begin 
			if rst = '0' then 
				pwm <= '0';
				pwm_n <= '1';
				-- counter <= b"0000000";
			elsif rising_edge(clk) then
				if counter < buffer_out then
					pwm <= '1';
					pwm_n <= '0';
				else
					pwm <= '0';
					pwm_n <= '1';
				end if;


			end if;
	end process;

end src;