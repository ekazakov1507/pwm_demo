# Top-Level Architecture

## System Overview

This document describes the overall system architecture of the PWM Demo project.

## Block Diagram

```mermaid
graph TB
    subgraph "External World"
        CLK_IN[sys_clk<br/>100 MHz Input]
        PWM_OUT[sys_pwm<br/>N Channels]
        PWM_N_OUT[sys_pwm_n<br/>N Complementary Channels]
    end

    subgraph "Clock Domain 1: Input Buffering"
        IBUF[IBUF<br/>Input Buffer]
        BUFG[BUFG<br/>Global Buffer]
    end

    subgraph "MMCM Clock Generator"
        MMCM[MMCME2_ADV<br/>Clock Manager]
        CLK_FB[Feedback Loop]
    end

    subgraph "Clock Domain 2: System Clock (clk = 50 MHz)"
        SINE[Sine Generator<br/>sine_gen_simple + ramp]
        SINE_OUT[sine_out<br/>6-bit Signed]
        DIRECT_PWM[pwm_mch<br/>Direct PWM]
        RESET_CTRL[main_reset_ctrl<br/>Reset + mode handoff]
    end

    subgraph "Clock Domain 3: PWM Clock (clk_pwm = 100 MHz)"
        PWM_MODULE[pwm_mch_buf<br/>Buffered PWM]
        PWM_BUF[p_buf<br/>Buffered PWM]
        PWM_N_BUF[p_n_buf<br/>Buffered PWM_N]
    end

    subgraph "Output Selection"
        MODE_SEL[Direct / Buffered<br/>mode select]
    end

    subgraph "Output Buffers"
        OBUF_P[OBUF × N<br/>PWM Outputs]
        OBUF_N[OBUF × N<br/>PWM_N Outputs]
    end

    CLK_IN --> IBUF
    IBUF --> BUFG
    BUFG --> MMCM
    MMCM -->|clkout1: 50 MHz| SINE
    MMCM -->|clkout1: 50 MHz| RESET_CTRL
    MMCM -->|clkout2: 100 MHz| PWM_MODULE
    MMCM -->|clkfbin| CLK_FB
    CLK_FB --> MMCM

    SINE -->|sine_out| DIRECT_PWM
    SINE -->|sine_out via CDC| PWM_MODULE
    RESET_CTRL -->|sine_rst| SINE
    RESET_CTRL -->|pwm_rst| DIRECT_PWM
    RESET_CTRL -->|pwm_rst| PWM_MODULE
    DIRECT_PWM --> MODE_SEL
    PWM_MODULE --> MODE_SEL
    MODE_SEL -->|selected pwm| OBUF_P
    MODE_SEL -->|selected pwm_n| OBUF_N
    OBUF_P --> PWM_OUT
    OBUF_N --> PWM_N_OUT

    style CLK_IN fill:#e1f5ff
    style PWM_OUT fill:#ffe1e1
    style PWM_N_OUT fill:#ffe1e1
    style SINE fill:#fff4e1
    style PWM_MODULE fill:#fff4e1
    style MMCM fill:#f0e1ff
```

## Clock Architecture

```mermaid
graph LR
    subgraph "Input Stage"
        EXT_CLK[External Clock<br/>100 MHz]
        IBUF[IBUF]
        BUFG[BUFG]
    end

    subgraph "MMCM"
        MMCM[MMCME2_ADV]
        MULT[clkfbout_mult_f = 8.0]
        DIV1[clkout1_divide = 16]
        DIV2[clkout2_divide = 8]
    end

    subgraph "Output Clocks"
        CLK_SYS[clk<br/>50 MHz]
        CLK_PWM[clk_pwm<br/>100 MHz]
    end

    EXT_CLK --> IBUF --> BUFG -->|clkin1| MMCM
    MMCM -->|Feedback| MULT
    MULT -->|Divide by 16| DIV1 --> CLK_SYS
    MULT -->|Divide by 8| DIV2 --> CLK_PWM

    style EXT_CLK fill:#e1f5ff
    style CLK_SYS fill:#ffe1e1
    style CLK_PWM fill:#e1ffe1
```

### Clock Frequency Calculation

```
Input Clock:     100 MHz (current board XDC)
MMCM Multiply:   × 8.0
Feedback Clock:  800 MHz (internal VCO)

clkout1: 800 MHz / 16 = 50 MHz
clkout2: 800 MHz / 8  = 100 MHz
```

**Note**: The checked-in board constraints define `sys_clk` as 10 ns. If a board clock is retargeted, keep the XDC constraint and MMCM input-period metadata consistent.

## Data Flow

```mermaid
sequenceDiagram
    participant CLK as Clock System
    participant SINE as Sine Generator
    participant PWM as PWM Module
    participant OUT as Output Buffers

    CLK->>SINE: clk (50 MHz)
    CLK->>PWM: clk_pwm (100 MHz)

    loop Every 50 MHz Clock Cycle
        SINE->>SINE: Generate next<br/>ramped sine sample
        SINE->>PWM: sine_out (6-bit)
    end

    loop Every 100 MHz Clock Cycle
        PWM->>PWM: Compare with<br/>reference counter
        PWM->>PWM: Apply dead-time
        PWM->>OUT: p_buf, p_n_buf
        OUT->>OUT: Drive external pins
    end
```

## Signal Chain

```
┌─────────────────────────────────────────────────────────────┐
│                     System Clock Domain                      │
│                       (clk = 50 MHz)                         │
│                                                              │
│  ┌──────────────────┐                                       │
│  │  Sine Generator  │  sine_gen_simple                      │
│  │                  │  - Lookup table (2048 points)          │
│  │                  │  - Soft-start amplitude ramp           │
│  │                  │  - 6-bit signed output                 │
│  └────────┬─────────┘                                       │
│           │ sine_out                                         │
└───────────┼──────────────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────────────┐
│                     PWM Clock Domain                         │
│                    (clk_pwm = 100 MHz)                       │
│                                                              │
│  ┌──────────────────┐      ┌──────────────────┐            │
│  │  Data Decimator  │─────▶│  Async FIFO       │            │
│  │  (if present)    │      │  - CDC crossing   │            │
│  └──────────────────┘      └────────┬─────────┘            │
│                                     │ buf_output             │
│                                     ▼                        │
│                           ┌──────────────────┐              │
│                           │  PWM Controller   │              │
│                           │  - Capture duty   │              │
│                           │  - Generate PWM   │              │
│                           └────────┬─────────┘              │
│                                    │                        │
│  ┌──────────────────┐      ┌───────┴────────┐              │
│  │  PWM Channel 0   │      │  PWM Channel N  │              │
│  │  - Ref counter   │      │  - Ref counter   │              │
│  │  - Comparator    │      │  - Comparator    │              │
│  │  - Dead-time     │      │  - Dead-time     │              │
│  └────────┬─────────┘      └────────┬─────────┘              │
│           │ p_buf[0]                │ p_buf[N]                │
└───────────┼─────────────────────────┼────────────────────────┘
            │                         │
            ▼                         ▼
        ┌───────┐                 ┌───────┐
        │ OBUF  │                 │ OBUF  │
        └───┬───┘                 └───┬───┘
            │                         │
            ▼                         ▼
        sys_pwm[0]                sys_pwm[N]
```

## Module Hierarchy

```
main.vhd (Top-Level)
│
├── Clock System
│   ├── IBUF (Input Buffer)
│   ├── BUFG (Global Buffer)
│   └── MMCME2_ADV (Clock Manager)
│       ├── clkout1 → clk (50 MHz)
│       └── clkout2 → clk_pwm (100 MHz)
│
├── Signal Generation (clk domain)
│   └── sine_gen_simple
│       └── Lookup Table + soft-start ramp (2048 samples, 6-bit)
│
├── Direct PWM Generation (clk domain)
│   └── pwm_mch
│       └── pwm_1ch × N
│
├── Buffered PWM Generation (clk/clk_pwm domains)
│   └── pwm_mch_buf
│       ├── async_fifo (CDC: clk → clk_pwm)
│       ├── pwm_reg_ctrl (Duty cycle capture)
│       │
│       └── pwm_1ch × N (Channel instances)
│           ├── Counter (symmetrical/asymmetrical)
│           │   ├── updown_counter_signed (SYMMETRICAL)
│           │   └── up_counter_signed (ASYMMETRICAL)
│           ├── Scaler (Amplitude scaling)
│           │   ├── scaler_signed
│           │   └── scaler_unsigned
│           ├── pwm_1ch_drive_pkg (complementary leg generation)
│           └── dead_time_generator (dead-time insertion)
│               ├── pwm_state / pwm_n_state → pwm / pwm_n
│
└── Output Selection
    └── main_reset_ctrl-controlled direct/buffered mux with reset blanking
```

## Key Design Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| Input Clock | 100 MHz | Current board XDC constraint |
| System Clock (clk) | 50 MHz | Sine generation and direct PWM branch |
| PWM Clock (clk_pwm) | 100 MHz | Buffered PWM reference counter and outputs |
| PWM Resolution | 6 bits | 64 discrete levels |
| Number of Channels | 4 | Configurable (default) |
| Dead Time | 4 cycles | PWM to PWM_N delay |
| Sine Table Length | 2048 | Samples per cycle |
| Sine Ramp Length | 2048 | Default soft-start length in `clk` cycles |
| Buffer Depth | 1024 | FIFO depth for CDC |

## Clock Domain Crossing

The design implements two clock domains:

1. **clk (50 MHz)**: Sine wave generation and direct PWM branch
2. **clk_pwm (100 MHz)**: Buffered PWM modulation and output

Data crossing is handled by:
- **Asynchronous FIFO** (`async_fifo`)
- Gray-coded pointers for safe crossing
- 3-stage synchronizers for control signals

```mermaid
graph TD
    subgraph "clk Domain (50 MHz)"
        SINE[sine_gen_simple]
        DEC[data_decimator]
        FIFO_WR[async_fifo<br/>Write Side]
    end

    subgraph "clk_pwm Domain (100 MHz)"
        FIFO_RD[async_fifo<br/>Read Side]
        PWM[pwm_mch_buf]
        CH[pwm_1ch]
    end

    SINE --> DEC
    DEC --> FIFO_WR
    FIFO_WR -.->|Gray Code| FIFO_RD
    FIFO_RD --> PWM
    PWM --> CH

    style SINE fill:#ffe1e1
    style DEC fill:#ffe1e1
    style FIFO_WR fill:#ffe1e1
    style FIFO_RD fill:#e1ffe1
    style PWM fill:#e1ffe1
    style CH fill:#e1ffe1
```

## Output Configuration

Each channel produces a complementary pair:

```
sys_pwm[i]   ──┐
                ├──┤ Power Stage ├──┤ Motor/Load
sys_pwm_n[i] ──┘

Dead-time inserted to prevent shoot-through
```

### Dead-Time Operation

```
pwm_state:    ────────┐          ┌────────────
                      │          │
                      │          │
                      └──────────┘

Dead-time:    ──┐
                │ (delay)
                └───────────────────

pwm output:   ────────┐          ┌────────────
                      │          │
                      └──────────┘


pwm_n_state:  ┌───────────────────┐
              │                   │
              └───────────────────┘

Dead-time:    ─────────────┐
                           │ (delay)
                           └──────────

pwm_n output: ┌───────────────────┐
              │                   │
              └───────────────────┘

              ◄─ dead_time ─►
```

## Design Constraints

### Timing Requirements

- **clk period**: 20 ns (50 MHz) in current board builds
- **clk_pwm period**: 10 ns (100 MHz) in current board builds
- **PWM frequency**: ~781.25 kHz for 6-bit symmetrical mode
- **Modulation frequency**: ~24.4 kHz sine LUT rate with `wave_length = 2048`

### Resource Utilization

Estimated for Zynq-7020 (XC7Z020):
- **LUTs**: ~500-1000 (depends on channel count)
- **FFs**: ~300-600
- **Block RAM**: 1-2 (for sine table + FIFO)
- **MMCM**: 1

## See Also

- [main.vhd Documentation](../src/main.md)
- [PWM Modules](../src/pwm/README.md)
- [Clock Domain Details](./clock_domains.md)
- [Module Hierarchy](./hierarchy.md)
