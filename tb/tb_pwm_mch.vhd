library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity tb_pwm_mch is
--  Port ( );
end entity tb_pwm_mch;

architecture tb of tb_pwm_mch is

  constant clk_period           : time      := 10 ns;
  constant data_width           : integer   := 7;
  constant ref_init             : integer   := -2 ** data_width / 2;
  constant num_dead_time_cycles : integer   := 1;
  constant buffer_depth         : integer   := 256;
  constant num_channels         : integer   := 2;
  constant input_data_type      : string    := "SIGNED";
  constant ref_type             : string    := "SYMMETRICAL";
  constant ref_step             : integer   := 1;
  constant ref_updwn            : std_logic := '1';

  signal clk     : std_logic                                 := '0';
  signal clk_pwm : std_logic                                 := '0';
  signal rst     : std_logic                                 := '0';
  signal enable  : std_logic                                 := '0';
  signal data_in : std_logic_vector(data_width - 1 downto 0) := (others => '0');

  signal p        : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_n      : std_logic_vector(num_channels - 1 downto 0) := (others => '0');

  signal p_buf      : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal p_n_buf    : std_logic_vector(num_channels - 1 downto 0) := (others => '0');

  signal saw_simple_pwm_hi   : boolean := false;
  signal saw_simple_pwm_n_hi : boolean := false;
  signal saw_simple_both_on  : boolean := false;

  signal saw_buf_pwm_hi   : boolean := false;
  signal saw_buf_pwm_n_hi : boolean := false;
  signal saw_buf_both_on  : boolean := false;

begin

  dut_sine : entity work.sine_gen_simple
    generic map (
      wave_length => 1024,
      bit_width   => data_width,
      data_type   => input_data_type
    )
    port map (
      clk         => clk,
      reset       => rst,
      output_data => data_in
    );

  simple_pwm : entity work.pwm_mch
    generic map (
      r               => data_width,
      input_width     => data_width,
      d               => num_dead_time_cycles,
      num_channels    => num_channels,
      input_data_type => input_data_type,
      ref_type        => ref_type,
      ref_step        => ref_step,
      fp23_binary_point => data_width - 1
    )
    port map (
      clk        => clk,
      rst        => rst,
      enable     => enable,
      input_wave => data_in,
      pwm        => p,
      pwm_n      => p_n
    );

  adv_pwm : entity work.pwm_mch_buf
    generic map (
      r               => data_width,
      d               => num_dead_time_cycles,
      num_channels    => num_channels,
      ref_type        => ref_type,
      input_data_type => input_data_type,
      buffer_depth    => buffer_depth,
      ref_step        => ref_step,
      ref_updwn       => ref_updwn
    )
    port map (
      clk        => clk,
      clk_pwm    => clk_pwm,
      rst        => rst,
      enable     => enable,
      input_wave => data_in,
      pwm        => p_buf,
      pwm_n      => p_n_buf
    );

  clk <= not clk after clk_period / 2;

  -- Symmetric PWM + pwm_mch_buf expect faster pwm clock (2x main clk here).
  clk_pwm <= not clk_pwm after clk_period / 4;

  stim_proc : process is
  begin

    rst    <= '1';
    wait for clk_period * 2;
    rst    <= '0';
    wait for clk_period;
    enable <= '1';
    wait for 250 us;

    assert saw_simple_pwm_hi
      report "pwm_mch: expected pwm activity"
      severity failure;
    assert saw_simple_pwm_n_hi
      report "pwm_mch: expected pwm_n activity"
      severity failure;
    assert not saw_simple_both_on
      report "pwm_mch: pwm and pwm_n must not be high together"
      severity failure;

    assert saw_buf_pwm_hi
      report "pwm_mch_buf: expected pwm activity"
      severity failure;
    assert saw_buf_pwm_n_hi
      report "pwm_mch_buf: expected pwm_n activity"
      severity failure;
    assert not saw_buf_both_on
      report "pwm_mch_buf: pwm and pwm_n must not be high together"
      severity failure;

    wait for clk_period;
    wait;

  end process stim_proc;

  complementary_monitor : process (clk) is
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        saw_simple_pwm_hi   <= false;
        saw_simple_pwm_n_hi <= false;
        saw_simple_both_on  <= false;
      elsif (enable = '1') then
        if (p(0) = '1') then
          saw_simple_pwm_hi <= true;
        end if;
        if (p_n(0) = '1') then
          saw_simple_pwm_n_hi <= true;
        end if;
        if ((p(0) = '1') and (p_n(0) = '1')) then
          saw_simple_both_on <= true;
        end if;
      end if;
    end if;
  end process complementary_monitor;

  complementary_buf_monitor : process (clk_pwm) is
  begin
    if rising_edge(clk_pwm) then
      if (rst = '1') then
        saw_buf_pwm_hi   <= false;
        saw_buf_pwm_n_hi <= false;
        saw_buf_both_on  <= false;
      elsif (enable = '1') then
        if (p_buf(0) = '1') then
          saw_buf_pwm_hi <= true;
        end if;
        if (p_n_buf(0) = '1') then
          saw_buf_pwm_n_hi <= true;
        end if;
        if ((p_buf(0) = '1') and (p_n_buf(0) = '1')) then
          saw_buf_both_on <= true;
        end if;
      end if;
    end if;
  end process complementary_buf_monitor;

end architecture tb;
