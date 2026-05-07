if {[llength $argv] != 2} {
  error "Usage: xsct tcl/build_z7_lite_fsbl.tcl <hdf_file> <output_dir>"
}

set hdf_file [lindex $argv 0]
set output_dir [lindex $argv 1]

proc join_path {base args} {
  set path [string trimright $base "/\\"]
  foreach part $args {
    append path "/" [string trim $part "/\\"]
  }
  return $path
}

set fsbl_name z7_lite_fsbl
set fsbl_work_dir [join_path $output_dir hsi_fsbl]
set app_dir [join_path $fsbl_work_dir $fsbl_name]
set fsbl_out [join_path $output_dir ${fsbl_name}.elf]
set local_repo [join_path $fsbl_work_dir repo]

proc patch_xilinx_tcl_file {tcl_file} {
  set fh [open $tcl_file r]
  set data [read $fh]
  close $fh

  if {[file tail $tcl_file] eq "standalone.tcl"} {
    set helper {
proc z7_lite_list_dir_entries {dir} {
    set result [list]
    set win_dir [string map {/ \\} $dir]
    if {[catch {exec cmd.exe /c dir /b /a-d "$win_dir"} names]} {
        return $result
    }
    foreach name [split $names "\n"] {
        set name [string trim $name "\r "]
        if {$name ne ""} {
            lappend result "[string trimright $dir "/\\"]/$name"
        }
    }
    return $result
}

}
    set data "${helper}${data}"
    regsub -all {glob -nocomplain \[file join \$([A-Za-z0-9_]+) \*\]} $data {z7_lite_list_dir_entries $\1} data
  }

  set patched_lines [list]
  foreach line [split $data "\n"] {
    if {[regexp {^([ \t]*)file delete(.*)$} $line -> indent rest]} {
      lappend patched_lines "${indent}catch {file delete$rest}"
    } else {
      lappend patched_lines [string map {"glob -join" "glob -nocomplain -join"} $line]
    }
  }

  set fh [open $tcl_file w]
  puts -nonewline $fh [join $patched_lines "\n"]
  close $fh
}

proc copy_directory {source_dir target_dir} {
  file mkdir $target_dir
  foreach entry [glob -nocomplain -directory $source_dir *] {
    set target [join_path $target_dir [file tail $entry]]
    if {[file isdirectory $entry]} {
      copy_directory $entry $target
    } else {
      file copy -force $entry $target
    }
  }
}

if {![file exists $hdf_file]} {
  error "HDF not found: $hdf_file"
}

file mkdir $output_dir
catch {file delete -force $fsbl_work_dir}
file mkdir $fsbl_work_dir

if {![info exists ::env(XILINX_SDK)]} {
  error "XILINX_SDK is not set; run this script through Xilinx SDK/XSCT 2018.3."
}

set source_standalone [join_path $::env(XILINX_SDK) data embeddedsw lib bsp standalone_v6_8]
set source_xilffs [join_path $::env(XILINX_SDK) data embeddedsw lib sw_services xilffs_v4_0]
set source_xilrsa [join_path $::env(XILINX_SDK) data embeddedsw lib sw_services xilrsa_v1_5]
set local_bsp_root [join_path $local_repo lib bsp]
set local_sw_services_root [join_path $local_repo lib sw_services]
set local_standalone [join_path $local_bsp_root standalone_v6_8]
set local_xilffs [join_path $local_sw_services_root xilffs_v4_0]
set local_xilrsa [join_path $local_sw_services_root xilrsa_v1_5]
set local_standalone_tcl [join_path $local_standalone data standalone.tcl]
set local_xilffs_tcl [join_path $local_xilffs data xilffs.tcl]

if {![file exists $source_standalone]} {
  error "Standalone BSP source not found: $source_standalone"
}
if {![file exists $source_xilffs]} {
  error "XilFFS source not found: $source_xilffs"
}
if {![file exists $source_xilrsa]} {
  error "XilRSA source not found: $source_xilrsa"
}

file mkdir $local_bsp_root
file mkdir $local_sw_services_root
copy_directory $source_standalone $local_standalone
copy_directory $source_xilffs $local_xilffs
copy_directory $source_xilrsa $local_xilrsa
patch_xilinx_tcl_file $local_standalone_tcl
patch_xilinx_tcl_file $local_xilffs_tcl
::hsi::set_repo_path $local_repo

::hsi::open_hw_design $hdf_file

set processor_candidates [::hsi::get_cells -hierarchical -filter {IP_TYPE == PROCESSOR && IP_NAME == ps7_cortexa9}]
if {[llength $processor_candidates] == 0} {
  error "No Zynq-7000 Cortex-A9 processor found in $hdf_file"
}
set processor [lindex $processor_candidates 0]

::hsi::generate_app -app zynq_fsbl -proc $processor -os standalone -dir $app_dir -compile

set candidates [list \
  [join_path $app_dir executable.elf] \
  [join_path $app_dir fsbl.elf] \
  [join_path $app_dir zynq_fsbl.elf] \
  [join_path $app_dir ${fsbl_name}.elf] \
]

set fsbl_elf ""
foreach candidate $candidates {
  if {[file exists $candidate]} {
    set fsbl_elf $candidate
    break
  }
}

if {$fsbl_elf eq ""} {
  set generated_elves [glob -nocomplain -directory $app_dir *.elf]
  if {[llength $generated_elves] == 1} {
    set fsbl_elf [lindex $generated_elves 0]
  }
}

if {$fsbl_elf eq ""} {
  error "FSBL ELF was not generated in $app_dir"
}

file copy -force $fsbl_elf $fsbl_out
::hsi::close_hw_design [::hsi::current_hw_design]
puts "Wrote Z7-Lite FSBL: $fsbl_out"
