-- vhdl-linter-disable not-declared

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library unisim;
  use unisim.vcomponents.all;

entity output_control is
  port (
    clk    : in    std_logic;
    rst    : in    std_logic;
    input  : in    std_logic;
    output : out   std_logic
  );
end entity output_control;

architecture src of output_control is

  constant ce          : std_logic                    := '0';             -- 1-bit input: Active high enable increment/decrement input
  constant inc         : std_logic                    := '0';             -- 1-bit input: Increment / Decrement tap delay input
  constant ld          : std_logic                    := '0';             -- 1-bit input: Load IDELAY_VALUE input
  constant ldpipeen    : std_logic                    := '0';             -- 1-bit input: Enable PIPELINE register to load data input
  constant regrst      : std_logic                    := '0';             -- 1-bit input: Active-high reset tap-delay input
  signal   cntvaluein  : std_logic_vector(4 downto 0) := (others => '0'); -- 5-bit input: Counter value input
  signal   cntvalueout : std_logic_vector(4 downto 0) := (others => '1'); -- 5-bit output: Counter value output
  signal   datain      : std_logic                    := '0';
  signal   dataout     : std_logic                    := '0';

begin

  d_trigger : process (clk, rst, input) is

    variable dq : std_logic := '0';

  begin

    if rising_edge(clk) then
      if (rst = '1') then        -- Synchronous reset
        dq := '0';
      else
        dq := input;
      end if;
    end if;

    datain <= dq;

  end process d_trigger;

  idelaye_inst : component idelaye2
    generic map (
      cinvctrl_sel          => "FALSE",
      delay_src             => "DATAIN",
      high_performance_mode => "FALSE",
      idelay_type           => "VAR_LOAD",
      idelay_value          => 0,
      pipe_sel              => "FALSE",
      refclk_frequency      => 200.0,
      signal_pattern        => "DATA"
    )
    port map (
      cntvalueout => cntvalueout,
      dataout     => dataout,
      c           => clk,
      ce          => CE,
      cinvctrl    => '0',
      cntvaluein  => cntvaluein,
      datain      => datain,
      idatain     => '1',
      inc         => INC,
      ld          => LD,
      ldpipeen    => LDPIPEEN,
      regrst      => REGRST
    );

  oout_buf : component obuf
    port map (
      o => output,
      i => dataout
    );

end architecture src;
