set script_dir [file dirname [info script]]
if {![file exists [file join $script_dir common.tcl]]} {
  set script_dir "C:/Users/user/VivadoProjects/2018-3/pwm_demo/tcl"
}
source [file join $script_dir common.tcl]

set part "xc7z010clg400-1"
set board_name "antminer-s9"
set xdc_file [file join $pwm_demo_repo_root constraints Antminer-S9.xdc]
set output_dir [pwm_demo_board_output_dir $pwm_demo_repo_root $board_name]

set config_name ""
set generic_overrides ""

if {[llength $argv] >= 1} {
  set config_name [lindex $argv 0]
}

if {[llength $argv] >= 2} {
  set generic_overrides [lindex $argv 1]
}

run_pwm_demo_build $part $xdc_file $board_name $config_name $generic_overrides $output_dir
