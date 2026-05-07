if {[info exists ::pwm_demo_repo_root] &&
    [file exists [file join $::pwm_demo_repo_root src pwm_core rtl pwm pwm_mch.vhd]]} {
  set repo_root $::pwm_demo_repo_root
} else {
  set root_candidates [list \
    "C:/Users/user/VivadoProjects/2018-3/pwm_demo" \
    [file dirname [file dirname [info script]]] \
  ]

  set repo_root ""
  foreach candidate $root_candidates {
    set candidate [string map {\\ /} $candidate]
    if {[file exists [file join $candidate src pwm_core rtl pwm pwm_mch.vhd]]} {
      set repo_root $candidate
      break
    }
  }

  if {$repo_root eq ""} {
    error "Could not locate pwm_demo repo root for pwm_core_sources.tcl"
  }
}

set pwm_core_root [file join $repo_root src pwm_core]

set pwm_core_vhdl_files [list \
  [file join $pwm_core_root rtl fp23 fp23_pkg.vhd] \
  [file join $pwm_core_root rtl utils range_divider_pkg.vhd] \
  [file join $pwm_core_root rtl utils dead_time_generator.vhd] \
  [file join $pwm_core_root rtl counters up_counter_unsigned.vhd] \
  [file join $pwm_core_root rtl counters up_counter_signed.vhd] \
  [file join $pwm_core_root rtl counters updown_counter_unsigned.vhd] \
  [file join $pwm_core_root rtl counters updown_counter_signed.vhd] \
  [file join $pwm_core_root rtl signal_chain scaler_fp23.vhd] \
  [file join $pwm_core_root rtl signal_chain scaler_unsigned.vhd] \
  [file join $pwm_core_root rtl signal_chain scaler_signed.vhd] \
  [file join $pwm_core_root rtl pwm pwm_1ch_drive_pkg.vhd] \
  [file join $pwm_core_root rtl pwm pwm_1ch.vhd] \
  [file join $pwm_core_root rtl pwm pwm_mch.vhd] \
]

set pwm_demo_local_vhdl_files [list \
  [file join $repo_root src utils edge_delay.vhd] \
  [file join $repo_root src buffers async_fifo.vhd] \
  [file join $repo_root src signal_chain data_decimator.vhd] \
  [file join $repo_root src signal_chain sine_gen_simple.vhd] \
  [file join $repo_root src pwm pwm_mch_buf.vhd] \
]

set pwm_core_vhdl_files [concat $pwm_core_vhdl_files $pwm_demo_local_vhdl_files]
