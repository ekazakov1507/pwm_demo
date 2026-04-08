# common.tcl - Shared build flow

# Read design sources (shared across boards)
read_verilog [glob ../src/**/*.v ../src/**/*.sv]  ;# Recursive glob for all subdirectories
read_vhdl [glob ../src/**/*.vhd]  ;# Read all VHDL files recursively

# Read board-specific constraints
read_xdc $XDC_FILE

# Synthesis
synth_design -top top -part $PART -flatten_hierarchy rebuilt
write_checkpoint -force ${BOARD}_synth.dcp  ;# Optional: Save synth checkpoint for reuse/analysis

# Implementation
opt_design
place_design
phys_opt_design  ;# Optional physical optimization
route_design
write_checkpoint -force ${BOARD}_impl.dcp

# Generate outputs (bitstream, reports, etc.)
report_timing_summary -file ${BOARD}_timing_summary.rpt
report_utilization -file ${BOARD}_utilization.rpt
write_bitstream -force ${BOARD}.bit

# Optional: Generate programming file (e.g., MCS for flash)
write_cfgmem -format mcs -size 16 -interface SPIx4 -loadbit "up 0x0 ${BOARD}.bit" -force -file ${BOARD}.mcs