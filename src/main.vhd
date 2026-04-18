library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library unisim;
  use unisim.vcomponents.all;

entity main is
  generic (
    num_channels : integer := 4
  );
  port (
    sys_clk   : in    std_logic;
    sys_pwm   : out   std_logic_vector(num_channels - 1 downto 0);
    sys_pwm_n : out   std_logic_vector(num_channels - 1 downto 0)
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

  signal obuf_clk  : std_logic := '0';
  signal gobuf_clk : std_logic := '0';

  signal mmcm_fb_in    : std_logic := '0';
  signal mmcm_clk_lock : std_logic := '0';

  signal clk      : std_logic                                 := '0';
  signal clk_pwm  : std_logic                                 := '0';
  signal rst      : std_logic                                 := '1';
  signal mmcm_lock_sync : std_logic_vector(1 downto 0)      := "00";
  signal rst_shreg      : std_logic_vector(2 downto 0)      := (others => '1');
  signal enable   : std_logic                                 := '1';
  signal sine_out : std_logic_vector(data_width - 1 downto 0) := (others => '0');

  signal p_buf   : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_n_buf : std_logic_vector(num_channels - 1 downto 0) := (others => '0');

begin

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

  adv_pwm : entity work.pwm_mch_buf
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

  pwm_obufs : for i in 0 to num_channels - 1 generate

    pwm_channel_obuf : component obuf
      port map (
        i => p_buf(i),
        o => sys_pwm(i)
      );

    pwm_n_channel_obuf : component obuf
      port map (
        i => p_n_buf(i),
        o => sys_pwm_n(i)
      );

  end generate pwm_obufs;

  -- MMCM lock synchronized into clk domain; reset re-asserts if lock is lost.
  rst_gen : process (clk) is
  begin

    if rising_edge(clk) then
      mmcm_lock_sync <= mmcm_lock_sync(0) & mmcm_clk_lock;
      if (mmcm_lock_sync(1) = '0') then
        rst_shreg <= (others => '1');
      else
        rst_shreg <= rst_shreg(1 downto 0) & '0';
      end if;
      rst <= rst_shreg(2);
    end if;

  end process rst_gen;

end architecture src;
