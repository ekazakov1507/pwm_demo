library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library unisim;
  use unisim.vcomponents.all;

entity main is
  generic (
    num_channels : integer := 4;
    debug        : string  := "NO_DEBUG"
  );
  port (
    sys_clk      : in    std_logic;
    sys_rst      : in    std_logic;
    sys_pwm_mode : in    std_logic;
    sys_pwm      : out   std_logic_vector(num_channels - 1 downto 0);
    sys_pwm_n    : out   std_logic_vector(num_channels - 1 downto 0)
  );
end entity main;

architecture src of main is

  constant data_width           : integer   := 6;
  constant num_dead_time_cycles : integer   := 4;
  constant buffer_depth         : integer   := 1024;
  constant wave_length          : integer   := 2048;
  constant input_data_type      : string    := "SIGNED";
  constant ref_type             : string    := "SYMMETRICAL";
  constant ref_step             : integer   := 1;
  constant ref_updwn            : std_logic := '1';
  constant pwm_idle             : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  constant debug_probe_width    : integer   := 4;

  function resize_pwm_debug_probe (
    input_value : std_logic_vector
  ) return std_logic_vector is
    variable result     : std_logic_vector(debug_probe_width - 1 downto 0) := (others => '0');
    variable copy_width : integer := 0;
  begin

    if (input_value'length < debug_probe_width) then
      copy_width := input_value'length;
    else
      copy_width := debug_probe_width;
    end if;

    for i in 0 to copy_width - 1 loop
      result(i) := input_value(input_value'low + i);
    end loop;

    return result;

  end function resize_pwm_debug_probe;

  component pwm_mch is
    generic (
      r                 : integer := 7;
      input_width       : integer := 7;
      d                 : integer := 2;
      num_channels      : integer := 2;
      input_data_type   : string  := "SIGNED";
      ref_type          : string  := "SYMMETRICAL";
      output_mode       : string  := "COMPLEMENTARY";
      ref_step          : integer := 1;
      scale_factor      : real    := 0.8;
      offset_factor     : real    := 0.1;
      fp23_binary_point : integer := 6
    );
    port (
      clk        : in    std_logic;
      rst        : in    std_logic;
      enable     : in    std_logic;
      input_wave : in    std_logic_vector(input_width - 1 downto 0);
      pwm        : out   std_logic_vector(num_channels - 1 downto 0);
      pwm_n      : out   std_logic_vector(num_channels - 1 downto 0)
    );
  end component pwm_mch;

  component pwm_mch_buf is
    generic (
      r               : integer   := 7;
      d               : integer   := 2;
      num_channels    : integer   := 2;
      input_data_type : string    := "SIGNED";
      buffer_depth    : integer   := 1024;
      ref_type        : string    := "SYMMETRICAL";
      output_mode     : string    := "COMPLEMENTARY";
      ref_step        : integer   := 1;
      ref_updwn       : std_logic := '1';
      clk_freq_hz     : integer   := 100_000_000;
      clk_pwm_freq_hz : integer   := 200_000_000
    );
    port (
      clk        : in    std_logic;
      clk_pwm    : in    std_logic;
      rst        : in    std_logic;
      enable     : in    std_logic;
      input_wave : in    std_logic_vector(r - 1 downto 0);
      pwm        : out   std_logic_vector(num_channels - 1 downto 0);
      pwm_n      : out   std_logic_vector(num_channels - 1 downto 0)
    );
  end component pwm_mch_buf;

  component vio_pwm_debug is
    port (
      clk        : in    std_logic;
      probe_out0 : out   std_logic_vector(0 downto 0);
      probe_out1 : out   std_logic_vector(0 downto 0)
    );
  end component vio_pwm_debug;

  component ila_pwm_debug is
    port (
      clk    : in    std_logic;
      probe0 : in    std_logic_vector(0 downto 0);
      probe1 : in    std_logic_vector(0 downto 0);
      probe2 : in    std_logic_vector(0 downto 0);
      probe3 : in    std_logic_vector(0 downto 0);
      probe4 : in    std_logic_vector(0 downto 0);
      probe5 : in    std_logic_vector(0 downto 0);
      probe6 : in    std_logic_vector(debug_probe_width - 1 downto 0);
      probe7 : in    std_logic_vector(debug_probe_width - 1 downto 0)
    );
  end component ila_pwm_debug;

  signal obuf_clk  : std_logic := '0';
  signal gobuf_clk : std_logic := '0';

  signal mmcm_fb_in    : std_logic := '0';
  signal mmcm_clk_lock : std_logic := '0';

  signal clk            : std_logic                                 := '0';
  signal clk_pwm        : std_logic                                 := '0';
  signal rst            : std_logic                                 := '1';
  signal rst_request    : std_logic                                 := '0';
  signal mmcm_lock_sync : std_logic_vector(1 downto 0)             := "00";
  signal sys_rst_sync   : std_logic_vector(1 downto 0)             := "11";
  signal rst_shreg      : std_logic_vector(2 downto 0)             := (others => '1');
  signal enable         : std_logic                                 := '1';
  signal pwm_mode_sync  : std_logic_vector(2 downto 0)             := "000";
  signal pwm_mode_request : std_logic                               := '0';
  signal pwm_mode_sel   : std_logic                                 := '0';
  signal sine_out       : std_logic_vector(data_width - 1 downto 0) := (others => '0');

  signal p_direct   : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_n_direct : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_buf      : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_n_buf    : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_selected : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_n_selected : std_logic_vector(num_channels - 1 downto 0) := (others => '0');

  signal vio_rst_force      : std_logic_vector(0 downto 0) := (others => '0');
  signal vio_pwm_mode_force : std_logic_vector(0 downto 0) := (others => '0');

  signal debug_probe_sys_rst          : std_logic_vector(0 downto 0) := (others => '0');
  signal debug_probe_rst_request      : std_logic_vector(0 downto 0) := (others => '0');
  signal debug_probe_rst              : std_logic_vector(0 downto 0) := (others => '0');
  signal debug_probe_sys_pwm_mode     : std_logic_vector(0 downto 0) := (others => '0');
  signal debug_probe_pwm_mode_request : std_logic_vector(0 downto 0) := (others => '0');
  signal debug_probe_pwm_mode_sel     : std_logic_vector(0 downto 0) := (others => '0');
  signal debug_probe_p_selected       : std_logic_vector(debug_probe_width - 1 downto 0) := (others => '0');
  signal debug_probe_p_n_selected     : std_logic_vector(debug_probe_width - 1 downto 0) := (others => '0');

begin

  debug_value_valid : assert ((debug = "NO_DEBUG") or (debug = "DEBUG"))
    report "main: debug generic must be NO_DEBUG or DEBUG"
    severity failure;

  sys_clk_ibuffer : component ibuf
    port map (
      i => sys_clk,
      o => obuf_clk
    );

  clk_gbuffer : component bufg
    port map (
      i => obuf_clk,
      o => gobuf_clk
    );

  mmcm_adv : component mmcme2_adv
    generic map (
      clkfbout_mult_f => 8.0,
      clkin1_period   => 8.0,
      clkin2_period   => 8.0,
      clkout1_phase   => 0.0,
      clkout1_divide  => 16,
      clkout2_phase   => 0.0,
      clkout2_divide  => 8
    )
    port map (
      clkinsel => '1',
      clkin1   => gobuf_clk,
      clkin2   => gobuf_clk,
      daddr    => "0000000",
      dclk     => '0',
      den      => '0',
      di       => x"0000",
      dwe      => '0',
      psclk    => '0',
      psen     => '0',
      psincdec => '0',
      clkfbin  => mmcm_fb_in,
      pwrdwn   => '0',
      rst      => '0',
      clkfbout => mmcm_fb_in,
      clkout1  => clk,
      clkout2  => clk_pwm,
      locked   => mmcm_clk_lock
    );

  dut_sine : entity work.sine_gen_simple
    generic map (
      wave_length => wave_length,
      bit_width   => data_width,
      data_type   => input_data_type
    )
    port map (
      clk         => clk,
      reset       => rst,
      output_data => sine_out
    );

  direct_pwm : component pwm_mch
    generic map (
      r                 => DATA_WIDTH,
      input_width       => DATA_WIDTH,
      d                 => NUM_DEAD_TIME_CYCLES,
      num_channels      => num_channels,
      input_data_type   => INPUT_DATA_TYPE,
      ref_type          => REF_TYPE,
      ref_step          => REF_STEP,
      fp23_binary_point => DATA_WIDTH - 1
    )
    port map (
      clk        => clk,
      rst        => rst,
      enable     => enable,
      input_wave => sine_out,
      pwm        => p_direct,
      pwm_n      => p_n_direct
    );

  buffered_pwm : component pwm_mch_buf
    generic map (
      r               => DATA_WIDTH,
      d               => NUM_DEAD_TIME_CYCLES,
      num_channels    => num_channels,
      ref_type        => REF_TYPE,
      input_data_type => INPUT_DATA_TYPE,
      buffer_depth    => BUFFER_DEPTH,
      ref_step        => REF_STEP,
      ref_updwn       => ref_updwn
    )
    port map (
      clk        => clk,
      clk_pwm    => clk_pwm,
      rst        => rst,
      enable     => enable,
      input_wave => sine_out,
      pwm        => p_buf,
      pwm_n      => p_n_buf
    );

  p_selected   <= pwm_idle when (rst = '1') else p_buf when (pwm_mode_sel = '1') else p_direct;
  p_n_selected <= pwm_idle when (rst = '1') else p_n_buf when (pwm_mode_sel = '1') else p_n_direct;

  rst_request      <= sys_rst or vio_rst_force(0);
  pwm_mode_request <= sys_pwm_mode or vio_pwm_mode_force(0);

  debug_probe_sys_rst(0)          <= sys_rst;
  debug_probe_rst_request(0)      <= rst_request;
  debug_probe_rst(0)              <= rst;
  debug_probe_sys_pwm_mode(0)     <= sys_pwm_mode;
  debug_probe_pwm_mode_request(0) <= pwm_mode_request;
  debug_probe_pwm_mode_sel(0)     <= pwm_mode_sel;
  debug_probe_p_selected          <= resize_pwm_debug_probe(p_selected);
  debug_probe_p_n_selected        <= resize_pwm_debug_probe(p_n_selected);

  no_debug_gen : if debug = "NO_DEBUG" generate
  begin

    vio_rst_force      <= (others => '0');
    vio_pwm_mode_force <= (others => '0');

  end generate no_debug_gen;

  debug_gen : if debug = "DEBUG" generate
  begin

    debug_vio : component vio_pwm_debug
      port map (
        clk        => clk,
        probe_out0 => vio_rst_force,
        probe_out1 => vio_pwm_mode_force
      );

    debug_ila : component ila_pwm_debug
      port map (
        clk    => clk,
        probe0 => debug_probe_sys_rst,
        probe1 => debug_probe_rst_request,
        probe2 => debug_probe_rst,
        probe3 => debug_probe_sys_pwm_mode,
        probe4 => debug_probe_pwm_mode_request,
        probe5 => debug_probe_pwm_mode_sel,
        probe6 => debug_probe_p_selected,
        probe7 => debug_probe_p_n_selected
      );

  end generate debug_gen;

  pwm_obufs : for i in 0 to num_channels - 1 generate

    pwm_channel_obuf : component obuf
      port map (
        i => p_selected(i),
        o => sys_pwm(i)
      );

    pwm_n_channel_obuf : component obuf
      port map (
        i => p_n_selected(i),
        o => sys_pwm_n(i)
      );

  end generate pwm_obufs;

  rst <= rst_shreg(2);

  -- Keep reset fully synchronous in the MMCM output clock domain so
  -- downstream BRAM control signals are not driven by async-reset flops.
  rst_gen : process (clk) is
  begin

    if rising_edge(clk) then
      mmcm_lock_sync <= mmcm_lock_sync(0) & mmcm_clk_lock;
      sys_rst_sync   <= sys_rst_sync(0) & rst_request;
      pwm_mode_sync  <= pwm_mode_sync(1 downto 0) & pwm_mode_request;

      if ((mmcm_lock_sync(1) = '0') or
          (sys_rst_sync(1) = '1') or
          (pwm_mode_sync(2) /= pwm_mode_sel)) then
        rst_shreg <= (others => '1');
      else
        rst_shreg <= rst_shreg(1 downto 0) & '0';
      end if;

      if ((mmcm_lock_sync(1) = '0') or
          (sys_rst_sync(1) = '1') or
          (pwm_mode_sync(2) /= pwm_mode_sel)) then
        pwm_mode_sel <= pwm_mode_sync(2);
      end if;
    end if;

  end process rst_gen;

end architecture src;
