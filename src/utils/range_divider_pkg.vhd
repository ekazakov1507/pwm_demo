library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

package range_divider_pkg is

  type value_flag_pair is record
    val  : integer;
    flag : std_logic;
  end record value_flag_pair;

  function get_chunk_end (
    mode  : string;
    r     : positive;
    index : natural;
    n     : positive
  ) return value_flag_pair;

  function get_chunk_end_signed (
    r     : positive;
    index : natural;
    n     : positive
  ) return value_flag_pair;

  function get_chunk_end_unsigned (
    r     : positive;
    index : natural;
    n     : positive
  ) return value_flag_pair;

end package range_divider_pkg;

package body range_divider_pkg is

  function get_chunk_end_signed (
    r     : positive;
    index : natural;
    n     : positive
  ) return value_flag_pair is

    constant max_pos : integer := 2 ** (r - 1) - 1;
    constant max_neg : integer := -max_pos;
    variable result  : value_flag_pair;

  begin

    result.flag := std_logic(to_unsigned(index, 32)(0));

    case n is

      when 2 =>

        if (index = 0) then
          result.val := max_neg;
        else
          result.val := max_pos;
        end if;

      when 4 =>

        case index is

          when 0 =>
            result.val := max_neg;

          when 1 =>
            result.val := max_pos;

          when others =>
            result.val := 0;

        end case;

      when 8 =>

        case index is

          when 0 =>
            result.val := max_neg;

          when 1 =>
            result.val := max_pos;

          when 2 | 3 =>
            result.val := 0;

          when 4 | 5 =>
            result.val := max_pos / 2;

          when 6 | 7 =>
            result.val := -max_pos / 2;

          when others =>
            result.val := 0;

        end case;

      when others =>

        result.val := max_neg + (2 * max_pos * index + n / 2) / (n - 1);

    end case;

    return result;

  end function get_chunk_end_signed;

  function get_chunk_end_unsigned (
    r     : positive;
    index : natural;
    n     : positive
  ) return value_flag_pair is

    constant max_val : integer := 2 ** r - 1;
    variable result  : value_flag_pair;

  begin

    result.flag := std_logic(to_unsigned(index, 32)(0));

    case n is

      when 2 =>

        if (index = 0) then
          result.val := 0;
        else
          result.val := max_val;
        end if;

      when 4 =>

        case index is

          when 0 =>
            result.val := 0;

          when 1 =>
            result.val := max_val;

          when others =>
            result.val := max_val / 2;

        end case;

      when 8 =>

        case index is

          when 0 =>
            result.val := 0;

          when 1 =>
            result.val := max_val;

          when 2 =>
            result.val := max_val / 4;

          when 3 =>
            result.val := (3 * max_val) / 4;

          when 4 | 5 =>
            result.val := max_val / 2;

          when 6 =>
            result.val := max_val / 8;

          when 7 =>
            result.val := (7 * max_val) / 8;

          when others =>
            result.val := 0;

        end case;

      when others =>

        result.val := (max_val * index + n / 2) / (n - 1);

    end case;

    return result;

  end function get_chunk_end_unsigned;

  function get_chunk_end (
    mode  : string;
    r     : positive;
    index : natural;
    n     : positive
  ) return value_flag_pair is

    variable result : value_flag_pair;

  begin

    if (mode = "SIGNED") then
      return get_chunk_end_signed(r => r, index => index, n => n);
    elsif (mode = "UNSIGNED") then
      return get_chunk_end_unsigned(r => r, index => index, n => n);
    else
      result.flag := '1';
      result.val  := -1;
      return result;
    end if;

  end function get_chunk_end;

end package body range_divider_pkg;
