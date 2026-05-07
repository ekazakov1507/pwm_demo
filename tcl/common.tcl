proc find_pwm_demo_repo_root {script_path} {
  set candidates [list "C:/Users/user/VivadoProjects/2018-3/pwm_demo"]

  if {[file pathtype $script_path] eq "absolute"} {
    lappend candidates [file dirname [file dirname $script_path]]
  } else {
    lappend candidates [file dirname [file dirname [file join [pwd] $script_path]]]
  }

  if {![catch {exec cmd.exe /c cd} cmd_pwd]} {
    set cmd_pwd [string trim $cmd_pwd]
    if {$cmd_pwd ne ""} {
      lappend candidates [file dirname [file dirname [file join $cmd_pwd $script_path]]]
    }
  }

  foreach candidate $candidates {
    set candidate [string map {\\ /} $candidate]
    if {[file exists [file join $candidate src main.vhd]] &&
        [file exists [file join $candidate tcl common.tcl]]} {
      return $candidate
    }
  }

  error "Could not locate pwm_demo repo root from: $candidates"
}

set pwm_demo_repo_root [find_pwm_demo_repo_root [info script]]
set pwm_demo_tcl_dir [file join $pwm_demo_repo_root tcl]

proc read_pwm_demo_core_sources {repo_root} {
  uplevel #0 [list source [file join $repo_root tcl pwm_core_sources.tcl]]
  read_vhdl -vhdl2008 $::pwm_core_vhdl_files
}

proc sanitize_pwm_demo_token {value} {
  set token [string tolower $value]
  regsub -all {_} $token "-" token
  regsub -all {'} $token "" token
  regsub -all {[^a-z0-9]+} $token "-" token
  regsub -all {-+} $token "-" token
  return [string trim $token "-"]
}

proc get_pwm_demo_vhdl_value {source pattern default} {
  if {[regexp -nocase $pattern $source -> raw_value]} {
    set value [string trim $raw_value]
    return [string map {_ "" "\"" "" "'" ""} $value]
  }

  return $default
}

proc infer_pwm_demo_build_tag {repo_root generic_overrides} {
  set main_file [file join $repo_root src main.vhd]
  set main_handle [open $main_file r]
  set main_source [read $main_handle]
  close $main_handle

  set num_channels [get_pwm_demo_vhdl_value $main_source {num_channels\s*:\s*integer\s*:=\s*([0-9_]+)} 4]
  if {[regexp -nocase {num_channels\s*=\s*([0-9_]+)} $generic_overrides -> override_channels]} {
    set num_channels [string map {_ ""} $override_channels]
  }

  set data_width [get_pwm_demo_vhdl_value $main_source {constant\s+data_width\s*:\s*integer\s*:=\s*([0-9_]+)} 0]
  set dead_time [get_pwm_demo_vhdl_value $main_source {constant\s+num_dead_time_cycles\s*:\s*integer\s*:=\s*([0-9_]+)} 0]
  set buffer_depth [get_pwm_demo_vhdl_value $main_source {constant\s+buffer_depth\s*:\s*integer\s*:=\s*([0-9_]+)} 0]
  set wave_length [get_pwm_demo_vhdl_value $main_source {constant\s+wave_length\s*:\s*integer\s*:=\s*([0-9_]+)} 0]
  set input_data_type [sanitize_pwm_demo_token [get_pwm_demo_vhdl_value $main_source {constant\s+input_data_type\s*:\s*string\s*:=\s*"([^"]+)"} default]]
  set ref_type [sanitize_pwm_demo_token [get_pwm_demo_vhdl_value $main_source {constant\s+ref_type\s*:\s*string\s*:=\s*"([^"]+)"} default]]
  set ref_step [get_pwm_demo_vhdl_value $main_source {constant\s+ref_step\s*:\s*integer\s*:=\s*([0-9_]+)} 0]
  set ref_updwn [get_pwm_demo_vhdl_value $main_source {constant\s+ref_updwn\s*:\s*std_logic\s*:=\s*'([01])'} 0]

  set tag_parts [list \
    "nc${num_channels}" \
    "dw${data_width}" \
    "dt${dead_time}" \
    "buf${buffer_depth}" \
    "wl${wave_length}" \
    $input_data_type \
    $ref_type \
    "rs${ref_step}" \
    "ru${ref_updwn}" \
  ]

  return [join $tag_parts "_"]
}

proc run_pwm_demo_build {part xdc_file board_name {config_name ""} {generic_overrides ""} {output_dir ""}} {
  global pwm_demo_repo_root

  if {$output_dir eq ""} {
    set output_dir [file join $pwm_demo_repo_root bit]
  }

  file mkdir $output_dir

  if {$config_name eq ""} {
    set config_name [infer_pwm_demo_build_tag $pwm_demo_repo_root $generic_overrides]
  }

  set artifact_stem [sanitize_pwm_demo_token "${board_name}_${config_name}"]

  puts "Board: $board_name"
  puts "Config: $config_name"
  puts "Output directory: $output_dir"
  puts "Artifact stem: $artifact_stem"

  read_pwm_demo_core_sources $pwm_demo_repo_root
  read_vhdl -vhdl2008 [list [file join $pwm_demo_repo_root src main.vhd]]
  read_xdc [list $xdc_file]

  if {$generic_overrides eq ""} {
    synth_design -top main -part $part -flatten_hierarchy rebuilt
  } else {
    puts "Generic overrides: $generic_overrides"
    synth_design -top main -part $part -flatten_hierarchy rebuilt -generic $generic_overrides
  }

  write_checkpoint -force [file join $output_dir ${artifact_stem}_synth.dcp]

  opt_design
  place_design
  phys_opt_design
  route_design
  write_checkpoint -force [file join $output_dir ${artifact_stem}_impl.dcp]

  report_timing_summary -file [file join $output_dir ${artifact_stem}_timing_summary.rpt]
  report_utilization -file [file join $output_dir ${artifact_stem}_utilization.rpt]
  write_bitstream -force [file join $output_dir ${artifact_stem}.bit]
}
