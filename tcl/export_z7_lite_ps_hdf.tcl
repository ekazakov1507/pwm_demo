set script_dir [file dirname [info script]]

if {[llength $argv] != 1} {
  error "Usage: vivado -mode batch -source tcl/export_z7_lite_ps_hdf.tcl -tclargs <output_dir>"
}

set output_dir [lindex $argv 0]
puts "Output directory: $output_dir"
file mkdir $output_dir

set project_dir [file join $output_dir z7_lite_ps_handoff_project]
set hdf_file [file join $output_dir z7_lite_ps.hdf]

create_project -force z7_lite_ps_handoff $project_dir -part xc7z020clg400-1
set_property target_language VHDL [current_project]

create_bd_design z7_lite_ps
set ps7 [create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0]

# Start from Xilinx's generic Zynq-7020 PS setup, then override the
# Microphase Z7-Lite boot-critical peripherals used by this project.
set_property -dict [list \
  CONFIG.preset {ZedBoard} \
] $ps7

set_property -dict [list \
  CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 3.3V} \
  CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
  CONFIG.PCW_UIPARAM_DDR_ENABLE {1} \
  CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE {DDR 3} \
  CONFIG.PCW_UIPARAM_DDR_ECC {Disabled} \
  CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {16 Bit} \
  CONFIG.PCW_UIPARAM_DDR_BL {8} \
  CONFIG.PCW_UIPARAM_DDR_HIGH_TEMP {Normal (0-85)} \
  CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41J256M16 RE-125} \
  CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH {16 Bits} \
  CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY {4096 MBits} \
  CONFIG.PCW_UIPARAM_DDR_SPEED_BIN {DDR3_1066F} \
  CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {533.333313} \
  CONFIG.PCW_UIPARAM_DDR_ROW_ADDR_COUNT {15} \
  CONFIG.PCW_UIPARAM_DDR_COL_ADDR_COUNT {10} \
  CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} \
  CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} \
  CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} \
  CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {0} \
  CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
  CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
  CONFIG.PCW_SD0_GRP_CD_ENABLE {1} \
  CONFIG.PCW_SD0_GRP_CD_IO {MIO 47} \
  CONFIG.PCW_SD0_GRP_WP_ENABLE {0} \
  CONFIG.PCW_SD0_GRP_POW_ENABLE {0} \
  CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1} \
  CONFIG.PCW_UART0_UART0_IO {MIO 14 .. 15} \
  CONFIG.PCW_UART0_GRP_FULL_ENABLE {0} \
  CONFIG.PCW_UART0_BAUD_RATE {115200} \
  CONFIG.PCW_UART1_PERIPHERAL_ENABLE {0} \
  CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {50} \
  CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {50} \
  CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {0} \
  CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {0} \
  CONFIG.PCW_USB0_PERIPHERAL_ENABLE {0} \
  CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {0} \
  CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {0} \
  CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
  CONFIG.PCW_USE_M_AXI_GP0 {0} \
  CONFIG.PCW_USE_M_AXI_GP1 {0} \
  CONFIG.PCW_USE_S_AXI_GP0 {0} \
  CONFIG.PCW_USE_S_AXI_GP1 {0} \
  CONFIG.PCW_USE_S_AXI_ACP {0} \
  CONFIG.PCW_USE_S_AXI_HP0 {0} \
  CONFIG.PCW_USE_S_AXI_HP1 {0} \
  CONFIG.PCW_USE_S_AXI_HP2 {0} \
  CONFIG.PCW_USE_S_AXI_HP3 {0} \
  CONFIG.PCW_USE_FABRIC_INTERRUPT {0} \
  CONFIG.PCW_EN_CLK0_PORT {0} \
  CONFIG.PCW_EN_CLK1_PORT {0} \
  CONFIG.PCW_EN_CLK2_PORT {0} \
  CONFIG.PCW_EN_CLK3_PORT {0} \
] $ps7

make_bd_intf_pins_external [get_bd_intf_pins $ps7/DDR]
make_bd_intf_pins_external [get_bd_intf_pins $ps7/FIXED_IO]

validate_bd_design
save_bd_design

set bd_file [get_files z7_lite_ps.bd]
generate_target all $bd_file
set wrapper_file [make_wrapper -files $bd_file -top]
add_files -norecurse $wrapper_file
update_compile_order -fileset sources_1

write_hwdef -force -file $hdf_file
puts "Wrote Z7-Lite PS hardware handoff: $hdf_file"
