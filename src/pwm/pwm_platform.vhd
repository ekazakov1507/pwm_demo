library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library unisim;
  use unisim.vcomponents.all;

library unimacro;
  use unimacro.vcomponents.all;

entity pwm_platform is
  port (
    sys_clk          : in    std_logic;
    sys_pwm_channels : out   std_logic_vector(3 downto 0)
  );
end entity pwm_platform;

architecture src of pwm_platform is

  signal ibuf_clk        : std_logic := '0';
  signal gbuf_clk        : std_logic := '0';
  signal clk_mmcm_1      : std_logic := '0';
  signal clk_mmcm_2      : std_logic := '0';
  signal mmcm_clk_lock   : std_logic := '0';
  signal clk_mmcm_fb_out : std_logic;
  signal clk_mmcm_fb_in  : std_logic;

  signal table_cos_unsigned : std_logic_vector(6 downto 0) := (others => '0');
  signal table_cos_signed   : std_logic_vector(6 downto 0) := (others => '0');

  component cos_table_gen is
    port (
      clk                 : in    std_logic;
      reset               : in    std_logic;
      cosine_out_unsigned : out   std_logic_vector(6 downto 0);
      cosine_out_signed   : out   std_logic_vector(6 downto 0)
    );
  end component cos_table_gen;

  signal pwm_c_enable : std_logic                    := '0';
  signal pwm_ref_step : std_logic_vector(6 downto 0) := "0000001"; -- +1 PWM ref step;
  signal ref_reset    : std_logic                    := 'U';
  signal pwm_channels : std_logic_vector(3 downto 0) := (others => '0');

  signal delay                : std_logic_vector(4 downto 0) := (others => '0');
  signal pwm_channels_delayed : std_logic_vector(1 downto 0) := (others => '0');

  component pwm_c_dt is
    generic (
      r               : integer := 7;
      pwm_type        : string := "SAWTOOTH";
      input_data_type : string := "UNSIGNED";
      ref_init        : integer := 0
    );
    port (
      clk        : in    std_logic;
      rst        : in    std_logic;
      enable     : in    std_logic;
      input_wave : in    std_logic_vector(R - 1 downto 0);
      pwm        : out   std_logic;
      pwm_n      : out   std_logic
    );
  end component pwm_c_dt;

begin

  sys_clk_buffer : component ibuf
    port map (
      o => ibuf_clk,
      i => sys_clk
    );

  clk_gbuffer : component bufg
    port map (
      o => gbuf_clk,
      i => ibuf_clk
    );

  -- mmcm_feedback_buf : bufg
  --  port map (
  --    O => clk_mmcm_fb_out,
  --    I => clk_mmcm_fb_in
  --    );

  gen_pwm_obufs : for i in 0 to 1 generate

    pwm_channel_obuf : component obuf
      port map (
        o => sys_pwm_channels(i),
        i => pwm_channels_delayed(i)
      );

  end generate gen_pwm_obufs;

  mmcm_adv : component mmcme2_adv
    generic map (
      clkfbout_mult_f => 8.0,
      clkin1_period   => 8.0,
      clkin2_period   => 8.0,
      clkout1_phase   => 0.0,
      clkout1_divide  => 8,
      clkout2_phase   => 0.0,
      clkout2_divide  => 4
    )
    port map (
      clkinsel => '1',
      clkin1   => gbuf_clk,
      clkin2   => gbuf_clk,
      daddr    => "0000000",
      dclk     => '0',
      den      => '0',
      di       => x"0000",
      dwe      => '0',
      -- Dynamic Phase Shift Ports: 1-bit (each) input: Ports used for dynamic phase shifting of the outputs
      psclk    => '0',
      psen     => '0',
      psincdec => '0',
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      clkfbin  => clk_mmcm_fb_in,
      pwrdwn   => '0',
      rst      => '0',
      clkfbout => clk_mmcm_fb_in,
      clkout1  => clk_mmcm_1,
      clkout2  => clk_mmcm_2,
      locked   => mmcm_clk_lock
    );

  cos_tab_gen : component cos_table_gen
    port map (
      clk                 => clk_mmcm_2,
      reset               => '0',
      cosine_out_unsigned => table_cos_unsigned,
      cosine_out_signed   => table_cos_signed
    );

  pwm_ch0_delay : process (clk_mmcm_2, pwm_channels) is
  begin

    if rising_edge(clk_mmcm_2) then
      delay(0)                <= pwm_channels(0);
      delay(1)                <= delay(0);
      delay(2)                <= delay(1);
      delay(3)                <= delay(2);
      delay(4)                <= delay(3);
      pwm_channels_delayed(0) <= delay(4);
    end if;

  end process pwm_ch0_delay;

  pwm_ch1_delay : process (clk_mmcm_2, pwm_channels) is
  begin

    if rising_edge(clk_mmcm_2) then
      pwm_channels_delayed(1) <= pwm_channels(1);
    end if;

  end process pwm_ch1_delay;

  enable_control : process (clk_mmcm_1, mmcm_clk_lock) is
  begin

    if rising_edge(clk_mmcm_1) then
      if (mmcm_clk_lock = '1') then
        pwm_c_enable <= '1';
      end if;
    end if;

  end process enable_control;

  -- centered_pwm_01channels : entity work.pwm_c_unsigned
  --   port map (
  --     rst => '1',
  --     enable => pwm_c_enable,
  --     clk => clk_mmcm_2,
  --     input_wave => table_cos_unsigned,
  --     pwm => pwm_channels(0),
  --     pwm_n => pwm_channels(1)
  --     );

  -- centered_pwm_23channels : entity work.pwm_c_signed
  --   port map (
  --     rst => '1',
  --     enable => pwm_c_enable,
  --     clk => clk_mmcm_2,
  --     input_wave => table_cos_signed,
  --     pwm => pwm_channels(2),
  --     pwm_n => pwm_channels(3)
  --     );

  pwday : component pwm_c_dt
    -- pwday: entity work.pwm_c_dt
    generic map (
      r               => 7,
      ref_type        => "SYMMETRICAL",
      input_data_type => "SIGNED",
      ref_init        => 0
    )
    port map (
      clk        => clk_mmcm_2,
      rst        => '1',
      enable     => pwm_c_enable,
      input_wave => table_cos_signed,
      pwm        => pwm_channels(0),
      pwm_n      => pwm_channels(1)
    );

end architecture src;
