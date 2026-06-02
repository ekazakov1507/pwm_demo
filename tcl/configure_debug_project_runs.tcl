set script_dir [file dirname [info script]]
if {![file exists [file join $script_dir common.tcl]]} {
  set script_dir "C:/Users/user/VivadoProjects/2018-3/pwm_demo/tcl"
}
source [file join $script_dir common.tcl]

proc set_pwm_demo_project_run_generic {run_name generic_value} {
  set run [get_runs -quiet $run_name]
  if {[llength $run] == 0} {
    puts "Skipping missing run: $run_name"
    return
  }

  set run_properties [list_property $run]
  if {[lsearch -exact $run_properties STEPS.SYNTH_DESIGN.ARGS.GENERIC] >= 0} {
    set_property STEPS.SYNTH_DESIGN.ARGS.GENERIC $generic_value $run
    return
  }

  foreach property_name [list STEPS.SYNTH_DESIGN.ARGS.MORE_OPTIONS {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS}] {
    if {[lsearch -exact $run_properties $property_name] >= 0} {
      set_property $property_name "-generic $generic_value" $run
      return
    }
  }

  error "Could not find a synth_design generic property on run $run_name"
}

set project_file [file join $pwm_demo_repo_root pwm_demo.xpr]
if {![file exists $project_file]} {
  error "Project file not found: $project_file"
}

open_project $project_file

set debug_ip_files [ensure_pwm_demo_debug_ip $pwm_demo_repo_root xc7z020clg400-1]
foreach ip_file $debug_ip_files {
  if {[llength [get_files -quiet $ip_file]] == 0} {
    add_files -norecurse -fileset sources_1 $ip_file
  }
}

set_pwm_demo_project_run_generic Z7-LITE {debug=DEBUG}
set_pwm_demo_project_run_generic ZYBO-ZYNQ {debug=DEBUG}

update_compile_order -fileset sources_1
save_project

puts "Configured local project synthesis runs for debug=DEBUG."
