library ieee;
  use ieee.std_logic_1164.all;

entity tb_main is
--  Port ( );
end entity tb_main;

architecture tb of tb_main is

  constant clk_period : time := 8 ns;

  constant num_channels                 : integer := 4;
  constant pwm_mode_switch_delay_cycles : natural := 256;
  constant pwm_zero                     : std_logic_vector(num_channels - 1 downto 0) := (others => '0');

  signal sys_clk      : std_logic := '0';
  signal sys_rst      : std_logic := '0';
  signal sys_pwm_mode : std_logic := '0';

  signal sys_pwm   : std_logic_vector(num_channels - 1 downto 0) := (others => '0');
  signal sys_pwm_n : std_logic_vector(num_channels - 1 downto 0) := (others => '0');

  signal test_phase         : integer range 0 to 3 := 0;
  signal saw_mode0_activity : boolean := false;
  signal saw_mode1_activity : boolean := false;
  signal saw_switch_blank   : boolean := false;

begin

  main_pwm_demo : entity work.main
    generic map (
      num_channels                 => num_channels,
      pwm_mode_switch_delay_cycles => pwm_mode_switch_delay_cycles
    )
    port map (
      sys_clk      => sys_clk,
      sys_rst      => sys_rst,
      sys_pwm_mode => sys_pwm_mode,
      sys_pwm      => sys_pwm,
      sys_pwm_n    => sys_pwm_n
    );

  sys_clk <= not sys_clk after clk_period / 2;

  stim_proc : process is
  begin

    wait for 1 us;

    sys_rst <= '1';
    test_phase <= 0;
    wait for 2 us;
    assert ((sys_pwm = pwm_zero) and (sys_pwm_n = pwm_zero))
      report "main: expected outputs blanked while sys_rst is asserted"
      severity failure;

    sys_pwm_mode <= '0';
    sys_rst      <= '0';
    test_phase   <= 1;
    wait for 12 us;
    assert saw_mode0_activity
      report "main: expected direct pwm_mch activity in mode 0"
      severity failure;

    if ((sys_pwm = pwm_zero) and (sys_pwm_n = pwm_zero)) then
      wait until ((sys_pwm /= pwm_zero) or (sys_pwm_n /= pwm_zero));
    end if;

    sys_pwm_mode <= '1';
    test_phase   <= 2;
    wait for 500 ns;
    assert ((sys_pwm = pwm_zero) and (sys_pwm_n = pwm_zero))
      report "main: expected outputs blanked during delayed runtime mode switch"
      severity failure;

    wait for 2 us;
    assert saw_switch_blank
      report "main: expected a blanking interval after runtime mode switch"
      severity failure;

    test_phase <= 3;
    wait for 15 us;
    assert saw_mode1_activity
      report "main: expected buffered pwm_mch_buf activity in mode 1"
      severity failure;

    wait;

  end process stim_proc;

  activity_monitor : process (sys_pwm, sys_pwm_n, test_phase) is
  begin

    if ((sys_pwm = pwm_zero) and (sys_pwm_n = pwm_zero)) then
      if (test_phase = 2) then
        saw_switch_blank <= true;
      end if;
    else
      if (test_phase = 1) then
        saw_mode0_activity <= true;
      elsif (test_phase = 3) then
        saw_mode1_activity <= true;
      end if;
    end if;

  end process activity_monitor;

end architecture tb;

