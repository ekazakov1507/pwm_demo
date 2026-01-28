library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.range_divider_pkg.get_chunk_end_unsigned;
  use work.range_divider_pkg.get_chunk_end_signed;
  use work.range_divider_pkg.value_flag_pair;

entity tb_range_divider_pkg is
--  Port ( );
end entity tb_range_divider_pkg;

architecture sim of tb_range_divider_pkg is

begin

  process is

    variable vec        : value_flag_pair;
    variable r_signed   : positive := 7; -- Signed range: -63 to +63
    variable r_unsigned : positive := 8; -- Unsigned range: 0 to 255

  begin

    -- ========================================================================
    -- SIGNED TESTS (r=7 -> symmetric range -63 to +63)
    -- ========================================================================
    report "====================================================================";
    report "SIGNED TEST VECTORS (r=" & integer'image(r_signed) & " -> range -63 to +63)";
    report "====================================================================";

    -- n = 2
    report "";
    report "n = 2:";

    for i in 0 to 1 loop

      vec := get_chunk_end_signed(r => r_signed, index => i, n => 2);
      report "  Index " & integer'image(i) & ": val = " & integer'image(vec.val) &
             ", flag = " & std_logic'image(vec.flag);

    end loop;

    -- n = 4
    report "";
    report "n = 4:";

    for i in 0 to 3 loop

      vec := get_chunk_end_signed(r => r_signed, index => i, n => 4);
      report "  Index " & integer'image(i) & ": val = " & integer'image(vec.val) &
             ", flag = " & std_logic'image(vec.flag);

    end loop;

    -- n = 8
    report "";
    report "n = 8:";

    for i in 0 to 7 loop

      vec := get_chunk_end_signed(r => r_signed, index => i, n => 8);
      report "  Index " & integer'image(i) & ": val = " & integer'image(vec.val) &
             ", flag = " & std_logic'image(vec.flag);

    end loop;

    -- ========================================================================
    -- UNSIGNED TESTS (r=8 -> range 0 to 255)
    -- ========================================================================
    report "";
    report "====================================================================";
    report "UNSIGNED TEST VECTORS (r=" & integer'image(r_unsigned) & " -> range 0 to 255)";
    report "====================================================================";

    -- n = 2
    report "";
    report "n = 2:";

    for i in 0 to 1 loop

      vec := get_chunk_end_unsigned(r => r_unsigned, index => i, n => 2);
      report "  Index " & integer'image(i) & ": val = " & integer'image(vec.val) &
             ", flag = " & std_logic'image(vec.flag);

    end loop;

    -- n = 4
    report "";
    report "n = 4:";

    for i in 0 to 3 loop

      vec := get_chunk_end_unsigned(r => r_unsigned, index => i, n => 4);
      report "  Index " & integer'image(i) & ": val = " & integer'image(vec.val) &
             ", flag = " & std_logic'image(vec.flag);

    end loop;

    -- n = 8
    report "";
    report "n = 8:";

    for i in 0 to 7 loop

      vec := get_chunk_end_unsigned(r => r_unsigned, index => i, n => 8);
      report "  Index " & integer'image(i) & ": val = " & integer'image(vec.val) &
             ", flag = " & std_logic'image(vec.flag);

    end loop;

    report "";
    report "=== TESTBENCH COMPLETE ===";
    wait;

  end process;

end architecture sim;
