library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

Library unisim;
use unisim.vcomponents.all

entity dead_time_control is
	port(
        clk : in std_logic;
        rst : in std_logic;
		pwm_in : in std_logic;
		pwm_in_n : in std_logic;
		pwm_out : out std_logic;
		pwm_out_n : out std_logic
		);
end dead_time_control;

architecture src of dead_time_control is

    signal pwm_signal : std_logic := '0';
    signal pwm_signal_n : std_logic := '1';
 
    signal pwm_set : std_logic := '0';
    signal pwm_reset : std_logic := '0';
    signal pwm_set_delay : std_logic := '0';
    signal pwm_reset_delay : std_logic := '0';

    -- component delay_counter is
    --     generic (
    --         DELAY_CYCLES : integer := 5 -- Number of clock cycles to delay
    --     );
    --     port (
    --         clk : in  std_logic; -- Clock signal
    --         reset : in  std_logic; -- Reset signal
    --         input_signal : in  std_logic; -- Input signal to delay
    --         delayed_signal : out std_logic -- Delayed output signal
    --     );
    -- end component;

    component sync_rs_flipflop is
        port (
            clk : in  std_logic;
            rst : in  std_logic;        
            S   : in  std_logic;
            R   : in  std_logic;
            Q   : out std_logic;
            Qn  : out std_logic
        );
    end component;

begin

    IDELAYCTRL_inst : IDELAYCTRL
    port map (
        RDY => RDY,                       -- 1-bit output: Ready output
        REFCLK => REFCLK,                 -- 1-bit input: Reference clock input
        RST => RST                        -- 1-bit input: Active high reset input
    );
   
    IDELAYE2_inst_1 : IDELAYE2
    generic map (
        CINVCTRL_SEL => "FALSE",          -- Enable dynamic clock inversion (FALSE, TRUE)
        DELAY_SRC => "DATAIN",           -- Delay input (IDATAIN, DATAIN)
        HIGH_PERFORMANCE_MODE => "FALSE", -- Reduced jitter ("TRUE"), Reduced power ("FALSE")
        IDELAY_TYPE => "VAR_LOAD",        -- FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
        IDELAY_VALUE => 0,                -- Input delay tap setting (0-31)
        PIPE_SEL => "FALSE",              -- Select pipelined mode, FALSE, TRUE
        REFCLK_FREQUENCY => 200.0,        -- IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
        SIGNAL_PATTERN => "DATA"          -- DATA, CLOCK input signal
    )
    port map (
        CNTVALUEOUT => CNTVALUEOUT_1,       -- 5-bit output: Counter value output
        DATAOUT => DATAOUT_1,             -- 1-bit output: Delayed data output
        C => C,                           -- 1-bit input: Clock input
        CE => CE_1,                         -- 1-bit input: Active high enable increment/decrement input
        CINVCTRL => '0',                  -- 1-bit input: Dynamic clock inversion input
        CNTVALUEIN => CNTVALUEIN_1,       -- 5-bit input: Counter value input
        DATAIN => DATAIN_1,               -- 1-bit input: Internal delay data input
        IDATAIN => '0',                   -- 1-bit input: Data input from the I/O
        INC => INC_1,                     -- 1-bit input: Increment / Decrement tap delay input
        LD => LD,                         -- 1-bit input: Load IDELAY_VALUE input
        LDPIPEEN => LDPIPEEN,             -- 1-bit input: Enable PIPELINE register to load data input
        REGRST => REGRST                  -- 1-bit input: Active-high reset tap-delay input
    );
   
    IDELAYE2_inst_2 : IDELAYE2
    generic map (
        CINVCTRL_SEL => "FALSE",          -- Enable dynamic clock inversion (FALSE, TRUE)
        DELAY_SRC => "DATAIN",           -- Delay input (IDATAIN, DATAIN)
        HIGH_PERFORMANCE_MODE => "FALSE", -- Reduced jitter ("TRUE"), Reduced power ("FALSE")
        IDELAY_TYPE => "VAR_LOAD",        -- FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
        IDELAY_VALUE => 0,                -- Input delay tap setting (0-31)
        PIPE_SEL => "FALSE",              -- Select pipelined mode, FALSE, TRUE
        REFCLK_FREQUENCY => 200.0,        -- IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
        SIGNAL_PATTERN => "DATA"          -- DATA, CLOCK input signal
    )
    port map (
        CNTVALUEOUT => CNTVALUEOUT_2,       -- 5-bit output: Counter value output
        DATAOUT => DATAOUT_2,             -- 1-bit output: Delayed data output
        C => C,                           -- 1-bit input: Clock input
        CE => CE_2,                         -- 1-bit input: Active high enable increment/decrement input
        CINVCTRL => '0',                  -- 1-bit input: Dynamic clock inversion input
        CNTVALUEIN => CNTVALUEIN_2,       -- 5-bit input: Counter value input
        DATAIN => DATAIN_2,               -- 1-bit input: Internal delay data input
        IDATAIN => '0',                   -- 1-bit input: Data input from the I/O
        INC => INC_2,                     -- 1-bit input: Increment / Decrement tap delay input
        LD => LD,                         -- 1-bit input: Load IDELAY_VALUE input
        LDPIPEEN => LDPIPEEN,             -- 1-bit input: Enable PIPELINE register to load data input
        REGRST => REGRST                  -- 1-bit input: Active-high reset tap-delay input
    );

    dead_time_main : process(clk, pwm_in, pwm_in_n,
                            pwm_signal, pwm_signal_n)

            variable dead_state : std_logic := '0';
            variable dead_counter : unsigned(DEAD_TIME-1 downto 0) := (others => '0');
            constant dead_counter_start : unsigned(DEAD_TIME-1 downto 0) := (others => '0');
            constant dead_counter_stop : unsigned(DEAD_TIME-1 downto 0) := (others => '1');
            constant dead_counter_step : unsigned(DEAD_TIME-1 downto 0) := (0 => '1', others => '0');
        begin 

	    end process;

    pwm_out <= pwm_signal;
    pwm_out_n <= pwm_signal_n;

end src;