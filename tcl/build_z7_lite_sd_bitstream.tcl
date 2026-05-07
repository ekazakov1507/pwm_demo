set script_dir [file dirname [info script]]
if {![file exists [file join $script_dir common.tcl]]} {
  set script_dir "C:/Users/user/VivadoProjects/2018-3/pwm_demo/tcl"
}
source [file join $script_dir common.tcl]
set repo_root $pwm_demo_repo_root

if {[llength $argv] != 1} {
  error "Usage: vivado -mode batch -source tcl/build_z7_lite_sd_bitstream.tcl -tclargs <output_dir>"
}

set output_dir [lindex $argv 0]
puts "Output directory: $output_dir"
set part "xc7z020clg400-1"
set board_name "z7-lite"
set xdc_file [file join $repo_root constraints Z7_LITE.xdc]
set config_name "sd-boot"
set generic_overrides ""

run_pwm_demo_build $part $xdc_file $board_name $config_name $generic_overrides $output_dir
