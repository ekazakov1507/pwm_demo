set script_dir [file dirname [info script]]
set part "xc7z010clg400-1"
set board_name "zybo-zynq"
set xdc_file [file join $script_dir .. constraints Zybo_board.xdc]
set output_dir [file normalize [file join $script_dir .. bit]]

set config_name ""
set generic_overrides ""

if {[llength $argv] >= 1} {
  set config_name [lindex $argv 0]
}

if {[llength $argv] >= 2} {
  set generic_overrides [lindex $argv 1]
}

source [file join $script_dir common.tcl]
run_pwm_demo_build $part $xdc_file $board_name $config_name $generic_overrides $output_dir
