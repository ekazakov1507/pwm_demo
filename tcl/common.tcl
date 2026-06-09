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
  regsub -all -- {-+} $token "-" token
  return [string trim $token "-"]
}

proc get_pwm_demo_vhdl_value {source pattern default} {
  if {[regexp -nocase $pattern $source -> raw_value]} {
    set value [string trim $raw_value]
    return [string map {_ "" "\"" "" "'" ""} $value]
  }

  return $default
}

proc get_pwm_demo_generic_override {generic_overrides generic_name default} {
  set normalized $generic_overrides
  regsub -all {["']} $normalized {} normalized
  regsub -all {[{};,]} $normalized { } normalized
  set pattern [format {(^|[[:space:]])%s[[:space:]]*=[[:space:]]*([^[:space:]]+)} $generic_name]

  if {[regexp -nocase $pattern $normalized -> unused value]} {
    return [string trim $value]
  }

  return $default
}

proc pwm_demo_debug_enabled {generic_overrides} {
  set debug_value [string toupper [get_pwm_demo_generic_override $generic_overrides debug "NO_DEBUG"]]
  return [expr {$debug_value eq "DEBUG"}]
}

proc normalize_pwm_demo_generic_overrides {generic_overrides} {
  set generic_overrides [string trim $generic_overrides]
  if {$generic_overrides eq ""} {
    return ""
  }

  set normalized_items [list]
  foreach item [split $generic_overrides] {
    set token [string trim $item "{};,\"'"]
    if {$token eq ""} {
      continue
    }

    if {[string equal -nocase $token "debug"]} {
      lappend normalized_items "debug=DEBUG"
    } else {
      lappend normalized_items $token
    }
  }

  return [join $normalized_items " "]
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
  set debug_value [sanitize_pwm_demo_token [get_pwm_demo_generic_override $generic_overrides debug "NO_DEBUG"]]

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

  if {$debug_value eq "debug"} {
    lappend tag_parts $debug_value
  }

  return [join $tag_parts "_"]
}

proc ensure_pwm_demo_debug_ip_core {debug_ip_dir module_name ip_name config} {
  set xci_file [file join $debug_ip_dir $module_name ${module_name}.xci]

  if {[llength [get_ips -quiet $module_name]] == 0} {
    if {[file exists $xci_file]} {
      read_ip $xci_file
    } else {
      create_ip -name $ip_name -vendor xilinx.com -library ip -module_name $module_name -dir $debug_ip_dir
    }
  }

  set ip_core [get_ips $module_name]
  set_property -dict $config $ip_core

  set xci_objects [get_files -quiet $xci_file]
  if {[llength $xci_objects] == 0} {
    set xci_objects [get_files -quiet [file normalize $xci_file]]
  }
  if {[llength $xci_objects] == 0} {
    set xci_objects [get_files -quiet -of_objects $ip_core]
  }
  if {[llength $xci_objects] == 0} {
    error "Could not locate XCI for $module_name"
  }

  catch {set_property generate_synth_checkpoint true $xci_objects}
  generate_target all $xci_objects
  synth_ip -force $ip_core

  return [lindex $xci_objects 0]
}

proc ensure_pwm_demo_debug_ip {repo_root part} {
  set debug_ip_dir [file join $repo_root ip debug [sanitize_pwm_demo_token $part]]
  file mkdir $debug_ip_dir

  puts "Preparing PWM demo VIO/ILA debug IP in $debug_ip_dir"
  set_part $part

  set vio_xci [ensure_pwm_demo_debug_ip_core \
    $debug_ip_dir \
    vio_pwm_debug \
    vio \
    [list \
      CONFIG.C_NUM_PROBE_IN {0} \
      CONFIG.C_NUM_PROBE_OUT {2} \
      CONFIG.C_PROBE_OUT0_WIDTH {3} \
      CONFIG.C_PROBE_OUT1_WIDTH {3} \
    ]]

  set ila_xci [ensure_pwm_demo_debug_ip_core \
    $debug_ip_dir \
    ila_pwm_debug \
    ila \
    [list \
      CONFIG.C_NUM_OF_PROBES {4} \
      CONFIG.C_DATA_DEPTH {1024} \
      CONFIG.C_PROBE0_WIDTH {6} \
      CONFIG.C_PROBE1_WIDTH {6} \
      CONFIG.C_PROBE2_WIDTH {4} \
      CONFIG.C_PROBE3_WIDTH {4} \
    ]]

  return [list $vio_xci $ila_xci]
}

proc run_pwm_demo_build {part xdc_file board_name {config_name ""} {generic_overrides ""} {output_dir ""}} {
  global pwm_demo_repo_root

  set generic_overrides [normalize_pwm_demo_generic_overrides $generic_overrides]

  if {$output_dir eq ""} {
    set output_dir [file join $pwm_demo_repo_root bit]
  }

  file mkdir $output_dir

  if {$config_name eq ""} {
    set config_name [infer_pwm_demo_build_tag $pwm_demo_repo_root $generic_overrides]
  }

  set artifact_stem [sanitize_pwm_demo_token "${board_name}_${config_name}"]
  set debug_enabled [pwm_demo_debug_enabled $generic_overrides]

  puts "Board: $board_name"
  puts "Config: $config_name"
  puts "Output directory: $output_dir"
  puts "Artifact stem: $artifact_stem"
  puts "Debug IP: $debug_enabled"

  set_part $part

  read_pwm_demo_core_sources $pwm_demo_repo_root
  read_vhdl -vhdl2008 [list [file join $pwm_demo_repo_root src main.vhd]]
  read_xdc [list $xdc_file]

  if {$debug_enabled} {
    ensure_pwm_demo_debug_ip $pwm_demo_repo_root $part
  }

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
  if {$debug_enabled} {
    write_debug_probes -force [file join $output_dir ${artifact_stem}.ltx]
  }
  write_bitstream -force [file join $output_dir ${artifact_stem}.bit]
}
