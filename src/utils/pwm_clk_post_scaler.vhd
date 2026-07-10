library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity pwm_clk_post_scaler is
  port (
    clk     : in    std_logic;
    rst     : in    std_logic;
    div_sel : in    std_logic_vector(1 downto 0);
    tick_ce : out   std_logic
  );
end entity pwm_clk_post_scaler;

architecture src of pwm_clk_post_scaler is

  constant max_divider : natural := 16;

  signal count_reg : natural range 0 to max_divider - 1 := 0;
  signal tick_reg  : std_logic := '0';

  function divider_for_sel (
    value : std_logic_vector(1 downto 0)
  ) return natural is
  begin
    case value is
      when "00" =>
        return 2;
      when "01" =>
        return 4;
      when "10" =>
        return 8;
      when others =>
        return 16;
    end case;
  end function divider_for_sel;

begin

  tick_ce <= tick_reg;

  tick_gen : process (clk) is
    variable selected_divider : natural range 2 to max_divider;
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        count_reg <= 0;
        tick_reg  <= '0';
      else
        selected_divider := divider_for_sel(div_sel);
        tick_reg <= '0';

        if (count_reg = selected_divider - 1) then
          count_reg <= 0;
          tick_reg  <= '1';
        else
          count_reg <= count_reg + 1;
        end if;
      end if;
    end if;
  end process tick_gen;

end architecture src;
