library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_mch_buf is
	generic(
		R : integer := 7; -- PWM resolution bits
        NUM_CHANNELS : integer := 2;
		REF_TYPE : string := "SYMMETRICAL"; -- Symmetrical and Asymmetrical
		INPUT_DATA_TYPE : string := "SIGNED"; -- signed or unsigned
        BUFFER_DEPTH : integer := 1024;
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
end pwm_mch_buf;

architecture src of pwm_mch_buf is

    -- signal buf_in : std_logic_vector(R-1 downto 0) := (others => '0');
    signal buf_out : std_logic_vector(R-1 downto 0) := (others => '0');
    signal buf_rd_en : std_logic := '0';
    signal buf_wr_en : std_logic := '0';
    signal buf_full : std_logic := '0';
    signal buf_empty : std_logic := '0';
    -- signal buf_count ;

    signal duty_cycle_state : std_logic := '0';
    signal duty_cycle : std_logic_vector(R-1 downto 0) := (others => '0');

begin

    input_buffer: entity work.sync_fifo
        generic map (
            DATA_WIDTH => R,
            FIFO_DEPTH => BUFFER_DEPTH -- TO DO resolution formula 
        )
        port map (
            clk      => clk,
            rst      => rst,
            wr_en    => buf_wr_en,
            rd_en    => buf_rd_en,
            data_in  => input_wave,
            data_out => buf_out,
            full     => buf_full,
            empty    => buf_empty
            -- count    => count
        );
 
    -- data_in_buffer_ctrl : process(clk, rst, input_wave)
    -- begin

    -- end process;

    input_buffer_rd_ctrl : process(clk, rst, buf_rd_en, buf_empty)
        variable cnt : integer := 0;
    begin
        if rising_edge(clk) then
            cnt := cnt + 1;
            if rst = '0' then 
                cnt := 0;
                buf_rd_en <= '0';
            elsif cnt = 2**R - 1 and buf_empty = '0' then
                buf_rd_en <= '1';
                cnt := 0;
            elsif cnt /= 2**R - 1 or buf_empty = '1' then
                buf_rd_en <= '0';
            end if;
            -- cnt := cnt + 1;
        end if;
    end process;

    input_buffer_wr_ctrl : process(clk, rst, buf_wr_en, buf_full)
    begin
        if rising_edge(clk) then
            if rst = '0' then 
                buf_wr_en <= '0';
            elsif buf_full = '0' then
                buf_wr_en <= '1'; 
            elsif buf_full = '1' then 
                buf_wr_en <= '0';
            end if;
        end if;
    end process;

    pwm_reg_ctrl : process(clk, rst, duty_cycle, duty_cycle_state, buf_out, buf_rd_en)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                duty_cycle_state <= '0';
                duty_cycle <= (others => '0');
            else
                duty_cycle_state <= buf_rd_en;
                if duty_cycle_state = '1' then
                    duty_cycle <= buf_out;
                end if;
            end if;
        end if;
    end process;

    channels_gen: for i in 0 to NUM_CHANNELS-1 generate 
        pwm2 : entity work.pwm_1ch
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
                -- input_wave => buf_out,
                input_wave => duty_cycle,
                pwm => pwm(i),
                pwm_n => pwm_n(i)
            );  
    end generate;
    
end src;