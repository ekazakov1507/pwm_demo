# pwm_demo src VHDL review

Date: 2026-07-19

Scope:

- Reviewed `src/**/*.vhd` in `pwm_demo`.
- `src/pwm_core` is treated as an already reviewed submodule; this note only references it where the top-level integration depends on its interface.
- Testbenches, docs, Octave scripts, constraints, and build scripts were not reviewed in this pass.
- No code changes were made as part of this review.

## Summary

The current top-level path is:

```text
sine_gen_simple, 16-bit
  -> source_sample = source_sine_out MSBs truncated to pwm_resolution_bits
  -> pwm_mch_buf FIFO, width r = pwm_resolution_bits
  -> pwm_core pwm_1ch, width r = pwm_resolution_bits
```

So for a 5-bit PWM build the design first generates the signal at 16 bits, then takes the top 5 bits, then writes those 5-bit samples into the FIFO. That is structurally consistent with a fixed-resolution PWM build. The remaining risks are mostly around reset timing, frame alignment, FIFO handshaking, and the hidden coupling between clock frequencies, post-divider, and sample pacing.

## Findings

### P1: `rst_pwm` can release inactive before synchronized reset arrives

File: `src/pwm/pwm_mch_buf.vhd`

Relevant lines:

- `rst_sync` is initialized to `"000"`.
- `rst_pwm` is initialized to `'1'`.
- `rst_pwm <= rst_sync(2)` in the `clk_pwm` process.

Issue:

On startup or when `rst` is asserted in the `clk` domain, the `clk_pwm` domain reset can briefly go inactive because the synchronization shift register starts at zeros and is only later filled with the current `rst` value. That can allow read-side FIFO logic, stream state, post-scaler, and PWM channels to run for a few `clk_pwm` cycles during what should be reset.

Risk:

At high clock rates this can produce a short uncontrolled startup window or make reset behavior dependent on relative clock phase.

Recommended fix:

Initialize the reset synchronizer to active state and keep reset assertion immediate enough for this integration, with synchronous release. For example, start `rst_sync` as `"111"` and review whether reset assertion must be asynchronously forced or only synchronously sampled.

### P1/P2: first FIFO read is delayed by one full PWM frame

File: `src/pwm/pwm_mch_buf.vhd`

Relevant lines:

- `stream_active` becomes active when `fifo_level >= stream_start_sample_count`.
- `buf_rd_en` is requested only when local `cnt = pwm_cycle_length - 1`.
- `duty_cycle` updates one cycle later through `buf_rd_valid`.

Issue:

After enough samples are buffered, the reader does not immediately request the first sample. It waits for one complete locally counted PWM frame, then waits for FIFO read latency. During that time `duty_cycle` remains neutral.

Risk:

This is a likely source of a one-frame startup delay and can shift the relationship between buffered samples and PWM frames. It is especially suspicious for the "PWM slots of the second kind" concern because the read scheduler is not explicitly locked to a known `pwm_1ch` frame-start event.

Recommended fix:

Add an explicit read/start state, or preload the first duty sample before releasing `pwm_stream_rst`. The cleanest option is usually:

1. Wait for prefill threshold.
2. Issue first FIFO read.
3. Latch `duty_cycle`.
4. Release PWM stream reset on a known frame boundary.
5. Then read one new sample per PWM frame.

### P2: FIFO samples do not carry pulse-frame boundaries

File: `src/pwm/pwm_mch_buf.vhd`

Relevant lines:

- `pulse_period_samples` is converted into `prefill_sample_count`, `resume_sample_count`, and `refill_sample_count`.
- FIFO stores only `r`-bit duty samples.

Issue:

The design treats pulse frames as sample counts outside the FIFO, but the FIFO payload has no `start_of_frame`, `end_of_frame`, or sequence marker. If one sample is dropped, duplicated, or accepted unexpectedly, the downstream side cannot detect that the pulse-frame boundary shifted.

Risk:

A single handshake error or underflow/restart can silently misalign later PWM output against the intended pulse frame.

Recommended fix:

If pulse-frame alignment matters, pack metadata into the FIFO together with the duty sample, such as:

- `sample`
- `sof` or `frame_start`
- optional `eof` or modulo sample index

Then make the read-side state machine use the marker to align the first PWM frame after restart.

### P2: `VALID` writer can accept `input_valid` while in `writer_idle`

File: `src/pwm/pwm_mch_buf.vhd`

Relevant lines:

- `buf_wr_en` is asserted whenever `input_valid = '1'` and `buf_full = '0'`.
- This write check happens before the `writer_state` decision.

Issue:

In `VALID` mode, the writer can write samples even when it is in `writer_idle`, as long as upstream presents `input_valid`. In the current `main` integration, upstream `sine_gen_simple` normally only advances when `input_sample_ce` is asserted, so this is partly masked. But as a reusable module handshake, `input_valid` is accepted too broadly.

Risk:

With a different upstream source, stale or extra valid samples can be packed into the FIFO and shift the pulse-frame contents.

Recommended fix:

Gate writes with writer activity. For example, allow FIFO writes only in `writer_prefill` and `writer_refill`, or define the interface contract clearly as "all `input_valid` pulses are accepted when FIFO is not full."

### P2: sample pacing depends on hidden clock and post-divider assumptions

Files:

- `src/main.vhd`
- `src/pwm/pwm_mch_buf.vhd`
- `src/utils/pwm_clk_post_scaler.vhd`

Relevant lines:

- `clk_freq_hz = 100_000_000`
- `clk_pwm_freq_hz = 200_000_000`
- `input_data_decimation_factor = 2 ** (pwm_resolution_bits + 1)`
- `use_post_scaler => true`
- post-divider runtime values are `/2`, `/4`, `/8`, `/16`

Issue:

For `SYMMETRICAL` PWM the frame length is `2 ** (r + 1)` raw PWM ticks. With `clk = 100 MHz`, `clk_pwm = 200 MHz`, and the fastest post-divider `/2`, the formula `input_data_decimation_factor = 2 ** (r + 1)` produces one source sample per PWM frame. That is correct for the current configuration.

However, this correctness depends on the current MMCM ratio and minimum post-divider. If either changes, the sample rate and PWM frame rate will no longer match.

Risk:

Future frequency changes can silently break sample-to-frame pacing while the code still elaborates.

Recommended fix:

Derive the valid-mode decimation factor from `clk_freq_hz`, `clk_pwm_freq_hz`, `pwm_cycle_length`, and selected minimum post-divider, or add asserts documenting the required clock/post-divider relationship.

### P2: changing `pwm_resolution_bits` changes pulse duration in seconds

File: `src/main.vhd`

Relevant lines:

- `pwm_resolution_bits` default is `8`.
- `sine_pulse_period_cycles` default is `390`.
- `input_data_decimation_factor = 2 ** (pwm_resolution_bits + 1)`.

Issue:

Pulse duration is configured in source samples. Since source sample rate changes with `pwm_resolution_bits`, the same `sine_pulse_period_cycles` value produces a different pulse duration in seconds for different PWM resolutions.

Examples for current clocks and fastest post-divider:

- `r = 8`: source rate is `195312.5 Hz`, `390` samples is about `1.9968 ms`.
- `r = 5`: source rate is `1562500 Hz`, `390` samples is about `0.2496 ms`.
- To keep the same period as `r = 8`, `390` samples when building with `r = 5`, the pulse period should be about `3120` samples.

Risk:

When building a 5-bit PWM image, the pulse frame becomes eight times shorter unless the pulse generics are also changed.

Recommended fix:

Either document this as intended or derive pulse sample counts from desired time/frequency parameters.

### P2/P3: reset style is mixed in non-core `src`

Files:

- `src/signal_chain/sine_gen_signed.vhd`
- `src/signal_chain/sine_gen_unsigned.vhd`
- `src/signal_chain/data_decimator.vhd`

Issue:

These modules still use asynchronous reset style with `process(clk, reset)` or `process(clk, rst)`, while `pwm_core` has been moved to synchronous reset semantics. The top-level reset controller produces synchronous-looking reset signals, so this mixture is not necessarily broken, but it weakens the reset contract across the design.

Risk:

At higher clock rates, reset release timing becomes less uniform and harder to constrain/reason about.

Recommended fix:

Unify these modules to synchronous reset, or document that these reset inputs may be asynchronously asserted and must be safely released relative to `clk`.

### P3: 16-bit signal generation followed by MSB truncation is structurally correct, but signed rounding is absent

File: `src/main.vhd`

Relevant line:

```vhdl
source_sample <= source_sine_out(source_data_width - 1 downto source_data_width - pwm_resolution_bits);
```

Issue:

For a 5-bit PWM build, this selects bits `15 downto 11` from the 16-bit sine. That is a normal MSB truncation path and the FIFO then stores 5-bit samples, not 16-bit samples.

Risk:

For signed data this is truncation, not rounding. Also, the most negative 16-bit value can map to `10000` at `r = 5`, which is `-16`. Some local signed chunk logic in `pwm_mch_buf` uses `max_neg := -max_pos`, which is `-15` for `r = 5`. This can create a one-count asymmetry between generated samples and channel phase/reference chunk points.

Recommended fix:

If exact symmetry matters, review signed range handling in `get_chunk_end_signed` and consider using the full two's-complement minimum `-2 ** (r - 1)` where appropriate. If noise/linearity matters, consider rounding before truncation.

### P3: `edge_delay.vhd` appears unused and less guarded than the rest of the design

File: `src/utils/edge_delay.vhd`

Issue:

`edge_delay` is present in the source list but is not instantiated by the reviewed `src` design. It has no reset port and no generic assertions. If `d` is larger than the `r`-bit counter can represent, `to_unsigned(dead_cycles_cons, r)` truncates the delay value.

Risk:

This is likely stale utility code. If reused later, it can produce a wrong delay silently.

Recommended fix:

Remove it from active source lists if obsolete, or add asserts for `r` and `d` and document the intended reset/initialization behavior.

## Notes To Revisit

- Decide whether `pwm_mch_buf` should carry explicit frame markers through FIFO.
- Decide whether first sample should be preloaded before enabling PWM counters.
- Decide whether `VALID` input mode should be strict request/response handshake or permissive valid-stream input.
- Decide whether pulse durations should be specified in time/frequency units instead of source sample counts.
- Decide whether all non-core `src` modules should be migrated to synchronous reset to match `pwm_core`.
