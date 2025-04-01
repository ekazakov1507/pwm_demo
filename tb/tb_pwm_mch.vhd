library ieee;
use ieee.std_logic_1164.all;

entity tb_pwm_mch is
--  Port ( );
end tb_pwm_mch;

architecture tb of tb_pwm_mch is
    constant CLK_PERIOD : time := 10 ns;
    constant DATA_WIDTH : integer := 7;
    constant BUFFER_DEPTH : integer := 128;
    constant NUM_CHANNELS : integer := 2;
    
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';
    signal enable    : std_logic := '0';
    signal data_in  : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

    signal p : std_logic_vector(NUM_CHANNELS-1 downto 0) := (others => '0');
    signal p_n : std_logic_vector(NUM_CHANNELS-1 downto 0) := (others => '0');

    signal p_buf : std_logic_vector(NUM_CHANNELS-1 downto 0) := (others => '0');
    signal p_n_buf : std_logic_vector(NUM_CHANNELS-1 downto 0) := (others => '0');
 
    component pwm_mch_buf is
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
    end component;


begin

    cos_tab_gen : entity work.cos_table_gen
        port map (
            clk => clk,
            reset => rst,
            cosine_out_signed => data_in
        );

    simple_pwm : entity work.pwm_mch
        generic map(
            R => DATA_WIDTH,
            NUM_CHANNELS => NUM_CHANNELS,
            REF_TYPE => "ASYMMETRICAL",
            INPUT_DATA_TYPE => "SIGNED",
            REF_INIT => 0
        )
        port map (
            clk => clk,
            rst => rst,
            enable => enable,
            input_wave => data_in,
            pwm => p,
            pwm_n => p_n
        );

    -- adv_pwm : entity work.pwm_mch_buf
    adv_pwm : pwm_mch_buf
        generic map(
            R => DATA_WIDTH,
            NUM_CHANNELS => NUM_CHANNELS,
            REF_TYPE => "ASYMMETRICAL",
            INPUT_DATA_TYPE => "SIGNED",
            BUFFER_DEPTH => 1024,
            REF_INIT => 0
        )
        port map (
            clk => clk,
            rst => rst,
            enable => enable,
            input_wave => data_in,
            pwm => p_buf,
            pwm_n => p_n_buf
        );


    clk <= not clk after CLK_PERIOD/2;

    stim_proc: process
    begin
        rst <= '0';
        wait for CLK_PERIOD*2;
        rst <= '1';
        wait for CLK_PERIOD;
        enable <= '1';
        wait for CLK_PERIOD;
        wait;
    end process;

end tb;
