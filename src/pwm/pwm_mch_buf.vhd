library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity pwm_mch_buf is
  generic (
    r               : integer   := 7;
    d               : integer   := 2;
    num_channels    : integer   := 2;
    input_data_type : string    := "SIGNED";
    buffer_depth    : integer   := 1024;
    ref_type        : string    := "SYMMETRICAL";
    scale_factor    : real      := 0.8;
    offset_factor   : real      := 0.1;
    input_mode       : string    := "DECIMATED";
    input_data_decimation_factor : positive := 64;
    pulse_period_samples : positive := 1024;
    prefill_pulses       : positive := 2;
    resume_pulses        : positive := 1;
    refill_batch_pulses  : positive := 1;
    min_safe_pulses      : natural  := 0;
    fifo_margin_samples  : natural  := 4;
    ref_step        : integer   := 1;
    ref_updwn       : std_logic := '1';
    clk_freq_hz     : integer   := 100_000_000;
    clk_pwm_freq_hz : integer   := 200_000_000
  );
  port (
    clk        : in    std_logic;
    clk_pwm    : in    std_logic;
    rst        : in    std_logic;
    enable     : in    std_logic;
    input_wave : in    std_logic_vector(r - 1 downto 0);
    input_valid : in   std_logic := '1';
    input_sample_ce : out std_logic;
    pwm        : out   std_logic_vector(num_channels - 1 downto 0);
    pwm_n      : out   std_logic_vector(num_channels - 1 downto 0)
  );
end entity pwm_mch_buf;

architecture src of pwm_mch_buf is

  type value_flag_pair is record
    val  : integer;
    flag : std_logic;
  end record value_flag_pair;

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

    if (mode = "SIGNED" or mode = "FP23" or mode = "FP23_SIGNED") then
      return get_chunk_end_signed(r => r, index => index, n => n);
    elsif (mode = "UNSIGNED") then
      return get_chunk_end_unsigned(r => r, index => index, n => n);
    else
      result.flag := '1';
      result.val  := -1;
      return result;
    end if;

  end function get_chunk_end;

  function clamp_positive(value : integer) return positive is
  begin
    if value < 1 then
      return 1;
    else
      return value;
    end if;
  end function;

  function max_natural (
    left  : natural;
    right : natural
  ) return natural is
  begin
    if left > right then
      return left;
    end if;

    return right;
  end function max_natural;

  function saturating_subtract (
    left  : natural;
    right : natural
  ) return natural is
  begin
    if left > right then
      return left - right;
    end if;

    return 0;
  end function saturating_subtract;

  function natural_for_input_mode (
    mode            : string;
    valid_value     : natural;
    decimated_value : natural
  ) return natural is
  begin
    if mode = "VALID" then
      return valid_value;
    end if;

    return decimated_value;
  end function natural_for_input_mode;

  function get_neutral_sample return std_logic_vector is
    variable result : std_logic_vector(r - 1 downto 0) := (others => '0');
  begin
    if input_data_type = "UNSIGNED" then
      result := std_logic_vector(to_unsigned(2 ** (r - 1), r));
    end if;

    return result;
  end function get_neutral_sample;

  function get_pwm_cycle_length return positive is
  begin
    if ref_type = "SYMMETRICAL" then
      return 2 ** (r + 1);
    else
      return 2 ** r;
    end if;
  end function;

  component pwm_1ch is
    generic (
      r                 : integer   := 7;
      input_width       : integer   := 7;
      d                 : integer   := 2;
      input_data_type   : string    := "SIGNED";
      ref_type          : string    := "SYMMETRICAL";
      scale_factor      : real      := 0.8;
      offset_factor     : real      := 0.1;
      fp23_binary_point : integer   := 6;
      ref_init          : integer   := 0;
      ref_step          : integer   := 1;
      ref_updwn         : std_logic := '1'
    );
    port (
      clk        : in    std_logic;
      rst        : in    std_logic;
      enable     : in    std_logic;
      input_wave : in    std_logic_vector(input_width - 1 downto 0);
      pwm        : out   std_logic;
      pwm_n      : out   std_logic
    );
  end component pwm_1ch;

  constant pwm_cycle_length : positive := get_pwm_cycle_length;

  constant fifo_count_width : integer := integer(ceil(log2(real(buffer_depth + 1))));
  constant prefill_sample_count : natural := pulse_period_samples * prefill_pulses;
  constant resume_sample_count : natural := pulse_period_samples * resume_pulses;
  constant refill_sample_count : natural := pulse_period_samples * refill_batch_pulses;
  constant min_safe_sample_count : natural := pulse_period_samples * min_safe_pulses;
  constant max_write_batch_samples : natural := max_natural(prefill_sample_count, refill_sample_count);
  constant almost_full_sample_count : natural := saturating_subtract(buffer_depth, fifo_margin_samples);
  constant valid_buffer_required_count : natural := prefill_sample_count + refill_sample_count + fifo_margin_samples;
  constant stream_start_sample_count : natural := natural_for_input_mode(input_mode, prefill_sample_count, 1);
  constant stream_stop_sample_count : natural := natural_for_input_mode(input_mode, min_safe_sample_count, 0);
  constant neutral_sample : std_logic_vector(r - 1 downto 0) := get_neutral_sample;

  type writer_state_t is (
    writer_prefill,
    writer_idle,
    writer_refill
  );

  signal buf_input  : std_logic_vector(r - 1 downto 0) := (others => '0');
  signal buf_output : std_logic_vector(r - 1 downto 0) := (others => '0');
  signal buf_rd_en  : std_logic                        := '0';
  signal buf_wr_en  : std_logic                        := '0';
  signal buf_full   : std_logic                        := '0';
  signal buf_empty  : std_logic                        := '0';
  signal buf_wr_count : std_logic_vector(fifo_count_width - 1 downto 0) := (others => '0');
  signal buf_rd_count : std_logic_vector(fifo_count_width - 1 downto 0) := (others => '0');

  signal dec_wave   : std_logic_vector(r - 1 downto 0) := (others => '0');
  signal valid_wave : std_logic                        := '0';

  signal duty_cycle : std_logic_vector(r - 1 downto 0) := neutral_sample;

  signal rst_sync : std_logic_vector(2 downto 0) := "000";
  signal rst_pwm  : std_logic                    := '1';

  signal enable_sync : std_logic_vector(2 downto 0) := "000";
  signal enable_pwm  : std_logic                    := '0';
  signal buf_rd_valid : std_logic                   := '0';
  signal stream_active : std_logic                  := '0';
  signal pwm_stream_rst : std_logic                 := '1';
  signal source_sample_ce : std_logic               := '0';

begin

  assert input_mode = "DECIMATED" or input_mode = "VALID"
    report "pwm_mch_buf: input_mode must be DECIMATED or VALID"
    severity failure;

  assert num_channels > 0
    report "num_channels must be >= 1"
    severity failure;

  assert buffer_depth > 0
    report "buffer_depth must be >= 1"
    severity failure;

  assert (input_mode = "DECIMATED") or (fifo_margin_samples < buffer_depth)
    report "pwm_mch_buf: fifo_margin_samples must be less than buffer_depth"
    severity failure;

  assert (input_mode = "DECIMATED") or (buffer_depth >= valid_buffer_required_count)
    report "pwm_mch_buf: buffer_depth must hold prefill_pulses plus refill_batch_pulses and margin"
    severity failure;

  assert (input_mode = "DECIMATED") or (prefill_pulses > resume_pulses)
    report "pwm_mch_buf: prefill_pulses must be greater than resume_pulses"
    severity failure;

  input_sample_ce <= source_sample_ce;
  pwm_stream_rst  <= rst_pwm or (not stream_active);

  decimated_input_gen : if input_mode = "DECIMATED" generate

    -- Use real arithmetic for elaboration-time scaling so the product
    -- clk_freq_hz * pwm_cycle_length cannot overflow 32-bit integer.
    constant decimation_factor_real : real := (real(clk_freq_hz) * real(pwm_cycle_length)) / real(clk_pwm_freq_hz);
    constant decimation_factor_raw  : integer := integer(round(decimation_factor_real));
    constant decimation_factor      : positive := clamp_positive(integer(round(decimation_factor_real * 0.95)));

  begin

    assert decimation_factor_raw > 0
      report "decimation_factor must be >= 1. Check clock frequencies and resolution."
      severity failure;

    source_sample_ce <= '1';

    dec_sine : entity work.data_decimator
      generic map (
        data_width        => r,
        decimation_factor => decimation_factor
      )
      port map (
        clk       => clk,
        rst       => rst,
        data_in   => input_wave,
        data_out  => dec_wave,
        valid_out => valid_wave
      );

    input_buffer_wr_ctrl : process (clk) is
    begin

      if rising_edge(clk) then
        if (rst = '1') then
          buf_wr_en <= '0';
          buf_input <= (others => '0');
        elsif ((buf_full = '0') and (valid_wave = '1')) then
          buf_wr_en <= '1';
          buf_input <= dec_wave;
        else
          buf_wr_en <= '0';
        end if;
      end if;

    end process input_buffer_wr_ctrl;

  end generate decimated_input_gen;

  valid_input_gen : if input_mode = "VALID" generate

    signal writer_state : writer_state_t := writer_prefill;
    signal writer_sample_count : natural range 0 to max_write_batch_samples := 0;
    signal input_data_decimation_count : natural range 0 to input_data_decimation_factor - 1 := 0;

  begin

    input_buffer_wr_ctrl : process (clk) is
      variable fifo_level        : natural;
      variable next_sample_count : natural;
      variable target_count      : natural;
    begin

      if rising_edge(clk) then
        if (rst = '1') then
          writer_state        <= writer_prefill;
          writer_sample_count <= 0;
          input_data_decimation_count <= 0;
          source_sample_ce    <= '0';
          buf_wr_en           <= '0';
          buf_input           <= neutral_sample;
        else
          source_sample_ce <= '0';
          buf_wr_en        <= '0';
          fifo_level       := to_integer(unsigned(buf_wr_count));
          next_sample_count := writer_sample_count;

          if ((input_valid = '1') and (buf_full = '0')) then
            buf_wr_en <= '1';
            buf_input <= input_wave;

            if (next_sample_count < max_write_batch_samples) then
              next_sample_count := next_sample_count + 1;
            end if;
          end if;

          case writer_state is

            when writer_prefill =>
              target_count := prefill_sample_count;

            when writer_refill =>
              target_count := refill_sample_count;

            when others =>
              target_count := 0;

          end case;

          if (writer_state = writer_idle) then
            writer_sample_count <= 0;
            input_data_decimation_count <= 0;

            if ((enable = '1') and (fifo_level <= resume_sample_count)) then
              writer_state <= writer_refill;
            end if;
          elsif (next_sample_count >= target_count) then
            writer_state        <= writer_idle;
            writer_sample_count <= 0;
            input_data_decimation_count <= 0;
          else
            writer_sample_count <= next_sample_count;

            if ((enable = '1') and
                (buf_full = '0') and
                (fifo_level < almost_full_sample_count)) then
              if (input_data_decimation_count = input_data_decimation_factor - 1) then
                input_data_decimation_count <= 0;
                source_sample_ce    <= '1';
              else
                input_data_decimation_count <= input_data_decimation_count + 1;
              end if;
            end if;
          end if;
        end if;
      end if;

    end process input_buffer_wr_ctrl;

  end generate valid_input_gen;

  input_buffer : entity work.async_fifo
    generic map (
      data_width => r,
      fifo_depth => buffer_depth
    )
    port map (
      wr_clk   => clk,
      wr_rst   => rst,
      wr_en    => buf_wr_en,
      full     => buf_full,
      wr_count => buf_wr_count,
      data_in  => buf_input,
      rd_clk   => clk_pwm,
      rd_rst   => rst_pwm,
      rd_en    => buf_rd_en,
      empty    => buf_empty,
      rd_count => buf_rd_count,
      data_out => buf_output
    );

  rst_sync_proc : process (clk_pwm) is
  begin
    if rising_edge(clk_pwm) then
      rst_sync <= rst_sync(1 downto 0) & rst;
      rst_pwm  <= rst_sync(2);
    end if;
  end process rst_sync_proc;

  enable_sync_proc : process (clk_pwm) is
  begin
    if rising_edge(clk_pwm) then
      if (rst_pwm = '1') then
        enable_sync <= "000";
        enable_pwm  <= '0';
      else
        enable_sync <= enable_sync(1 downto 0) & enable;
        enable_pwm  <= enable_sync(2);
      end if;
    end if;
  end process enable_sync_proc;

  input_buffer_rd_ctrl : process (clk_pwm) is

    -- Count one full PWM frame before requesting next buffered sample.
    variable cnt : integer range 0 to pwm_cycle_length - 1 := 0;
    variable fifo_level : natural := 0;
    variable stream_next : std_logic := '0';
  begin

    if rising_edge(clk_pwm) then
      if (rst_pwm = '1') then
        cnt          := 0;
        buf_rd_en    <= '0';
        buf_rd_valid <= '0';
        stream_active <= '0';
      else
        fifo_level := to_integer(unsigned(buf_rd_count));
        stream_next := stream_active;
        buf_rd_valid <= buf_rd_en;
        buf_rd_en <= '0';

        if (enable_pwm = '0') then
          stream_next := '0';
          cnt := 0;
        elsif (stream_active = '0') then
          cnt := 0;

          if (fifo_level >= stream_start_sample_count) then
            stream_next := '1';
          end if;
        elsif (fifo_level <= stream_stop_sample_count) then
          stream_next := '0';
          cnt := 0;
        end if;

        if (stream_next = '1') then
          if (cnt = pwm_cycle_length - 1) then
            cnt := 0;

            if (buf_empty = '0') then
              buf_rd_en <= '1';
            else
              stream_next := '0';
            end if;
          else
            cnt := cnt + 1;
          end if;
        else
          buf_rd_valid <= '0';
        end if;

        stream_active <= stream_next;
      end if;
    end if;

  end process input_buffer_rd_ctrl;

  pwm_reg_ctrl : process (clk_pwm) is
  begin

    if rising_edge(clk_pwm) then
      if ((rst_pwm = '1') or (stream_active = '0')) then
        duty_cycle <= neutral_sample;
      else
        if (buf_rd_valid = '1') then
          duty_cycle <= buf_output;
        end if;
      end if;
    end if;

  end process pwm_reg_ctrl;

  channels_gen : for i in 0 to NUM_CHANNELS - 1 generate

    constant chunk : value_flag_pair := get_chunk_end(
                                                      mode  => input_data_type,
                                                      r     => r,
                                                      index => i,
                                                      n     => num_channels);

  begin

    pwm_ich : component pwm_1ch
      generic map (
        r               => r,
        input_width     => r,
        d               => d,
        ref_type        => ref_type,
        scale_factor    => scale_factor,
        offset_factor   => offset_factor,
        fp23_binary_point => r - 1,
        ref_init        => chunk.val,
        ref_step        => ref_step,
        ref_updwn       => chunk.flag,
        input_data_type => input_data_type
      )
      port map (
        clk        => clk_pwm,
        rst        => pwm_stream_rst,
        enable     => enable_pwm,
        input_wave => duty_cycle,
        pwm        => pwm(i),
        pwm_n      => pwm_n(i)
      );

  end generate channels_gen;

end architecture src;
