library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity tb_pwm_1ch is
--  Port ( );
end entity tb_pwm_1ch;

architecture tb of tb_pwm_1ch is

  constant clk_period           : time    := 10 ns;
  constant data_width           : integer := 7;
  constant num_dead_time_cycles : integer := 2;
  constant ref_type             : string  := "SYMMETRICAL";
  constant ref_init             : integer := -2 ** data_width / 2;
  constant ref_step             : integer := 1;
  constant input_data_type      : string  := "SIGNED";
  constant scale_factor         : real    := 0.8;
  constant offset_factor        : real    := 0.1;

  signal clk     : std_logic                                 := '0';
  signal rst     : std_logic                                 := '0';
  signal enable  : std_logic                                 := '0';
  signal data_in : std_logic_vector(data_width - 1 downto 0) := (others => '0');

  -- Two DUTs: classic complementary vs three-level bipolar split (same stimulus).
  signal p_comp   : std_logic := '0';
  signal p_n_comp : std_logic := '0';
  signal p_bi     : std_logic := '0';
  signal p_n_bi   : std_logic := '0';

  signal saw_pos_pwm_hi     : boolean := false;
  signal saw_neg_pwm_n_hi   : boolean := false;
  signal saw_pos_pwm_n_only : boolean := false;
  signal saw_neg_pwm_only   : boolean := false;

begin

  dut_sine : entity work.sine_gen_simple
    generic map (
      wave_length => 2048,
      bit_width   => data_width,
      data_type   => input_data_type
    )
    port map (
      clk         => clk,
      reset       => rst,
      output_data => data_in
    );

  pwm_comp : entity work.pwm_1ch
    generic map (
      r               => data_width,
      input_width     => data_width,
      d               => num_dead_time_cycles,
      ref_type        => ref_type,
      output_mode     => "COMPLEMENTARY",
      ref_init        => ref_init,
      ref_step        => ref_step,
      input_data_type => input_data_type,
      scale_factor    => scale_factor,
      offset_factor   => offset_factor,
      fp23_binary_point => data_width - 1
    )
    port map (
      clk        => clk,
      rst        => rst,
      enable     => enable,
      input_wave => data_in,
      pwm        => p_comp,
      pwm_n      => p_n_comp
    );

  pwm_bipolar : entity work.pwm_1ch
    generic map (
      r               => data_width,
      input_width     => data_width,
      d               => num_dead_time_cycles,
      ref_type        => ref_type,
      output_mode     => "BIPOLAR_SPLIT",
      ref_init        => ref_init,
      ref_step        => ref_step,
      input_data_type => input_data_type,
      scale_factor    => scale_factor,
      offset_factor   => offset_factor,
      fp23_binary_point => data_width - 1
    )
    port map (
      clk        => clk,
      rst        => rst,
      enable     => enable,
      input_wave => data_in,
      pwm        => p_bi,
      pwm_n      => p_n_bi
    );

  clk <= not clk after clk_period / 2;

  stim_proc : process is
  begin

    rst    <= '1';
    wait for clk_period * 2;
    rst    <= '0';
    wait for clk_period;
    enable <= '1';
    wait for 100 us;

    assert saw_pos_pwm_hi
      report "BIPOLAR_SPLIT: expected pwm high during positive half-cycle"
      severity failure;
    assert not saw_pos_pwm_n_only
      report "BIPOLAR_SPLIT: pwm_n must stay low during positive half-cycle"
      severity failure;
    assert not saw_neg_pwm_only
      report "BIPOLAR_SPLIT: pwm must stay low during negative half-cycle"
      severity failure;
    assert saw_neg_pwm_n_hi
      report "BIPOLAR_SPLIT: expected pwm_n high during negative half-cycle"
      severity failure;

    wait for clk_period;
    wait;

  end process stim_proc;

  bipolar_monitor : process (clk) is
    variable sample : integer;
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        saw_pos_pwm_hi   <= false;
        saw_neg_pwm_n_hi <= false;
      elsif (enable = '1') then
        sample := to_integer(signed(data_in));

        if (sample > 0) then
          if (p_bi = '1') then
            saw_pos_pwm_hi <= true;
          end if;
          if (p_n_bi = '1') then
            saw_pos_pwm_n_only <= true;
          end if;
        elsif (sample < 0) then
          if (p_bi = '1') then
            saw_neg_pwm_only <= true;
          end if;
          if (p_n_bi = '1') then
            saw_neg_pwm_n_hi <= true;
          end if;
        end if;
      end if;
    end if;
  end process bipolar_monitor;

end architecture tb;
