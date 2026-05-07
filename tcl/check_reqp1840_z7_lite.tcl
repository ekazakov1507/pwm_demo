set repo_root "C:/Users/user/VivadoProjects/2018-3/pwm_demo"
set output_dir [file join $repo_root build reqp1840_check]
set artifact_stem "z7lite_reqp1840_check"

file mkdir $output_dir

source [file join $repo_root tcl pwm_core_sources.tcl]
read_vhdl -vhdl2008 $pwm_core_vhdl_files
read_vhdl -vhdl2008 [list [file join $repo_root src main.vhd]]
read_xdc [list [file join $repo_root constraints Z7_LITE.xdc]]

set synth_rc [catch {synth_design -top main -part xc7z020clg400-1 -flatten_hierarchy rebuilt} synth_msg]
if {$synth_rc != 0} {
  puts "synth_design returned: $synth_msg"
}

if {[llength [get_cells -quiet]] == 0} {
  error "No synthesized design is available after synth_design."
}

write_checkpoint -force [file join $output_dir ${artifact_stem}_synth.dcp]
report_utilization -file [file join $output_dir ${artifact_stem}_synth_utilization.rpt]
report_drc -file [file join $output_dir ${artifact_stem}_synth_drc.rpt]

set impl_rc [catch {
  opt_design
  place_design
  phys_opt_design
  route_design
} impl_msg]
if {$impl_rc != 0} {
  puts "implementation returned: $impl_msg"
}

if {[llength [get_cells -quiet]] > 0} {
  write_checkpoint -force [file join $output_dir ${artifact_stem}_impl.dcp]
  report_timing_summary -file [file join $output_dir ${artifact_stem}_timing_summary.rpt]
  report_utilization -file [file join $output_dir ${artifact_stem}_utilization.rpt]
  report_drc -file [file join $output_dir ${artifact_stem}_drc.rpt]
}
