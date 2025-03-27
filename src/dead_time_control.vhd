library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Library unisim;
use unisim.vcomponents.all;

entity dead_time_control is
	port(
        clk : in std_logic;
        rst : in std_logic;
		pwm_set : in std_logic;
		pwm_reset : in std_logic;
		pwm_chA : out std_logic;
		pwm_chB : out std_logic
		);
end dead_time_control;

architecture src of dead_time_control is

    -- ## CONSTANTS ##
    -- for generic maps
    -- constant CINVCTRL_SEL : string := "FALSE";          -- Enable dynamic clock inversion (FALSE, TRUE)
    -- constant DELAY_SRC : string := "DATAIN";           -- Delay input (IDATAIN, DATAIN)
    -- constant HIGH_PERFORMANCE_MODE : string := "FALSE"; -- Reduced jitter ("TRUE"), Reduced power ("FALSE")
    -- constant IDELAY_TYPE : string := "VAR_LOAD";        -- FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
    -- constant IDELAY_VALUE : integer := 0,                -- Input delay tap setting (0-31)
    -- constant PIPE_SEL : string:= "FALSE";              -- Select pipelined mode, FALSE, TRUE
    -- constant REFCLK_FREQUENCY : real := 200.0,        -- IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
    -- constant SIGNAL_PATTERN : setting := "DATA";          -- DATA, CLOCK input signal

    -- for port maps
    constant CE : std_logic := '0'; -- 1-bit input: Active high enable increment/decrement input

    constant INC : std_logic := '0'; -- 1-bit input: Increment / Decrement tap delay input

    constant LD : std_logic := '0'; -- 1-bit input: Load IDELAY_VALUE input

    constant LDPIPEEN : std_logic := '0'; -- 1-bit input: Enable PIPELINE register to load data input

    constant REGRST : std_logic := '0'; -- 1-bit input: Active-high reset tap-delay input

    signal CNTVALUEIN : std_logic_vector(4 downto 0) := (others => '0'); -- 5-bit input: Counter value input
    signal CNTVALUEOUT : std_logic_vector(4 downto 0) := (others => '1'); -- 5-bit output: Counter value output


    signal pwm_set_delay : std_logic := '0';
    signal pwm_reset_delay : std_logic := '0';

    signal or_gate_A : std_logic := '0';
    signal or_gate_B : std_logic := '0';

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

begin

    -- IDELAYCTRL_inst : IDELAYCTRL
    -- port map (
    --     RDY => RDY,                       -- 1-bit output: Ready output
    --     REFCLK => clk,                 -- 1-bit input: Reference clock input
    --     RST => rst                        -- 1-bit input: Active high reset input
    -- );
   
    -- Channel A
    IDELAYE2_inst_chA : IDELAYE2
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
        CNTVALUEOUT => CNTVALUEOUT,       -- 5-bit output: Counter value output
        DATAOUT => pwm_set_delay,             -- 1-bit output: Delayed data output
        C => clk,                           -- 1-bit input: Clock input
        CE => CE,                         -- 1-bit input: Active high enable increment/decrement input
        CINVCTRL => '0',                  -- 1-bit input: Dynamic clock inversion input
        CNTVALUEIN => CNTVALUEIN,       -- 5-bit input: Counter value input
        DATAIN => pwm_set,               -- 1-bit input: Internal delay data input
        IDATAIN => '0',                   -- 1-bit input: Data input from the I/O
        INC => INC,                     -- 1-bit input: Increment / Decrement tap delay input
        LD => LD,                         -- 1-bit input: Load IDELAY_VALUE input
        LDPIPEEN => LDPIPEEN,             -- 1-bit input: Enable PIPELINE register to load data input
        REGRST => REGRST                  -- 1-bit input: Active-high reset tap-delay input
    );
   
    RS_trigger_A : entity work.sync_rs_flipflop
    port map (
        clk => clk,
        S => pwm_reset_delay,
        R => or_gate_A,
        Q => pwm_chA
    ); 

    -- channel B
    IDELAYE2_inst_chB : IDELAYE2
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
        CNTVALUEOUT => CNTVALUEOUT,       -- 5-bit output: Counter value output
        DATAOUT => pwm_reset_delay,             -- 1-bit output: Delayed data output
        C => clk,                           -- 1-bit input: Clock input
        CE => CE,                         -- 1-bit input: Active high enable increment/decrement input
        CINVCTRL => '0',                  -- 1-bit input: Dynamic clock inversion input
        CNTVALUEIN => CNTVALUEIN,       -- 5-bit input: Counter value input
        DATAIN => pwm_reset,               -- 1-bit input: Internal delay data input
        IDATAIN => '0',                   -- 1-bit input: Data input from the I/O
        INC => INC,                     -- 1-bit input: Increment / Decrement tap delay input
        LD => LD,                         -- 1-bit input: Load IDELAY_VALUE input
        LDPIPEEN => LDPIPEEN,             -- 1-bit input: Enable PIPELINE register to load data input
        REGRST => REGRST                  -- 1-bit input: Active-high reset tap-delay input
    );

    RS_trigger_B : entity work.sync_rs_flipflop
    port map (
        clk => clk,
        S => pwm_set_delay,
        R => or_gate_B,
        Q => pwm_chB
    ); 


    rst_channel_A : process(clk, rst, pwm_set)
    begin
        if rising_edge(clk) then
            or_gate_A <= rst or pwm_set;
        end if;

    end process;

    rst_channel_B : process(clk, rst, pwm_reset)
    begin
        if rising_edge(clk) then
            or_gate_A <= rst or pwm_reset;
        end if;

    end process;


end src;