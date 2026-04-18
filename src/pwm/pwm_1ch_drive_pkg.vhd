library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

package pwm_1ch_drive_pkg is

  type pwm_leg_pair is record
    pwm   : std_logic;
    pwm_n : std_logic;
  end record pwm_leg_pair;

  function drive_complementary_signed (
    counter_vec : std_logic_vector;
    ref_vec     : std_logic_vector
  ) return pwm_leg_pair;

  function drive_complementary_unsigned (
    counter_vec : std_logic_vector;
    ref_vec     : std_logic_vector
  ) return pwm_leg_pair;

  function drive_bipolar_signed (
    counter_vec : std_logic_vector;
    ref_vec     : std_logic_vector
  ) return pwm_leg_pair;

  function drive_bipolar_unsigned (
    counter_vec : std_logic_vector;
    ref_vec     : std_logic_vector
  ) return pwm_leg_pair;

end package pwm_1ch_drive_pkg;

package body pwm_1ch_drive_pkg is

  function drive_complementary_signed (
    counter_vec : std_logic_vector;
    ref_vec     : std_logic_vector
  ) return pwm_leg_pair is
    variable cmp : std_logic;
  begin
    if signed(counter_vec) < signed(ref_vec) then
      cmp := '1';
    else
      cmp := '0';
    end if;
    return (pwm => cmp, pwm_n => not cmp);
  end function drive_complementary_signed;

  function drive_complementary_unsigned (
    counter_vec : std_logic_vector;
    ref_vec     : std_logic_vector
  ) return pwm_leg_pair is
    variable cmp : std_logic;
  begin
    if unsigned(counter_vec) < unsigned(ref_vec) then
      cmp := '1';
    else
      cmp := '0';
    end if;
    return (pwm => cmp, pwm_n => not cmp);
  end function drive_complementary_unsigned;

  function drive_bipolar_signed (
    counter_vec : std_logic_vector;
    ref_vec     : std_logic_vector
  ) return pwm_leg_pair is
    variable cnt_s : signed(counter_vec'range);
    variable ref_s : signed(ref_vec'range);
  begin
    cnt_s := signed(counter_vec);
    ref_s := signed(ref_vec);
    if ref_s > 0 then
      if cnt_s < ref_s then
        return (pwm => '1', pwm_n => '0');
      else
        return (pwm => '0', pwm_n => '0');
      end if;
    elsif ref_s < 0 then
      if cnt_s > ref_s then
        return (pwm => '0', pwm_n => '1');
      else
        return (pwm => '0', pwm_n => '0');
      end if;
    else
      return (pwm => '0', pwm_n => '0');
    end if;
  end function drive_bipolar_signed;

  function drive_bipolar_unsigned (
    counter_vec : std_logic_vector;
    ref_vec     : std_logic_vector
  ) return pwm_leg_pair is
    constant mid   : natural := 2 ** (ref_vec'length - 1);
    variable cnt_i : integer;
    variable ref_i : integer;
  begin
    cnt_i := to_integer(unsigned(counter_vec)) - mid;
    ref_i := to_integer(unsigned(ref_vec)) - mid;
    if ref_i > 0 then
      if cnt_i < ref_i then
        return (pwm => '1', pwm_n => '0');
      else
        return (pwm => '0', pwm_n => '0');
      end if;
    elsif ref_i < 0 then
      if cnt_i > ref_i then
        return (pwm => '0', pwm_n => '1');
      else
        return (pwm => '0', pwm_n => '0');
      end if;
    else
      return (pwm => '0', pwm_n => '0');
    end if;
  end function drive_bipolar_unsigned;

end package body pwm_1ch_drive_pkg;
