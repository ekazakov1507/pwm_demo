set script_dir [file dirname [info script]]
set repo_root [file dirname $script_dir]

source [file join $repo_root src pwm_core tcl pwm_core_sources.tcl]

set pwm_demo_local_vhdl_files [list \
  [file join $repo_root src utils edge_delay.vhd] \
  [file join $repo_root src buffers async_fifo.vhd] \
  [file join $repo_root src signal_chain data_decimator.vhd] \
  [file join $repo_root src signal_chain sine_gen_simple.vhd] \
  [file join $repo_root src pwm pwm_mch_buf.vhd] \
]

set pwm_core_vhdl_files [concat $pwm_core_vhdl_files $pwm_demo_local_vhdl_files]
