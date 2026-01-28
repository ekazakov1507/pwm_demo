library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity pwm_1ch is
  generic (
    r               : integer   := 7;             -- PWM resolution bits
    d               : integer   := 2;             -- Num dead-time cycles
    input_data_type : string    := "SIGNED";      -- signed or unsigned
    ref_type        : string    := "SYMMETRICAL"; -- Symmetrical and Asymmetrical
    scale_factor    : real      := 0.8;
    offset_factor   : real      := 0.1;
    ref_init        : integer   := 0;
    ref_step        : integer   := 1;
    ref_updwn       : std_logic := '1'
  );
  port (
    clk        : in    std_logic;
    rst        : in    std_logic;
    enable     : in    std_logic;
    input_wave : in    std_logic_vector(r - 1 downto 0);
    pwm        : out   std_logic;
    pwm_n      : out   std_logic
  );
end entity pwm_1ch;

architecture src of pwm_1ch is

  function get_start_value return integer is
  begin

    if (INPUT_DATA_TYPE = "UNSIGNED") then
      return 0;
    elsif (INPUT_DATA_TYPE = "SIGNED") then
      return -2 ** R / 2;
    end if;

  end function get_start_value;

  function get_stop_value return integer is
  begin

    if (INPUT_DATA_TYPE = "UNSIGNED") then
      return 2 ** R - 1;
    elsif (INPUT_DATA_TYPE = "SIGNED") then
      return 2 ** R / 2 - 1;
    end if;

  end function get_stop_value;

  constant start  : integer   := get_start_value;
  constant stop   : integer   := get_stop_value;
  constant step   : integer   := ref_step;
  constant updown : std_logic := ref_updwn;

  signal input_reg    : std_logic_vector(r - 1 downto 0) := (others => '0');
  signal scaled_input : std_logic_vector(r - 1 downto 0) := (others => '0');
  signal counter      : std_logic_vector(r - 1 downto 0) := (others => '0');

  signal pwm_state   : std_logic := '0';
  signal pwm_n_state : std_logic := '0';

  signal q_set   : std_logic := '0';
  signal q_reset : std_logic := '0';

begin

  set_pwm_s_unsigned : if (REF_TYPE = "ASYMMETRICAL" and INPUT_DATA_TYPE = "UNSIGNED") generate

    cnt : entity work.up_counter_unsigned
      generic map (
        r     => r,
        init  => ref_init,
        start => START,
        stop  => STOP,
        step  => STEP
      )
      port map (
        clk    => clk,
        rst    => rst,
        enable => enable,
        cnt    => counter
      );

  end generate set_pwm_s_unsigned;

  set_pwm_s_signed : if (REF_TYPE = "ASYMMETRICAL" and INPUT_DATA_TYPE = "SIGNED") generate

    cnt : entity work.up_counter_signed
      generic map (
        r     => r,
        init  => ref_init,
        start => START,
        stop  => STOP,
        step  => STEP
      )
      port map (
        clk    => clk,
        rst    => rst,
        enable => enable,
        cnt    => counter
      );

  end generate set_pwm_s_signed;

  set_pwm_t_unsigned : if (REF_TYPE = "SYMMETRICAL" and INPUT_DATA_TYPE = "UNSIGNED") generate

    cnt : entity work.updown_counter_unsigned
      generic map (
        r      => r,
        init   => ref_init,
        start  => START,
        stop   => STOP,
        step   => STEP,
        updown => updown
      )
      port map (
        clk    => clk,
        rst    => rst,
        enable => enable,
        cnt    => counter
      );

  end generate set_pwm_t_unsigned;

  set_pwm_t_signed : if (REF_TYPE = "SYMMETRICAL" and INPUT_DATA_TYPE = "SIGNED") generate

    cnt : entity work.updown_counter_signed
      generic map (
        r      => r,
        init   => ref_init,
        start  => START,
        stop   => STOP,
        step   => STEP,
        updown => updown
      )
      port map (
        clk    => clk,
        rst    => rst,
        enable => enable,
        cnt    => counter
      );

  end generate set_pwm_t_signed;

  set_scaler_type_signed : if INPUT_DATA_TYPE = "SIGNED" generate

    rsc : entity work.scaler_signed
      generic map (
        r            => r,
        scale_factor => scale_factor + offset_factor
      )
      port map (
        clk         => clk,
        reset       => rst,
        input_data  => input_reg,
        output_data => scaled_input
      );

  end generate set_scaler_type_signed;

  set_scaler_type_unsigned : if INPUT_DATA_TYPE = "UNSIGNED" generate

    rsc : entity work.scaler_unsigned
      generic map (
        r             => r,
        scale_factor  => scale_factor,
        offset_factor => offset_factor
      )
      port map (
        clk         => clk,
        reset       => rst,
        input_data  => input_reg,
        output_data => scaled_input
      );

  end generate set_scaler_type_unsigned;

  dead_time_control_p : entity work.edge_delay
    generic map (
      r => r,
      d => d
    )
    port map (
      clk    => clk,
      input  => pwm_state,
      output => pwm
    );

  dead_time_control_n : entity work.edge_delay
    generic map (
      r => r,
      d => d
    )
    port map (
      clk    => clk,
      input  => pwm_n_state,
      output => pwm_n
    );

  input_control : process (clk, rst, input_wave) is
  begin

    if rising_edge(clk) then
      if (rst = '1') then
        input_reg <= (others => '0');
      elsif (rst = '0') then
        input_reg <= input_wave;
      end if;
    end if;

  end process input_control;

  pwm_set_control : process (clk, rst, counter, scaled_input) is
  begin

    if rising_edge(clk) then
      if (rst = '1') then
        pwm_state   <= '0';
        pwm_n_state <= '1';
      -- counter <= b"0000000";
      else
        if (counter >= scaled_input) then
          pwm_state   <= '1';
          pwm_n_state <= '0';
        else
          pwm_state   <= '0';
          pwm_n_state <= '1';
        end if;
      end if;
    end if;

  end process pwm_set_control;

end architecture src;
