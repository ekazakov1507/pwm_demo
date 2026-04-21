library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity dead_time_generator is
  generic (
    r           : integer := 7;
    dead_time_d : integer := 2
  );
  port (
    clk       : in    std_logic;
    rst       : in    std_logic;
    pwm_in    : in    std_logic;
    pwm_n_in  : in    std_logic;
    pwm_out   : out   std_logic;
    pwm_n_out : out   std_logic
  );
end entity dead_time_generator;

architecture src of dead_time_generator is

  signal dead_active : boolean   := false;
  signal dead_timer  : unsigned(r - 1 downto 0) := (others => '0');
  signal pwm_in_prev : std_logic := '0';
  signal pwm_n_in_prev : std_logic := '0';
  signal pwm_latch   : std_logic := '0';
  signal pwm_n_latch : std_logic := '0';
  signal pwm_out_reg : std_logic := '0';
  signal pwm_n_out_reg : std_logic := '0';

begin

  dead_time_ctrl : process (clk) is
    variable req_changed : boolean;
  begin

    if rising_edge(clk) then
      if (rst = '1') then
        dead_active  <= false;
        dead_timer   <= (others => '0');
        pwm_in_prev  <= '0';
        pwm_n_in_prev <= '0';
        pwm_latch    <= '0';
        pwm_n_latch  <= '0';
        pwm_out_reg  <= '0';
        pwm_n_out_reg <= '0';
      else

        -- Detect changes on requested state only once per transition.
        req_changed := (pwm_in /= pwm_in_prev) or (pwm_n_in /= pwm_n_in_prev);

        -- Track latest requested state.
        pwm_in_prev   <= pwm_in;
        pwm_n_in_prev <= pwm_n_in;

        -- Start dead time only when the requested state changes.
        if req_changed then
          pwm_latch   <= pwm_in;
          pwm_n_latch <= pwm_n_in;

          if (dead_time_d = 0) then
            dead_active    <= false;
            dead_timer     <= (others => '0');
            pwm_out_reg    <= pwm_in;
            pwm_n_out_reg  <= pwm_n_in;
          else
            dead_timer     <= to_unsigned(dead_time_d - 1, r);
            dead_active    <= true;
            pwm_out_reg    <= '0';
            pwm_n_out_reg  <= '0';
          end if;
        elsif dead_active then
          -- During dead time: force both outputs low (safe state)
          pwm_out_reg   <= '0';
          pwm_n_out_reg <= '0';

          if dead_timer = 0 then
            -- Dead time expired: apply latched target state
            dead_active   <= false;
            pwm_out_reg   <= pwm_latch;
            pwm_n_out_reg <= pwm_n_latch;
          else
            dead_timer <= dead_timer - 1;
          end if;
        else
          pwm_out_reg   <= pwm_latch;
          pwm_n_out_reg <= pwm_n_latch;
        end if;

      end if;
    end if;

  end process dead_time_ctrl;

  pwm_out   <= pwm_out_reg;
  pwm_n_out <= pwm_n_out_reg;

end architecture src;
