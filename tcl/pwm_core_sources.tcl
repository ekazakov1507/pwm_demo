set script_dir [file dirname [info script]]
set repo_root [file dirname $script_dir]

set pwm_core_vhdl_files [list \
  [file join $repo_root src utils range_divider_pkg.vhd] \
  [file join $repo_root src utils edge_delay.vhd] \
  [file join $repo_root src utils dead_time_generator.vhd] \
  [file join $repo_root src counters up_counter_unsigned.vhd] \
  [file join $repo_root src counters up_counter_signed.vhd] \
  [file join $repo_root src counters updown_counter_unsigned.vhd] \
  [file join $repo_root src counters updown_counter_signed.vhd] \
  [file join $repo_root src buffers async_fifo.vhd] \
  [file join $repo_root src signal_chain data_decimator.vhd] \
  [file join $repo_root src signal_chain scaler_unsigned.vhd] \
  [file join $repo_root src signal_chain scaler_signed.vhd] \
  [file join $repo_root src signal_chain sine_gen_simple.vhd] \
  [file join $repo_root src pwm pwm_1ch_drive_pkg.vhd] \
  [file join $repo_root src pwm pwm_1ch.vhd] \
  [file join $repo_root src pwm pwm_mch.vhd] \
  [file join $repo_root src pwm pwm_mch_buf.vhd] \
]
