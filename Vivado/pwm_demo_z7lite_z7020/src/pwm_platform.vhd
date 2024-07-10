library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;
library UNIMACRO;
use unimacro.Vcomponents.all;

entity pwm_platform is
	port ( 
	  sys_clk : in std_logic;
    sys_pwm_channels : out std_logic_vector(1 downto 0)
	);
end pwm_platform;

architecture src of pwm_platform is

  signal ibuf_clk : std_logic := '0';
  signal gbuf_clk : std_logic := '0';
  signal clk_mmcm_1 : std_logic := '0';
  signal clk_mmcm_2 : std_logic := '0';
  signal mmcm_clk_lock : std_logic := '0';
  signal clk_mmcm_fb_out : std_logic ; 
  signal clk_mmcm_fb_in : std_logic ;

  signal angle_cos : std_logic_vector(10 downto 0) := (others => '0');
  signal table_cos : std_logic_vector(6 downto 0) := (others => '0');
  component cos_table_gen is
    port (
      clk : in std_logic;
      reset : in std_logic;
      angle : in std_logic_vector(10 downto 0);
      cosine_out : out std_logic_vector(6 downto 0)
    );
  end component cos_table_gen;
  
  signal pwm_c_enable : std_logic := '0';
  signal pwm_ref_step : std_logic_vector(6 downto 0) := "0000001"; -- +1 PWM ref step;
  signal ref_reset : std_logic := 'U';
  signal pwm_channels : std_logic_vector(1 downto 0) := (others => '0');
  
  signal delay : std_logic_vector(4 downto 0) := (others => '0');
  signal pwm_channels_delayed : std_logic_vector(1 downto 0) := (others => '0');

  --component pwm_l is
  --  port (
  --      enable : in std_logic;
  --      clk : in std_logic;
  --      modulated_wave : in std_logic_vector;
  --      counter_step : in std_logic_vector;
  --      counter_reset : in std_logic;
  --      pwm : out std_logic;
  --      pwm_i : out std_logic
  --    );
  --end component pwm_l;

  component pwm_c is
    port (
        enable : in std_logic;
        clk : in std_logic;
        modulated_wave : in std_logic_vector;
        counter_step : in std_logic_vector;
        counter_reset : in std_logic;
        pwm : out std_logic;
        pwm_i : out std_logic
      );
  end component pwm_c;

begin

  sys_clk_buffer : ibuf          
    port map (     
      O => ibuf_clk,    
      I => sys_clk  
    ); 

  clk_gbuffer: bufg    
    port map (     
      O => gbuf_clk,    
      I => ibuf_clk  
    ); 

  --mmcm_feedback_buf : bufg
  --  port map (
  --    O => clk_mmcm_fb_out,
  --    I => clk_mmcm_fb_in
  --    );

  gen_pwm_obufs: for i in 0 to 1 generate 
     pwm_channel_obuf: obuf
     port map (
        O => sys_pwm_channels(i),  
        I => pwm_channels_delayed(i) 
      ); 
  end generate; 

  MMCM_ADV : MMCME2_ADV
    generic map (
      CLKFBOUT_MULT_F => 15.0,
      CLKIN1_PERIOD => 20.0,
      CLKIN2_PERIOD => 20.0, 
      CLKOUT1_PHASE => 0.0,
      CLKOUT1_DIVIDE => 8,
      CLKOUT2_PHASE => 0.0,
      CLKOUT2_DIVIDE => 3
    )
    port map (             
      CLKINSEL => '1',
      CLKIN1   => gbuf_clk,
      CLKIN2   => gbuf_clk,
      DADDR    => "0000000",
      DCLK => '0',
      DEN => '0',
      DI => x"0000", 
      DWE => '0',
        -- Dynamic Phase Shift Ports: 1-bit (each) input: Ports used for dynamic phase shifting of the outputs
      PSCLK => '0', -- 1-bit input: Phase shift clock
      PSEN => '0', -- 1-bit input: Phase shift enable
      PSINCDEC => '0', -- 1-bit input: Phase shift increment/decrement
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN => clk_mmcm_fb_in, -- 1-bit input: Feedback clock
        PWRDWN   => '0', 
        RST      => '0',
        CLKFBOUT => clk_mmcm_fb_in,
      CLKOUT1 => clk_mmcm_1,
      CLKOUT2 => clk_mmcm_2,
      LOCKED => mmcm_clk_lock
    );

  costabgen : cos_table_gen
    port map (
      clk => clk_mmcm_2,
      reset => '0',
      angle => angle_cos,
      cosine_out => table_cos
    );

  pwm_ch0_delay : process(clk_mmcm_2, pwm_channels)
    begin
      if rising_edge(clk_mmcm_2) then 
        delay(0) <= pwm_channels(0);
        delay(1) <= delay(0);
        delay(2) <= delay(1);
        delay(3) <= delay(2);
        delay(4) <= delay(3);
        pwm_channels_delayed(0) <= delay(4);
      end if;
  end process;

  pwm_ch1_delay : process(clk_mmcm_2, pwm_channels)
    begin
      if rising_edge(clk_mmcm_2) then
        pwm_channels_delayed(1) <= pwm_channels(1);
      end if;
  end process;

  cosine_generator : process(clk_mmcm_2, angle_cos)
      variable angle_reset : std_logic := '0';
      variable angle_updown : std_logic := '0';
    begin
      if rising_edge(clk_mmcm_2) then
        if angle_reset = '1' then
          angle_cos <= b"00000000000";
          angle_updown := '1';
        elsif angle_updown = '1' and angle_cos < b"10011100001" then
          angle_cos <= std_logic_vector(unsigned(angle_cos) + b"00000000001");
        elsif angle_updown = '0' and angle_cos > b"00000000000" then
          angle_cos <= std_logic_vector(unsigned(angle_cos) - b"00000000001");
        elsif angle_cos = b"00000000000" then
          angle_updown := '1';
          angle_cos <= std_logic_vector(unsigned(angle_cos) + b"00000000001");
        elsif angle_cos = b"10011100001" then
          angle_updown := '0';
          angle_cos <= std_logic_vector(unsigned(angle_cos) - b"00000000001");
        end if;
      end if;
  end process;

  enable_control : process(clk_mmcm_1, mmcm_clk_lock) 
      begin
        if rising_edge(clk_mmcm_1) then
          if mmcm_clk_lock = '1' then
            pwm_c_enable <= '1';
          end if;
        end if;
  end process;

  centered_pwm_1channel : pwm_c
    port map (
      enable => pwm_c_enable,
      clk => clk_mmcm_2,
      modulated_wave => table_cos,
      counter_step => pwm_ref_step,
      counter_reset => ref_reset,
      pwm => pwm_channels(0),
      pwm_i => pwm_channels(1)
      );

end src;
