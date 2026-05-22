library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity async_fifo is
  generic (
    data_width : integer := 8;
    fifo_depth : integer := 16
  );
  port (
    wr_clk     : in    std_logic;
    wr_rst     : in    std_logic;
    wr_en      : in    std_logic;
    data_in    : in    std_logic_vector(data_width - 1 downto 0);
    full       : out   std_logic;
    wr_count   : out   std_logic_vector(integer(ceil(log2(real(fifo_depth + 1)))) - 1 downto 0);
    rd_clk     : in    std_logic;
    rd_rst     : in    std_logic;
    rd_en      : in    std_logic;
    data_out   : out   std_logic_vector(data_width - 1 downto 0);
    empty      : out   std_logic;
    rd_count   : out   std_logic_vector(integer(ceil(log2(real(fifo_depth + 1)))) - 1 downto 0)
  );
end entity async_fifo;

architecture src of async_fifo is

  constant addr_width  : integer := integer(ceil(log2(real(fifo_depth))));
  constant count_width : integer := integer(ceil(log2(real(fifo_depth + 1))));

  type mem_type is array (0 to fifo_depth - 1) of std_logic_vector(data_width - 1 downto 0);

  signal memory : mem_type;
  attribute ram_style : string;
  attribute ram_style of memory : signal is "block";

  signal wr_ptr_bin  : unsigned(addr_width downto 0) := (others => '0');
  signal wr_ptr_gray : std_logic_vector(addr_width downto 0) := (others => '0');
  signal wr_ptr_gray_rd1 : std_logic_vector(addr_width downto 0) := (others => '0');
  signal wr_ptr_gray_rd2 : std_logic_vector(addr_width downto 0) := (others => '0');

  signal rd_ptr_bin  : unsigned(addr_width downto 0) := (others => '0');
  signal rd_ptr_gray : std_logic_vector(addr_width downto 0) := (others => '0');
  signal rd_ptr_gray_wr1 : std_logic_vector(addr_width downto 0) := (others => '0');
  signal rd_ptr_gray_wr2 : std_logic_vector(addr_width downto 0) := (others => '0');

  signal rd_ptr_bin_wr_sync : unsigned(addr_width downto 0) := (others => '0');
  signal wr_ptr_bin_rd_sync : unsigned(addr_width downto 0) := (others => '0');

  signal full_i  : std_logic                          := '0';
  signal empty_i : std_logic                          := '1';
  signal wr_cnt  : unsigned(count_width - 1 downto 0) := (others => '0');
  signal rd_cnt  : unsigned(count_width - 1 downto 0) := (others => '0');

  function bin2gray (
    bin : unsigned
  ) return std_logic_vector is
  begin

    return std_logic_vector(bin xor ('0' & bin(bin'high downto 1)));

  end function bin2gray;

  function gray2bin (
    gray : std_logic_vector
  ) return unsigned is

    variable bin : unsigned(gray'range);

  begin

    bin(bin'high) := gray(gray'high);

    for i in gray'high - 1 downto 0 loop

      bin(i) := bin(i + 1) xor gray(i);

    end loop;

    return bin;

  end function gray2bin;

  function fifo_is_full (
    wr_ptr_next : unsigned;
    rd_ptr_sync : unsigned
  ) return std_logic is
  begin

    if (wr_ptr_next(wr_ptr_next'high - 1 downto 0) = rd_ptr_sync(rd_ptr_sync'high - 1 downto 0) and
        wr_ptr_next(wr_ptr_next'high) /= rd_ptr_sync(rd_ptr_sync'high)) then
      return '1';
    else
      return '0';
    end if;

  end function fifo_is_full;

  function fifo_is_empty (
    rd_ptr_next : unsigned;
    wr_ptr_sync : unsigned
  ) return std_logic is
  begin

    if (rd_ptr_next = wr_ptr_sync) then
      return '1';
    else
      return '0';
    end if;

  end function fifo_is_empty;

begin

  rd_ptr_bin_wr_sync <= gray2bin(rd_ptr_gray_wr2);
  wr_ptr_bin_rd_sync <= gray2bin(wr_ptr_gray_rd2);

  assert fifo_depth = 2 ** addr_width
    report "async_fifo fifo_depth must be a power of two"
    severity failure;

  wr_proc : process (wr_clk) is
  begin

    if rising_edge(wr_clk) then
      if (wr_rst = '1') then
        wr_ptr_bin      <= (others => '0');
        wr_ptr_gray     <= (others => '0');
        rd_ptr_gray_wr1 <= (others => '0');
        rd_ptr_gray_wr2 <= (others => '0');
        full_i          <= '0';
        wr_cnt          <= (others => '0');
      else
        rd_ptr_gray_wr2 <= rd_ptr_gray_wr1;
        rd_ptr_gray_wr1 <= rd_ptr_gray;

        if (wr_en = '1' and full_i = '0') then
          memory(to_integer(wr_ptr_bin(addr_width - 1 downto 0))) <= data_in;
          wr_ptr_bin                                             <= wr_ptr_bin + 1;
          wr_ptr_gray                                            <= bin2gray(wr_ptr_bin + 1);
          full_i                                                 <= fifo_is_full(wr_ptr_bin + 1, rd_ptr_bin_wr_sync);
          wr_cnt                                                 <= resize((wr_ptr_bin + 1) - rd_ptr_bin_wr_sync, count_width);
        else
          full_i <= fifo_is_full(wr_ptr_bin, rd_ptr_bin_wr_sync);
          wr_cnt <= resize(wr_ptr_bin - rd_ptr_bin_wr_sync, count_width);
        end if;
      end if;
    end if;

  end process wr_proc;

  rd_proc : process (rd_clk) is
  begin

    if rising_edge(rd_clk) then
      if (rd_rst = '1') then
        rd_ptr_bin      <= (others => '0');
        rd_ptr_gray     <= (others => '0');
        wr_ptr_gray_rd1 <= (others => '0');
        wr_ptr_gray_rd2 <= (others => '0');
        data_out        <= (others => '0');
        empty_i         <= '1';
        rd_cnt          <= (others => '0');
      else
        wr_ptr_gray_rd2 <= wr_ptr_gray_rd1;
        wr_ptr_gray_rd1 <= wr_ptr_gray;

        if (rd_en = '1' and empty_i = '0') then
          data_out    <= memory(to_integer(rd_ptr_bin(addr_width - 1 downto 0)));
          rd_ptr_bin <= rd_ptr_bin + 1;
          rd_ptr_gray <= bin2gray(rd_ptr_bin + 1);
          empty_i <= fifo_is_empty(rd_ptr_bin + 1, wr_ptr_bin_rd_sync);
          rd_cnt <= resize(wr_ptr_bin_rd_sync - (rd_ptr_bin + 1), count_width);
        else
          empty_i <= fifo_is_empty(rd_ptr_bin, wr_ptr_bin_rd_sync);
          rd_cnt <= resize(wr_ptr_bin_rd_sync - rd_ptr_bin, count_width);
        end if;
      end if;
    end if;

  end process rd_proc;

  full     <= full_i;
  empty    <= empty_i;
  wr_count <= std_logic_vector(wr_cnt);
  rd_count <= std_logic_vector(rd_cnt);

end architecture src;
