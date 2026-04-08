# build_board1.tcl - Build for Board 1

set PART "xc7a100tcsg324-1"  ;# Your chip/part (same for all boards)
set BOARD "board1"
set XDC_FILE "../constraints/board1/board1.xdc"  ;# Path to board1 constraints

# Optional: Board-specific properties (e.g., if needed for unique optimizations)
set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true [get_runs synth_1]  ;# But in non-project mode, use synth_design args instead

# Run the shared flow
source common.tcl

# Any post-build steps unique to board1 (e.g., custom reports)
report_power -file ${BOARD}_power.rpt