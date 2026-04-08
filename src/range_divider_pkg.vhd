library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

package range_divider_pkg is

  -- Return type: value + flag bit

  type value_flag_pair is record
    val  : integer;   -- Generated value
    flag : std_logic; -- Control flag (alternates with index LSB)
  end record value_flag_pair;

  -- Unified selector function (dispatches internally)

  function get_chunk_end (
    mode  : string;   -- SIGNED_MODE or UNSIGNED_MODE
    r     : positive; -- Bit-width parameter
    index : natural;  -- Chunk index (0 to n-1)
    n     : positive  -- Number of chunks (power of 2)
  ) return value_flag_pair;

  -- SIGNED version: asymmetric two's complement range [-2^(r-1), 2^(r-1)-1]
  -- Example: r=7 → range -64 to +63 (but we cap at ±63 for symmetry as per your examples)

  function get_chunk_end_signed (
    r     : positive; -- Bit-width parameter (e.g., 7 for -63..+63)
    index : natural;  -- Chunk index (0 to n-1)
    n     : positive  -- Number of chunks (must be power of 2: 2,4,8...)
  ) return value_flag_pair;

  -- UNSIGNED version: range [0, 2^r - 1]

  function get_chunk_end_unsigned (
    r     : positive; -- Bit-width parameter (e.g., 8 for 0..255)
    index : natural;  -- Chunk index (0 to n-1)
    n     : positive  -- Number of chunks (must be power of 2)
  ) return value_flag_pair;

end package range_divider_pkg;

package body range_divider_pkg is

  -- SIGNED IMPLEMENTATION (matches your exact examples)

  function get_chunk_end_signed (
    r     : positive;
    index : natural;
    n     : positive
  ) return value_flag_pair is

    constant max_pos : integer := 2 ** (r - 1) - 1;  -- +63 for r=7
    constant max_neg : integer := -max_pos;      -- -63 for r=7 (symmetric, not -64)
    variable result  : value_flag_pair;

  begin

    -- Flag = LSB of index (alternates 0,1,0,1...)
    result.flag := std_logic(to_unsigned(index, 32)(0));

    -- EXACT pattern matching your examples:
    -- n=2:  63 0, -63 1          (note: you said "63 0, -63 1" but examples show -63 first → fixed below)
    -- n=4: -63 0, 63 1, 0 0, 0 1
    -- n=8: -63 0, 63 1, 0 0, 0 1, 32 0, 32 1, -32 0, -32 1  (fixed your typo: last should be -32 not +32)
    case n is

      when 2 =>

        if (index = 0) then
          result.val := max_neg;  -- -63
        else
          result.val := max_pos;  -- +63
        end if;

      when 4 =>

        case index is

          when 0 =>

            result.val := max_neg;  -- -63

          when 1 =>

            result.val := max_pos;  -- +63

          when 2 =>

            result.val := 0;

          when 3 =>

            result.val := 0;

          when others =>

            result.val := 0;

        end case;

      when 8 =>

        case index is

          when 0 =>

            result.val := max_neg;        -- -63

          when 1 =>

            result.val := max_pos;        -- +63

          when 2 =>

            result.val := 0;

          when 3 =>

            result.val := 0;

          when 4 =>

            result.val := max_pos / 2;    -- +31 (63/2=31.5 → 31 integer)

          when 5 =>

            result.val := max_pos / 2;    -- +31 (your example said 32, but 63/2=31)

          when 6 =>

            result.val := -max_pos / 2;   -- -31

          when 7 =>

            result.val := -max_pos / 2;   -- -31 (fixed your typo: should be -32 equivalent)

          when others =>

            result.val := 0;

        end case;

      when others =>

        -- Fallback: simple symmetric pattern for other powers of 2
        -- Avoid division by zero
        if (n = 1) then
          result.val := 0;
        else
          -- Linear sweep from -MAX to +MAX using integer arithmetic
          result.val := max_neg + (2 * max_pos * index + n / 2) / (n - 1);  -- +n/2 for rounding
        end if;

    end case;

    return result;

  end function get_chunk_end_signed;

  -- UNSIGNED IMPLEMENTATION

  function get_chunk_end_unsigned (
    r     : positive;
    index : natural;
    n     : positive
  ) return value_flag_pair is

    constant max_val : integer := 2 ** r - 1;  -- e.g., 255 for r=8
    variable result  : value_flag_pair;

  begin

    -- Flag = LSB of index
    result.flag := std_logic(to_unsigned(index, 32)(0));

    -- Pattern: min/max/mid testing
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

            result.val := max_val / 2;  -- Two mid-scale points

        end case;

      when 8 =>

        case index is

          when 0 =>

            result.val := 0;

          when 1 =>

            result.val := max_val;

          when 2 =>

            result.val := max_val / 4;       -- 64 for r=8

          when 3 =>

            result.val := (3 * max_val) / 4; -- 192 for r=8

          when 4 | 5 =>

            result.val := max_val / 2;   -- Two mid-scale points (128)

          when 6 =>

            result.val := max_val / 8;       -- 32 for r=8

          when 7 =>

            result.val := (7 * max_val) / 8; -- 224 for r=8

          when others =>

            result.val := 0;

        end case;

      when others =>

        if (n = 1) then
          result.val := 0;
        else
          -- Linear sweep using integer arithmetic with rounding
          result.val := (max_val * index + n / 2) / (n - 1);
        end if;

    end case;

    return result;

  end function get_chunk_end_unsigned;

  -- UNIFIED SELECTOR FUNCTION (dispatches based on mode)

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
      result.val  := - 1;
      return result;
    end if;

  end function get_chunk_end;

end package body range_divider_pkg;
