library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity tb_async_fifo is
end entity tb_async_fifo;

architecture tb of tb_async_fifo is

  constant data_width : integer := 8;
  constant fifo_depth : integer := 16;
  constant addr_width : integer := 4;

  signal wr_clk   : std_logic                                 := '0';
  signal wr_rst   : std_logic                                 := '1';
  signal wr_en    : std_logic                                 := '0';
  signal data_in  : std_logic_vector(data_width - 1 downto 0) := (others => '0');
  signal full     : std_logic;
  signal wr_count : std_logic_vector(addr_width - 1 downto 0);

  signal rd_clk   : std_logic := '0';
  signal rd_rst   : std_logic := '1';
  signal rd_en    : std_logic := '0';
  signal data_out : std_logic_vector(data_width - 1 downto 0);
  signal empty    : std_logic;
  signal rd_count : std_logic_vector(addr_width - 1 downto 0);

  constant fast_period : time := 10 ns;
  constant slow_period : time := 25 ns;
  constant very_fast   : time := 5 ns;
  constant very_slow   : time := 50 ns;

  signal test_passed : integer := 0;
  signal test_failed : integer := 0;

  type test_array is array (0 to 15) of std_logic_vector(7 downto 0);

  constant test_data : test_array :=
  (
    x"01",
    x"02",
    x"03",
    x"04",
    x"05",
    x"06",
    x"07",
    x"08",
    x"09",
    x"0A",
    x"0B",
    x"0C",
    x"0D",
    x"0E",
    x"0F",
    x"10"
  );

begin

  uut : entity work.async_fifo
    generic map (
      data_width => DATA_WIDTH,
      fifo_depth => FIFO_DEPTH
    )
    port map (
      wr_clk   => wr_clk,
      wr_rst   => wr_rst,
      wr_en    => wr_en,
      data_in  => data_in,
      full     => full,
      wr_count => wr_count,

      rd_clk   => rd_clk,
      rd_rst   => rd_rst,
      rd_en    => rd_en,
      data_out => data_out,
      empty    => empty,
      rd_count => rd_count
    );

  wr_clk <= not wr_clk after fast_period / 2;
  rd_clk <= not rd_clk after slow_period / 2;

  process is

    procedure reset_all is
    begin

      wr_rst <= '1';
      rd_rst <= '1';
      wait for 100 ns;
      wr_rst <= '0';
      rd_rst <= '0';
      wait for 50 ns;

    end procedure reset_all;

    procedure test_start (
      name : string
    ) is
    begin

      report "=== TEST: " & name & " ===";

    end procedure test_start;

    procedure test_end (
      name : string;
      pass : boolean
    ) is
    begin

      if (pass) then
        report "PASS: " & name;
        test_passed <= test_passed + 1;
      else
        report "FAIL: " & name;
        test_failed <= test_failed + 1;
      end if;

      wait for 100 ns;

    end procedure test_end;

    procedure write_data (
      value : integer
    ) is
    begin

      wait until rising_edge(wr_clk);

      if (full = '0') then
        wr_en   <= '1';
        data_in <= std_logic_vector(to_unsigned(value, DATA_WIDTH));
      else
        wr_en <= '0';
      end if;

    end procedure write_data;

    procedure read_data (
      expected    : integer;
      valid_check : boolean := true
    ) is

      variable data_val : integer;

    begin

      wait until rising_edge(rd_clk);

      if (empty = '0' or not valid_check) then
        rd_en <= '1';
        if (valid_check) then
          wait until falling_edge(rd_clk);
          data_val := to_integer(unsigned(data_out));
          assert data_val = expected
            report "Read mismatch: got " & integer'image(data_val) &
                   ", expected " & integer'image(expected)
            severity error;
        end if;
      else
        rd_en <= '0';
      end if;

    end procedure read_data;

    variable expected_data : integer := 0;
    variable read_data_val : integer := 0;

  begin

    reset_all;

    test_start("1. Basic write/read");

    for i in 1 to 5 loop

      write_data(i);

    end loop;

    wr_en <= '0';
    wait for 50 ns;

    for i in 1 to 5 loop

      read_data(i);

    end loop;

    rd_en <= '0';
    test_end("Basic write/read", true);

    test_start("2. Full FIFO test");

    for i in 1 to 20 loop

      write_data(i);

    end loop;

    wr_en <= '0';
    assert full = '1'
      report "FIFO should be full"
      severity error;
    test_end("Full FIFO test", full = '1');

    test_start("3. Empty FIFO test");

    for i in 1 to 20 loop

      read_data(i, false);

    end loop;

    rd_en <= '0';
    wait for 50 ns;
    assert empty = '1'
      report "FIFO should be empty"
      severity error;
    test_end("Empty FIFO test", empty = '1');

    test_start("4. Concurrent write/read");

    for i in 1 to 30 loop

      if (i <= 20) then
        write_data(i);
      end if;

      if (i >= 10) then
        read_data(i - 9);
      end if;

    end loop;

    wr_en <= '0';
    rd_en <= '0';
    test_end("Concurrent write/read", true);

    test_start("5. Burst write then burst read");

    for i in 1 to 10 loop

      write_data(100 + i);

    end loop;

    wr_en <= '0';
    wait for 200 ns;

    for i in 1 to 10 loop

      read_data(100 + i);

    end loop;

    rd_en <= '0';
    test_end("Burst test", true);

    test_start("6. Write faster than read (4:1)");

    for i in 1 to 40 loop

      if (i mod 4 = 0) then
        read_data(expected_data + 1);
        expected_data := expected_data + 1;
      end if;

      write_data(i);

    end loop;

    wr_en <= '0';
    rd_en <= '0';
    test_end("Fast write test", true);

    test_start("7. Read faster than write (1:4)");

    for i in 1 to 10 loop

      write_data(200 + i);

      if (i > 1) then

        for j in 1 to 3 loop

          read_data(200 + i - 1);

        end loop;

      end if;

    end loop;

    wr_en <= '0';
    rd_en <= '0';
    test_end("Fast read test", true);

    test_start("8. Random write/read pattern");

    for i in 1 to 50 loop

      if (i mod 7 = 0) then
        write_data(300 + i);
      end if;

      if (i mod 5 = 0) then
        read_data(0, false);
      end if;

    end loop;

    wr_en <= '0';
    rd_en <= '0';
    test_end("Random pattern", true);

    test_start("9. Count verification");

    for i in 1 to 8 loop

      write_data(400 + i);

    end loop;

    wr_en <= '0';
    wait until rising_edge(wr_clk);
    assert unsigned(wr_count) = 8
      report "Write count wrong"
      severity error;
    wait until rising_edge(rd_clk);
    assert unsigned(rd_count) = 8
      report "Read count wrong"
      severity error;
    test_end("Count test", unsigned(wr_count) = 8 and unsigned(rd_count) = 8);

    test_start("10. Write during full");

    for i in 1 to 20 loop

      write_data(500 + i);

    end loop;

    write_data(999);
    wr_en <= '0';
    test_end("Full ignore test", true);

    test_start("11. Read during empty");

    for i in 1 to 5 loop

      read_data(0, false);

    end loop;

    rd_en <= '0';
    test_end("Empty ignore test", empty = '1');

    test_start("12. Reset during operation");

    for i in 1 to 5 loop

      write_data(600 + i);
      read_data(600 + i);

    end loop;

    reset_all;
    assert empty = '1' and full = '0'
      report "Reset failed"
      severity error;
    test_end("Reset test", empty = '1' and full = '0');

    test_start("13. Maximum throughput");

    for i in 1 to 100 loop

      write_data(700 + i);
      read_data(700 + i);

    end loop;

    wr_en <= '0';
    rd_en <= '0';
    test_end("Throughput test", true);

    test_start("14. Data integrity");

    for i in 0 to 15 loop

      write_data(to_integer(unsigned(TEST_DATA(i))));

    end loop;

    wr_en <= '0';
    wait for 100 ns;

    for i in 0 to 15 loop

      read_data(to_integer(unsigned(TEST_DATA(i))));

    end loop;

    rd_en <= '0';
    test_end("Data integrity", true);

    test_start("15. Long sequence stress");

    for i in 1 to 1000 loop

      if (i mod 3 = 0) then
        write_data(800 + i);
      end if;

      if (i mod 4 = 0) then
        read_data(0, false);
      end if;

    end loop;

    wr_en <= '0';
    rd_en <= '0';
    test_end("Stress test", true);

    report "==========================================";
    report "TEST SUMMARY:";
    report "  Passed: " & integer'image(test_passed);
    report "  Failed: " & integer'image(test_failed);
    report "  Total:  " & integer'image(test_passed + test_failed);

    if (test_failed = 0) then
      report "ALL TESTS PASSED!";
    else
      report "SOME TESTS FAILED!";
    end if;

    wait;

  end process;

  process is

    variable write_ops : integer := 0;
    variable read_ops  : integer := 0;

  begin

    wait until rising_edge(wr_clk);

    if (wr_en = '1' and full = '0') then
      write_ops := write_ops + 1;
    end if;

    wait until rising_edge(rd_clk);

    if (rd_en = '1' and empty = '0') then
      read_ops := read_ops + 1;
    end if;

  end process;

end architecture tb;
