# Signal Chain Modules

## Overview

The signal chain modules handle waveform generation, scaling, and sample rate conversion:

- **sine_gen_simple.vhd**: Wrapper that selects the signed or unsigned sine generator
- **sine_gen_signed.vhd**: Signed sine lookup table generator with optional ramp and pulse envelope
- **sine_gen_unsigned.vhd**: Unsigned sine lookup table generator with optional ramp and pulse envelope
- **data_decimator.vhd**: Sample rate decimator (downsampler)
- **scaler_signed.vhd**: Signed amplitude scaler
- **scaler_unsigned.vhd**: Unsigned amplitude scaler with offset

## Module Hierarchy

```mermaid
graph TB
    subgraph "Signal Generation"
        SINE[sine_gen_simple<br/>type-selecting wrapper]
        SINE_S[sine_gen_signed]
        SINE_U[sine_gen_unsigned]
    end

    subgraph "Sample Rate Conversion"
        DEC[data_decimator<br/>Downsampler]
    end

    subgraph "Amplitude Scaling"
        SCALER_S[scaler_signed<br/>Signed Mode]
        SCALER_U[scaler_unsigned<br/>Unsigned Mode]
    end

    SINE -->|SIGNED| SINE_S
    SINE -->|UNSIGNED| SINE_U
    SINE_S --> DEC
    SINE_U --> DEC
    DEC --> SCALER_S
    DEC --> SCALER_U

    style SINE fill:#ffe1e1
    style DEC fill:#fff4e1
    style SCALER_S fill:#e1ffe1
    style SCALER_U fill:#e1ffe1
```

---

## sine_gen_simple.vhd - Sine Wave Generator

### Description

`sine_gen_simple` keeps the public generator interface stable and selects a typed implementation from `data_type`. `data_type = "SIGNED"` instantiates `sine_gen_signed`; `data_type = "UNSIGNED"` instantiates `sine_gen_unsigned`.

The selected leaf generator produces a continuous sine wave using a lookup table (LUT) with elaboration-time computed constants. When enabled, the ramp logic fades the waveform amplitude in after reset. Pulse mode gates the sine with a rectangular or tapered envelope, so the same interface can produce sine bursts/radio pulses.

### Block Diagram

```mermaid
graph TB
    CLK[clk]
    RST[reset]

    subgraph "sine_gen_simple Wrapper"
        TYPE{data_type}
        SIGNED_LEAF[sine_gen_signed]
        UNSIGNED_LEAF[sine_gen_unsigned]
    end

    subgraph "Selected Leaf Generator"
        INDEX[Phase Accumulator<br/>0 to wave_length-1]
        RAMP_COUNT[Ramp Counter<br/>0 to ramp_length]
        PULSE_COUNT[Pulse Counter<br/>0 to pulse_period_cycles-1]
        
        subgraph "LUT Generation"
            FUNC[generate_sine_wave<br/>function]
            LUT[(SINE_WAVE<br/>Lookup Table)]
        end

        ENVELOPE[Typed ramp or pulse<br/>envelope scaling]
        OUTPUT[Output Register]
    end

    OUTPUT_DATA[output_data<br/>bit_width]

    TYPE -->|SIGNED| SIGNED_LEAF
    TYPE -->|UNSIGNED| UNSIGNED_LEAF
    SIGNED_LEAF --> INDEX
    UNSIGNED_LEAF --> INDEX
    CLK --> INDEX
    CLK --> RAMP_COUNT
    CLK --> PULSE_COUNT
    RST --> INDEX
    RST --> RAMP_COUNT
    RST --> PULSE_COUNT
    INDEX -->|Address| LUT
    FUNC -->|Elaboration| LUT
    LUT --> ENVELOPE
    RAMP_COUNT --> ENVELOPE
    PULSE_COUNT --> ENVELOPE
    ENVELOPE --> OUTPUT
    OUTPUT --> OUTPUT_DATA

    style CLK fill:#e1f5ff
    style RST fill:#ffe1e1
    style OUTPUT_DATA fill:#e1ffe1
    style LUT fill:#fff4e1
    style TYPE fill:#fff4e1
```

### Entity Declaration

```vhdl
entity sine_gen_simple is
  generic (
    wave_length              : positive := 1024;   -- Samples per full cycle
    bit_width                : positive := 16;     -- Output bit width
    data_type                : string   := "UNSIGNED";
    ramp_enable              : boolean  := false;
    ramp_length              : natural  := 0;
    pulse_enable             : boolean  := false;
    pulse_period_cycles      : positive := 1024;
    pulse_start_delay_cycles : natural  := 0;
    pulse_duration_cycles    : positive := 1024;
    pulse_front_cycles       : natural  := 0;
    pulse_fall_cycles        : natural  := 0
  );
  port (
    clk          : in    std_logic;
    reset        : in    std_logic;
    enable       : in    std_logic := '1';
    sample_ce    : in    std_logic := '1';
    output_valid : out   std_logic;
    output_data  : out   std_logic_vector(bit_width - 1 downto 0)
  );
end entity sine_gen_simple;
```

### Generics

| Generic | Type | Default | Description |
|---------|------|---------|-------------|
| `wave_length` | positive | 1024 | Number of samples per sine cycle |
| `bit_width` | positive | 16 | Output resolution in bits |
| `data_type` | string | "UNSIGNED" | Output format: "SIGNED" or "UNSIGNED" |
| `ramp_enable` | boolean | false | Enables post-reset amplitude ramp |
| `ramp_length` | natural | 0 | Ramp length in accepted samples; `0` uses `wave_length` |
| `pulse_enable` | boolean | false | Enables pulse-envelope output mode |
| `pulse_period_cycles` | positive | 1024 | Pulse frame length in input samples |
| `pulse_start_delay_cycles` | natural | 0 | Neutral/zero delay before the pulse |
| `pulse_duration_cycles` | positive | 1024 | Active pulse duration |
| `pulse_front_cycles` | natural | 0 | Rising envelope length |
| `pulse_fall_cycles` | natural | 0 | Falling envelope length |

### Ports

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk` | in | 1 | Clock input |
| `reset` | in | 1 | Active-high reset |
| `enable` | in | 1 | Generator enable |
| `sample_ce` | in | 1 | Sample advance clock-enable |
| `output_valid` | out | 1 | Pulses when `output_data` is updated |
| `output_data` | out | bit_width | Sine wave sample output |

### LUT Generation Algorithm

```mermaid
graph TB
    START[generate_sine_wave]
    
    subgraph "For each index i in selected leaf"
        ANGLE[Calculate angle<br/>θ = i × 2π / wave_length]
        SIN[Compute sine<br/>sin_val = sin(θ)]
        
        subgraph "Typed LUT Mapping"
            LEAF{selected leaf}
            SIGNED_MAP[sine_gen_signed<br/>scaled = sin_val × 2^(N-1)-1]
            UNSIGNED_MAP[sine_gen_unsigned<br/>scaled = sin_val+1 / 2 × 2^N-1]
        end
        
        CONVERT[Convert to selected type<br/>signed or unsigned]
    end

    WAVE[Return wave_array]

    START --> ANGLE --> SIN --> LEAF
    LEAF -->|SIGNED| SIGNED_MAP
    LEAF -->|UNSIGNED| UNSIGNED_MAP
    SIGNED_MAP --> CONVERT
    UNSIGNED_MAP --> CONVERT
    CONVERT --> WAVE

    style START fill:#f0e1ff
    style WAVE fill:#e1ffe1
    style LEAF fill:#fff4e1
```

### Data Type Mapping

#### Signed Mode

```
sin_val range: [-1.0, +1.0]
Output range:  [-2^(N-1), 2^(N-1)-1]

Example (N=6):
    sin_val = -1.0  →  -32
    sin_val =  0.0  →    0
    sin_val = +1.0  →   +31
```

```
    ▲ output_data
    │
 31 ┤        ╭─────╮
    │      ╭─╯     ╰─╮
    │    ╭─╯         ╰─╮
    │  ╭╯               ╰╮
  0 ┤──╯                 ╰──
    │ ╭╮               ╭╮
    │  ╰╮               ╭╯
-32 ┤    ╰─────────────╯
    │
    └──────────────────────────────► index
    0          1024         2048
```

#### Unsigned Mode

```
sin_val range: [-1.0, +1.0]
Output range:  [0, 2^N-1]

Example (N=6):
    sin_val = -1.0  →    0
    sin_val =  0.0  →   32
    sin_val = +1.0  →   63
```

```
    ▲ output_data
    │
 63 ┤        ╭─────╮
    │      ╭─╯     ╰─╮
    │    ╭─╯         ╰─╮
    │  ╭╯               ╰╮
 32 ┤──╯                 ╰──
    │ ╭╮               ╭╮
    │  ╰╮               ╭╯
  0 ┤    ╰─────────────╯
    │
    └──────────────────────────────► index
    0          1024         2048
```

### Operation

```mermaid
stateDiagram-v2
    [*] --> RESET: reset='1'
    RESET --> IDLE: reset='0', index=0

    IDLE --> RUNNING: rising_edge(clk)
    RUNNING --> RUNNING: index < wave_length-1<br/>index <= index + 1
    RUNNING --> WRAP: index = wave_length-1
    WRAP --> RUNNING: index <= 0

    note right of RUNNING
        Output: ramped SINE_WAVE(index)
        - Signed: scales sample toward 0
        - Unsigned: scales AC component around midpoint
    end note
```

### Soft-Start Ramp

With `ramp_enable = true`, `ramp_count` increments once per accepted sample until the effective ramp length is reached. Signed output multiplies each sample by `ramp_count / ramp_length`, so the waveform starts at zero amplitude. Unsigned output preserves the midpoint and scales only the AC component, so the first active unsigned sample starts near midscale rather than rail zero.

The current top-level build uses the pulse-envelope generics instead of the soft-start ramp, but the ramp remains available for standalone generator tests and alternate integrations.

### Pulse and Radio-Burst Sizing

In pulse mode, `wave_length` is the number of samples in one carrier sine cycle. It is not the pulse length. The pulse envelope is controlled by the `pulse_*` generics, and all of these counts advance only when `sample_ce = '1'`.

Use these formulas:

```text
sample_rate_hz = clk_hz / sample_ce_divider
wave_length = round(sample_rate_hz / carrier_hz)
actual_carrier_hz = sample_rate_hz / wave_length

pulse_duration_cycles = round(pulse_duration_seconds * sample_rate_hz)
pulse_period_cycles = round(pulse_repeat_period_seconds * sample_rate_hz)
carrier_cycles_per_pulse = pulse_duration_cycles / wave_length
```

For the buffered PWM top level, the source `sample_ce` rate should match the PWM sample playback rate. With the current 100 MHz signal-chain clock and the default `/2` PWM post-scaler, this is usually done with:

```text
input_data_decimation_factor = 2 ** (pwm_resolution_bits + 1)
sample_rate_hz = 100_000_000 / input_data_decimation_factor
```

Example: about a 100 kHz carrier, about a 1 ms radio pulse, and an equal 1 ms off-time:

```text
pwm_resolution_bits = 5
input_data_decimation_factor = 2 ** (5 + 1) = 64
sample_rate_hz = 100_000_000 / 64 = 1_562_500 samples/s

wave_length = round(1_562_500 / 100_000) = 16
actual_carrier_hz = 1_562_500 / 16 = 97_656.25 Hz

pulse_duration_cycles = 100 carrier cycles * 16 samples = 1600
actual_pulse_duration = 1600 / 1_562_500 = 1.024 ms
pulse_period_cycles = 3200
```

The matching top-level values are:

```vhdl
pwm_resolution_bits           => 5,
sine_wave_length              => 16,
sine_pulse_period_cycles      => 3200,
sine_pulse_start_delay_cycles => 0,
sine_pulse_duration_cycles    => 1600,
sine_pulse_front_cycles       => 0,
sine_pulse_fall_cycles        => 0
```

If the duration must be closer to exactly 1 ms, use `pulse_duration_cycles = 1563` at this sample rate. That gives about 1.000 ms, but the burst ends after about 97.7 carrier cycles rather than at an integer carrier-cycle boundary.

### Usage Example

```vhdl
-- In main.vhd:
dut_sine : entity work.sine_gen_simple
  generic map (
    wave_length => 2048,           -- 2048 samples
    bit_width   => 6,              -- 6-bit output
    data_type   => "SIGNED",       -- Signed output
    ramp_enable => true,
    ramp_length => 2048
  )
  port map (
    clk         => clk,            -- 50 MHz in current board builds
    reset       => sine_rst,
    enable      => '1',
    sample_ce   => '1',
    output_valid => open,
    output_data => sine_out        -- 6-bit sine wave
  );
```

### Resource Usage

| Resource | Estimate | Notes |
|----------|----------|-------|
| Block RAM | 1 | For 2048×6 LUT |
| LUTs | ~10 | Index logic |
| FFs | ~10 | Pipeline registers |

---

## data_decimator.vhd - Sample Rate Decimator

### Description

Reduces the sample rate by an integer factor, outputting one sample every N input samples.

### Block Diagram

```mermaid
graph TB
    CLK[clk]
    RST[rst]
    DATA_IN[data_in<br/>data_width]

    subgraph "Decimator"
        COUNT[Counter<br/>0 to decimation_factor-1]
        VALID_GEN[valid_int Generator]
        OUTPUT_REG[Output Register]
    end

    DATA_OUT[data_out<br/>data_width]
    VALID_OUT[valid_out]

    CLK --> COUNT
    RST --> COUNT
    RST --> VALID_GEN
    DATA_IN --> OUTPUT_REG

    COUNT --> VALID_GEN
    VALID_GEN --> OUTPUT_REG

    OUTPUT_REG --> DATA_OUT
    VALID_GEN --> VALID_OUT

    style DATA_IN fill:#e1f5ff
    style DATA_OUT fill:#e1ffe1
    style VALID_OUT fill:#fff4e1
```

### Entity Declaration

```vhdl
entity data_decimator is
  generic (
    data_width        : integer := 16;  -- Width of input data
    decimation_factor : integer := 100  -- Rate reduction factor
  );
  port (
    clk       : in    std_logic;
    rst       : in    std_logic;
    data_in   : in    std_logic_vector(data_width - 1 downto 0);
    data_out  : out   std_logic_vector(data_width - 1 downto 0);
    valid_out : out   std_logic
  );
end entity data_decimator;
```

### Generics

| Generic | Type | Default | Description |
|---------|------|---------|-------------|
| `data_width` | integer | 16 | Input/output data width |
| `decimation_factor` | integer | 100 | Output rate = input_rate / factor |

### Ports

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk` | in | 1 | Clock input |
| `rst` | in | 1 | Active-high reset |
| `data_in` | in | data_width | High-rate input stream |
| `data_out` | out | data_width | Decimated output stream |
| `valid_out` | out | 1 | Pulse when new sample valid |

### Operation Timing

```
Input: 100 MHz
Decimation Factor: 100
Output: 1 MHz
```

```mermaid
gantt
    title Decimator Timing Diagram (factor=4 example)
    dateFormat X
    axisFormat %t
    
    section Clock
    clk          :0, 1, 2, 3, 4, 5, 6, 7, 8
    
    section Counter
    count_reg    :0, 1, 2, 3, 0, 1, 2, 3, 0
    
    section Output
    valid_out    :crit, 0, 0, 0, 1, 0, 0, 0, 1, 0
    data_out     :crit, -, -, -, d0, -, -, -, d1, -
```

### Text Timing Diagram

```
Clock:       ─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─
             └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘

count_reg:   0   1   2   3   0   1   2   3   0
                                     (factor=4)

valid_out:   0   0   0   1   0   0   0   1   0
                     ▲               ▲
                   sample          sample

data_out:    -   -   -  d0   -   -   -  d1   -
```

### Algorithm

```vhdl
process (clk, rst) is
begin
  if rst = '1' then
    count_reg <= 0;
    valid_int <= '0';
    data_out  <= (others => '0');
  elsif rising_edge(clk) then
    valid_int <= '0';  -- Default: not valid

    if count_reg = decimation_factor - 1 then
      count_reg <= 0;
      valid_int <= '1';           -- Pulse valid for 1 cycle
      data_out  <= data_in;       -- Capture current input
    else
      count_reg <= count_reg + 1;
    end if;
  end if;
end process;
```

### Usage in PWM System

```vhdl
-- In pwm_mch_buf.vhd:
dec_sine : entity work.data_decimator
  generic map (
    data_width        => r,              -- PWM resolution
    decimation_factor => decimation_factor
  )
  port map (
    clk       => clk,
    rst       => rst,
    data_in   => input_wave,             -- From sine generator
    data_out  => dec_wave,               -- Decimated output
    valid_out => valid_wave              -- Valid pulse
  );
```

### Decimation Factor Calculation

```
For SYMMETRICAL PWM:
    pwm_cycle_length = 2^(r+1)
    decimation_real = (clk_freq_hz * pwm_cycle_length) / clk_pwm_freq_hz
    decimation = round(decimation_real * 0.95)
    
    Standalone DECIMATED-mode example (r=6, clk:clk_pwm = 50:100 MHz):
    decimation_real = (50 MHz * 128) / 100 MHz = 64
    decimation = round(64 * 0.95) = 61
    
For ASYMMETRICAL PWM:
    pwm_cycle_length = 2^r
    decimation_real = (clk_freq_hz * pwm_cycle_length) / clk_pwm_freq_hz
    decimation = round(decimation_real * 0.95)
    
    Same standalone clock ratio, r=6:
    decimation_real = (50 MHz * 64) / 100 MHz = 32
    decimation = round(32 * 0.95) = 30
```

The current board top-level uses `pwm_mch_buf` in `VALID` mode with a raw 200 MHz `clk_pwm` and a `/2`, `/4`, `/8`, or `/16` post-scaled tick. In that path, the top-level drives `input_data_decimation_factor` directly instead of using `data_decimator`.

---

## scaler_signed.vhd - Signed Amplitude Scaler

### Description

Scales signed input data by a fixed factor using fixed-point multiplication.

### Block Diagram

```mermaid
graph TB
    CLK[clk]
    RST[reset]
    INPUT[input_data<br/>Q-format signed]

    subgraph "Scaler"
        MUL[Signed Multiply<br/>input_sig × scale]
        TRUNC[Truncate<br/>Take upper bits]
        ADD[Add Offset<br/>scaled + offset]
        OUTPUT_REG[Output Register]
    end

    OUTPUT[output_data<br/>Q-format signed]

    CLK --> MUL
    RST --> OUTPUT_REG
    INPUT --> MUL

    MUL --> TRUNC
    TRUNC --> ADD
    ADD --> OUTPUT_REG
    OUTPUT_REG --> OUTPUT

    style INPUT fill:#e1f5ff
    style OUTPUT fill:#e1ffe1
    style MUL fill:#fff4e1
```

### Entity Declaration

```vhdl
entity scaler_signed is
  generic (
    r             : integer := 16;  -- Data width
    scale_factor  : real    := 0.8; -- Scaling factor
    offset_factor : real    := 0.1  -- Offset factor
  );
  port (
    clk         : in    std_logic;
    reset       : in    std_logic;
    input_data  : in    std_logic_vector(r - 1 downto 0);
    output_data : out   std_logic_vector(r - 1 downto 0)
  );
end entity scaler_signed;
```

### Generics

| Generic | Type | Default | Description |
|---------|------|---------|-------------|
| `r` | integer | 16 | Data width in bits |
| `scale_factor` | real | 0.8 | Multiplication factor |
| `offset_factor` | real | 0.1 | Signed offset factor |

### Ports

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk` | in | 1 | Clock input |
| `reset` | in | 1 | Active-high reset |
| `input_data` | in | r | Signed input (Q1.N-1 format) |
| `output_data` | out | r | Scaled signed output |

### Multiplication Algorithm

```mermaid
graph LR
    INPUT[input_data<br/>Q1.15] --> SIGN[input_sig<br/>signed r-bit]
    SCALE[scale constant<br/>Q1.15] --> MUL

    SIGN --> MUL[Signed Multiply<br/>r × r → 2r-1 bits]
    MUL --> PRODUCT[product<br/>2r-1 downto 0]
    PRODUCT --> TRUNC[Truncate<br/>Take bits 2r-1:r]
    TRUNC --> SCALED[scaled<br/>r-bit]
    OFFSET[offset constant] --> ADD[Add Offset]
    SCALED --> ADD
    ADD --> OUTPUT[output_data]

    style INPUT fill:#e1f5ff
    style OUTPUT fill:#e1ffe1
    style MUL fill:#fff4e1
    style TRUNC fill:#f0e1ff
```

### Fixed-Point Format

```
Input:  Q1.15 format (1 sign bit, 15 fraction bits)
        Range: -1.0 to +0.99997

Scale:  Q1.15-style constant from scale_factor
        Example: 0.8 → 26213 (0.8 × 32767)

Offset: Q1.15-style constant from offset_factor
        Example: 0.1 → 3276 (0.1 × 32767)
```

### Example Calculation

```
For r=16, scale_factor=0.8, offset_factor=0.1:

Input:    0.5 (in Q1.15: 0.5 × 32768 = 16384)
Scale:    0.8 (constant: 0.8 × 32767 = 26213)
Offset:   0.1 (constant: 0.1 × 32767 = 3276)

Multiply: 16384 × 26213 = 429,473,792

Truncate: Take bits [31:16]
          = 6553 decimal

Add Offset: 6553 + 3276 = 9829
```

### Operation

```vhdl
process (clk, reset) is
begin
  if reset = '1' then
    output_data <= (others => '0');
  elsif rising_edge(clk) then
    -- Signed multiplication: 16 × 16 → 32 bits
    product <= input_sig * scale;

    -- Take upper 16 bits, then add the configured signed offset.
    scaled <= product(2*r - 1 downto r);
    result <= scaled + offset;

    output_data <= std_logic_vector(result);
  end if;
end process;
```

---

## scaler_unsigned.vhd - Unsigned Amplitude Scaler

### Description

Scales unsigned input data and adds a DC offset, designed for PWM modulation.

### Block Diagram

```mermaid
graph TB
    CLK[clk]
    RST[reset]
    INPUT[input_data<br/>unsigned r-bit]

    subgraph "Scaler with Offset"
        TO_UNSIGNED[input_uns<br/>unsigned]
        MUL[Unsigned Multiply<br/>input_uns × scale]
        TRUNC[Truncate<br/>Take upper bits]
        ADD[Add Offset<br/>scaled + offset]
        OUTPUT_REG[Output Register]
    end

    OUTPUT[output_data<br/>unsigned r-bit]

    CLK --> MUL
    CLK --> ADD
    RST --> OUTPUT_REG
    INPUT --> TO_UNSIGNED

    TO_UNSIGNED --> MUL
    MUL --> TRUNC
    TRUNC --> ADD
    ADD --> OUTPUT_REG
    OUTPUT_REG --> OUTPUT

    style INPUT fill:#e1f5ff
    style OUTPUT fill:#e1ffe1
    style MUL fill:#fff4e1
    style ADD fill:#f0e1ff
```

### Entity Declaration

```vhdl
entity scaler_unsigned is
  generic (
    r             : integer := 16;
    scale_factor  : real    := 0.8;
    offset_factor : real    := 0.1
  );
  port (
    clk         : in    std_logic;
    reset       : in    std_logic;
    input_data  : in    std_logic_vector(r - 1 downto 0);
    output_data : out   std_logic_vector(r - 1 downto 0)
  );
end entity scaler_unsigned;
```

### Generics

| Generic | Type | Default | Description |
|---------|------|---------|-------------|
| `r` | integer | 16 | Data width in bits |
| `scale_factor` | real | 0.8 | Amplitude scaling factor |
| `offset_factor` | real | 0.1 | DC offset factor |

### Ports

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk` | in | 1 | Clock input |
| `reset` | in | 1 | Active-high reset |
| `input_data` | in | r | Unsigned input |
| `output_data` | out | r | Scaled output with offset |

### Operation

```mermaid
graph LR
    INPUT[input_data] --> CONV[Reinterpret<br/>as unsigned]
    CONV --> MUL[Unsigned Multiply<br/>r × r → 2r bits]
    SCALE[scale constant] --> MUL
    MUL --> TRUNC[Truncate<br/>bits 2r-1:r]
    TRUNC --> SCALED[scaled]
    
    OFFSET[offset constant] --> ADD[Add]
    SCALED --> ADD
    ADD --> RESULT[result]
    RESULT --> OUTPUT[output_data]

    style INPUT fill:#e1f5ff
    style OUTPUT fill:#e1ffe1
    style MUL fill:#fff4e1
    style ADD fill:#f0e1ff
```

### Example Calculation

```
For r=16, scale_factor=0.8, offset_factor=0.1:

Constants:
    max_val    = 2^15 = 32768
    scale_int  = 0.8 × 32768 = 26214
    offset_int = 0.1 × 32768 = 3277

Input:    32768 (mid-scale, represents 0.5)

Multiply: 32768 × 26214 = 858,960,896
          = 0x3333_0000

Truncate: Take bits [31:16]
          = 0x3333 = 13107

Add Offset: 13107 + 3277 = 16384

Output:   16384 (mid-scale, represents 0.5 × 0.8 + 0.1 = 0.5) ✓
```

### Usage in PWM System

```vhdl
-- In pwm_1ch.vhd:
set_scaler_type_signed : if INPUT_DATA_TYPE = "SIGNED" generate
  rsc : entity work.scaler_signed
    generic map (
      r             => r,
      scale_factor  => scale_factor,
      offset_factor => offset_factor
    )
    port map (
      clk         => clk,
      reset       => rst,
      input_data  => input_reg,
      output_data => scaled_output
    );
end generate;

set_scaler_type_unsigned : if INPUT_DATA_TYPE = "UNSIGNED" generate
  rsc : entity work.scaler_unsigned
    generic map (
      r             => r,
      scale_factor  => scale_factor,
      offset_factor => offset_factor
    )
    port map (
      clk         => clk,
      reset       => rst,
      input_data  => input_reg,
      output_data => scaled_output
    );
end generate;
```

---

## Scaler Comparison

| Feature | scaler_signed | scaler_unsigned |
|---------|---------------|-----------------|
| **Input Format** | Q1.N-1 signed | Unsigned binary |
| **Output Range** | -scale to +scale | offset to scale+offset |
| **Multiplication** | Signed × Signed | Unsigned × Unsigned |
| **Truncation** | Bits [2r-1:r] | Bits [2r-1:r] |
| **DC Offset** | Explicit signed offset | Explicit unsigned offset |
| **Generics** | 3 (r, scale, offset) | 3 (r, scale, offset) |
| **Use Case** | Signed AC signals with optional bias | PWM with DC bias |

---

## Signal Chain Data Flow

```mermaid
graph TB
    subgraph "Stage 1: Waveform Generation"
        SINE[sine_gen_simple]
    end

    subgraph "Stage 2: Sample Rate Conversion"
        DEC[data_decimator]
    end

    subgraph "Stage 3: Clock Domain Crossing"
        FIFO[async_fifo]
    end

    subgraph "Stage 4: Amplitude Scaling"
        SCALER{data_type?}
        SCALER_S[scaler_signed]
        SCALER_U[scaler_unsigned]
    end

    subgraph "Stage 5: PWM Generation"
        PWM[pwm_1ch]
    end

    SINE --> DEC
    DEC --> FIFO
    FIFO --> SCALER
    SCALER -->|SIGNED| SCALER_S
    SCALER -->|UNSIGNED| SCALER_U
    SCALER_S --> PWM
    SCALER_U --> PWM

    style SINE fill:#ffe1e1
    style DEC fill:#fff4e1
    style FIFO fill:#f0e1ff
    style SCALER_S fill:#e1ffe1
    style SCALER_U fill:#e1ffe1
    style PWM fill:#ffe1e1
```

---

## Test Coverage

All signal chain modules have testbenches:

```
tb/
├── tb_main.vhd              -- Full signal chain test
├── tb_pwm_mch.vhd           -- Integration with PWM
└── tb_scalers.vhd           -- Scaler-specific tests
```

---

## See Also

- [PWM Modules](../pwm/README.md)
- [Async FIFO](../buffers/README.md)
- [Counter Modules](../counters/README.md)
