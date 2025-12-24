library ieee;
  use ieee.std_logic_1164.all;

package custom_types_pkg is

  type integer_vector is array (natural range <>) of integer;

  type real_vector is array (natural range <>) of real;

end package custom_types_pkg;
