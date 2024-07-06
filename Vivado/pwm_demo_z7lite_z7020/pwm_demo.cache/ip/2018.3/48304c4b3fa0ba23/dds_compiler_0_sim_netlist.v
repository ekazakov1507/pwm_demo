// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Fri Jun 28 21:02:47 2024
// Host        : DESKTOP-6SKDS4P running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ dds_compiler_0_sim_netlist.v
// Design      : dds_compiler_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z100ffg900-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "dds_compiler_0,dds_compiler_v6_0_17,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "dds_compiler_v6_0_17,Vivado 2018.3" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (aclk,
    m_axis_data_tvalid,
    m_axis_data_tdata,
    m_axis_phase_tvalid,
    m_axis_phase_tdata);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 aclk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME aclk_intf, ASSOCIATED_BUSIF M_AXIS_PHASE:S_AXIS_CONFIG:M_AXIS_DATA:S_AXIS_PHASE, ASSOCIATED_RESET aresetn, ASSOCIATED_CLKEN aclken, FREQ_HZ 100000000, PHASE 0.000, INSERT_VIP 0" *) input aclk;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_DATA TVALID" *) (* x_interface_parameter = "XIL_INTERFACENAME M_AXIS_DATA, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.000, LAYERED_METADATA undef, INSERT_VIP 0" *) output m_axis_data_tvalid;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_DATA TDATA" *) output [7:0]m_axis_data_tdata;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_PHASE TVALID" *) (* x_interface_parameter = "XIL_INTERFACENAME M_AXIS_PHASE, TDATA_NUM_BYTES 2, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.000, LAYERED_METADATA undef, INSERT_VIP 0" *) output m_axis_phase_tvalid;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_PHASE TDATA" *) output [15:0]m_axis_phase_tdata;

  wire aclk;
  wire [7:0]m_axis_data_tdata;
  wire m_axis_data_tvalid;
  wire [15:0]m_axis_phase_tdata;
  wire m_axis_phase_tvalid;
  wire NLW_U0_debug_axi_resync_in_UNCONNECTED;
  wire NLW_U0_debug_core_nd_UNCONNECTED;
  wire NLW_U0_debug_phase_nd_UNCONNECTED;
  wire NLW_U0_event_phase_in_invalid_UNCONNECTED;
  wire NLW_U0_event_pinc_invalid_UNCONNECTED;
  wire NLW_U0_event_poff_invalid_UNCONNECTED;
  wire NLW_U0_event_s_config_tlast_missing_UNCONNECTED;
  wire NLW_U0_event_s_config_tlast_unexpected_UNCONNECTED;
  wire NLW_U0_event_s_phase_chanid_incorrect_UNCONNECTED;
  wire NLW_U0_event_s_phase_tlast_missing_UNCONNECTED;
  wire NLW_U0_event_s_phase_tlast_unexpected_UNCONNECTED;
  wire NLW_U0_m_axis_data_tlast_UNCONNECTED;
  wire NLW_U0_m_axis_phase_tlast_UNCONNECTED;
  wire NLW_U0_s_axis_config_tready_UNCONNECTED;
  wire NLW_U0_s_axis_phase_tready_UNCONNECTED;
  wire [0:0]NLW_U0_debug_axi_chan_in_UNCONNECTED;
  wire [15:0]NLW_U0_debug_axi_pinc_in_UNCONNECTED;
  wire [15:0]NLW_U0_debug_axi_poff_in_UNCONNECTED;
  wire [15:0]NLW_U0_debug_phase_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_data_tuser_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_phase_tuser_UNCONNECTED;

  (* C_ACCUMULATOR_WIDTH = "16" *) 
  (* C_AMPLITUDE = "0" *) 
  (* C_CHANNELS = "1" *) 
  (* C_CHAN_WIDTH = "1" *) 
  (* C_DEBUG_INTERFACE = "0" *) 
  (* C_HAS_ACLKEN = "0" *) 
  (* C_HAS_ARESETN = "0" *) 
  (* C_HAS_M_DATA = "1" *) 
  (* C_HAS_M_PHASE = "1" *) 
  (* C_HAS_PHASEGEN = "1" *) 
  (* C_HAS_PHASE_OUT = "1" *) 
  (* C_HAS_SINCOS = "1" *) 
  (* C_HAS_S_CONFIG = "0" *) 
  (* C_HAS_S_PHASE = "0" *) 
  (* C_HAS_TLAST = "0" *) 
  (* C_HAS_TREADY = "0" *) 
  (* C_LATENCY = "3" *) 
  (* C_MEM_TYPE = "1" *) 
  (* C_MODE_OF_OPERATION = "0" *) 
  (* C_MODULUS = "9" *) 
  (* C_M_DATA_HAS_TUSER = "0" *) 
  (* C_M_DATA_TDATA_WIDTH = "8" *) 
  (* C_M_DATA_TUSER_WIDTH = "1" *) 
  (* C_M_PHASE_HAS_TUSER = "0" *) 
  (* C_M_PHASE_TDATA_WIDTH = "16" *) 
  (* C_M_PHASE_TUSER_WIDTH = "1" *) 
  (* C_NEGATIVE_COSINE = "0" *) 
  (* C_NEGATIVE_SINE = "0" *) 
  (* C_NOISE_SHAPING = "0" *) 
  (* C_OPTIMISE_GOAL = "0" *) 
  (* C_OUTPUTS_REQUIRED = "0" *) 
  (* C_OUTPUT_FORM = "0" *) 
  (* C_OUTPUT_WIDTH = "8" *) 
  (* C_PHASE_ANGLE_WIDTH = "8" *) 
  (* C_PHASE_INCREMENT = "2" *) 
  (* C_PHASE_INCREMENT_VALUE = "001000010,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0" *) 
  (* C_PHASE_OFFSET = "0" *) 
  (* C_PHASE_OFFSET_VALUE = "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0" *) 
  (* C_POR_MODE = "0" *) 
  (* C_RESYNC = "0" *) 
  (* C_S_CONFIG_SYNC_MODE = "0" *) 
  (* C_S_CONFIG_TDATA_WIDTH = "1" *) 
  (* C_S_PHASE_HAS_TUSER = "0" *) 
  (* C_S_PHASE_TDATA_WIDTH = "1" *) 
  (* C_S_PHASE_TUSER_WIDTH = "1" *) 
  (* C_USE_DSP48 = "0" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_dds_compiler_v6_0_17 U0
       (.aclk(aclk),
        .aclken(1'b1),
        .aresetn(1'b1),
        .debug_axi_chan_in(NLW_U0_debug_axi_chan_in_UNCONNECTED[0]),
        .debug_axi_pinc_in(NLW_U0_debug_axi_pinc_in_UNCONNECTED[15:0]),
        .debug_axi_poff_in(NLW_U0_debug_axi_poff_in_UNCONNECTED[15:0]),
        .debug_axi_resync_in(NLW_U0_debug_axi_resync_in_UNCONNECTED),
        .debug_core_nd(NLW_U0_debug_core_nd_UNCONNECTED),
        .debug_phase(NLW_U0_debug_phase_UNCONNECTED[15:0]),
        .debug_phase_nd(NLW_U0_debug_phase_nd_UNCONNECTED),
        .event_phase_in_invalid(NLW_U0_event_phase_in_invalid_UNCONNECTED),
        .event_pinc_invalid(NLW_U0_event_pinc_invalid_UNCONNECTED),
        .event_poff_invalid(NLW_U0_event_poff_invalid_UNCONNECTED),
        .event_s_config_tlast_missing(NLW_U0_event_s_config_tlast_missing_UNCONNECTED),
        .event_s_config_tlast_unexpected(NLW_U0_event_s_config_tlast_unexpected_UNCONNECTED),
        .event_s_phase_chanid_incorrect(NLW_U0_event_s_phase_chanid_incorrect_UNCONNECTED),
        .event_s_phase_tlast_missing(NLW_U0_event_s_phase_tlast_missing_UNCONNECTED),
        .event_s_phase_tlast_unexpected(NLW_U0_event_s_phase_tlast_unexpected_UNCONNECTED),
        .m_axis_data_tdata(m_axis_data_tdata),
        .m_axis_data_tlast(NLW_U0_m_axis_data_tlast_UNCONNECTED),
        .m_axis_data_tready(1'b0),
        .m_axis_data_tuser(NLW_U0_m_axis_data_tuser_UNCONNECTED[0]),
        .m_axis_data_tvalid(m_axis_data_tvalid),
        .m_axis_phase_tdata(m_axis_phase_tdata),
        .m_axis_phase_tlast(NLW_U0_m_axis_phase_tlast_UNCONNECTED),
        .m_axis_phase_tready(1'b0),
        .m_axis_phase_tuser(NLW_U0_m_axis_phase_tuser_UNCONNECTED[0]),
        .m_axis_phase_tvalid(m_axis_phase_tvalid),
        .s_axis_config_tdata(1'b0),
        .s_axis_config_tlast(1'b0),
        .s_axis_config_tready(NLW_U0_s_axis_config_tready_UNCONNECTED),
        .s_axis_config_tvalid(1'b0),
        .s_axis_phase_tdata(1'b0),
        .s_axis_phase_tlast(1'b0),
        .s_axis_phase_tready(NLW_U0_s_axis_phase_tready_UNCONNECTED),
        .s_axis_phase_tuser(1'b0),
        .s_axis_phase_tvalid(1'b0));
endmodule

(* C_ACCUMULATOR_WIDTH = "16" *) (* C_AMPLITUDE = "0" *) (* C_CHANNELS = "1" *) 
(* C_CHAN_WIDTH = "1" *) (* C_DEBUG_INTERFACE = "0" *) (* C_HAS_ACLKEN = "0" *) 
(* C_HAS_ARESETN = "0" *) (* C_HAS_M_DATA = "1" *) (* C_HAS_M_PHASE = "1" *) 
(* C_HAS_PHASEGEN = "1" *) (* C_HAS_PHASE_OUT = "1" *) (* C_HAS_SINCOS = "1" *) 
(* C_HAS_S_CONFIG = "0" *) (* C_HAS_S_PHASE = "0" *) (* C_HAS_TLAST = "0" *) 
(* C_HAS_TREADY = "0" *) (* C_LATENCY = "3" *) (* C_MEM_TYPE = "1" *) 
(* C_MODE_OF_OPERATION = "0" *) (* C_MODULUS = "9" *) (* C_M_DATA_HAS_TUSER = "0" *) 
(* C_M_DATA_TDATA_WIDTH = "8" *) (* C_M_DATA_TUSER_WIDTH = "1" *) (* C_M_PHASE_HAS_TUSER = "0" *) 
(* C_M_PHASE_TDATA_WIDTH = "16" *) (* C_M_PHASE_TUSER_WIDTH = "1" *) (* C_NEGATIVE_COSINE = "0" *) 
(* C_NEGATIVE_SINE = "0" *) (* C_NOISE_SHAPING = "0" *) (* C_OPTIMISE_GOAL = "0" *) 
(* C_OUTPUTS_REQUIRED = "0" *) (* C_OUTPUT_FORM = "0" *) (* C_OUTPUT_WIDTH = "8" *) 
(* C_PHASE_ANGLE_WIDTH = "8" *) (* C_PHASE_INCREMENT = "2" *) (* C_PHASE_INCREMENT_VALUE = "001000010,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0" *) 
(* C_PHASE_OFFSET = "0" *) (* C_PHASE_OFFSET_VALUE = "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0" *) (* C_POR_MODE = "0" *) 
(* C_RESYNC = "0" *) (* C_S_CONFIG_SYNC_MODE = "0" *) (* C_S_CONFIG_TDATA_WIDTH = "1" *) 
(* C_S_PHASE_HAS_TUSER = "0" *) (* C_S_PHASE_TDATA_WIDTH = "1" *) (* C_S_PHASE_TUSER_WIDTH = "1" *) 
(* C_USE_DSP48 = "0" *) (* C_XDEVICEFAMILY = "zynq" *) (* downgradeipidentifiedwarnings = "yes" *) 
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_dds_compiler_v6_0_17
   (aclk,
    aclken,
    aresetn,
    s_axis_phase_tvalid,
    s_axis_phase_tready,
    s_axis_phase_tdata,
    s_axis_phase_tlast,
    s_axis_phase_tuser,
    s_axis_config_tvalid,
    s_axis_config_tready,
    s_axis_config_tdata,
    s_axis_config_tlast,
    m_axis_data_tvalid,
    m_axis_data_tready,
    m_axis_data_tdata,
    m_axis_data_tlast,
    m_axis_data_tuser,
    m_axis_phase_tvalid,
    m_axis_phase_tready,
    m_axis_phase_tdata,
    m_axis_phase_tlast,
    m_axis_phase_tuser,
    event_pinc_invalid,
    event_poff_invalid,
    event_phase_in_invalid,
    event_s_phase_tlast_missing,
    event_s_phase_tlast_unexpected,
    event_s_phase_chanid_incorrect,
    event_s_config_tlast_missing,
    event_s_config_tlast_unexpected,
    debug_axi_pinc_in,
    debug_axi_poff_in,
    debug_axi_resync_in,
    debug_axi_chan_in,
    debug_core_nd,
    debug_phase,
    debug_phase_nd);
  input aclk;
  input aclken;
  input aresetn;
  input s_axis_phase_tvalid;
  output s_axis_phase_tready;
  input [0:0]s_axis_phase_tdata;
  input s_axis_phase_tlast;
  input [0:0]s_axis_phase_tuser;
  input s_axis_config_tvalid;
  output s_axis_config_tready;
  input [0:0]s_axis_config_tdata;
  input s_axis_config_tlast;
  output m_axis_data_tvalid;
  input m_axis_data_tready;
  output [7:0]m_axis_data_tdata;
  output m_axis_data_tlast;
  output [0:0]m_axis_data_tuser;
  output m_axis_phase_tvalid;
  input m_axis_phase_tready;
  output [15:0]m_axis_phase_tdata;
  output m_axis_phase_tlast;
  output [0:0]m_axis_phase_tuser;
  output event_pinc_invalid;
  output event_poff_invalid;
  output event_phase_in_invalid;
  output event_s_phase_tlast_missing;
  output event_s_phase_tlast_unexpected;
  output event_s_phase_chanid_incorrect;
  output event_s_config_tlast_missing;
  output event_s_config_tlast_unexpected;
  output [15:0]debug_axi_pinc_in;
  output [15:0]debug_axi_poff_in;
  output debug_axi_resync_in;
  output [0:0]debug_axi_chan_in;
  output debug_core_nd;
  output [15:0]debug_phase;
  output debug_phase_nd;

  wire \<const0> ;
  wire \<const1> ;
  wire aclk;
  wire [7:0]m_axis_data_tdata;
  wire [15:0]m_axis_phase_tdata;
  wire m_axis_phase_tvalid;
  wire NLW_i_synth_debug_axi_resync_in_UNCONNECTED;
  wire NLW_i_synth_debug_core_nd_UNCONNECTED;
  wire NLW_i_synth_debug_phase_nd_UNCONNECTED;
  wire NLW_i_synth_event_phase_in_invalid_UNCONNECTED;
  wire NLW_i_synth_event_pinc_invalid_UNCONNECTED;
  wire NLW_i_synth_event_poff_invalid_UNCONNECTED;
  wire NLW_i_synth_event_s_config_tlast_missing_UNCONNECTED;
  wire NLW_i_synth_event_s_config_tlast_unexpected_UNCONNECTED;
  wire NLW_i_synth_event_s_phase_chanid_incorrect_UNCONNECTED;
  wire NLW_i_synth_event_s_phase_tlast_missing_UNCONNECTED;
  wire NLW_i_synth_event_s_phase_tlast_unexpected_UNCONNECTED;
  wire NLW_i_synth_m_axis_data_tlast_UNCONNECTED;
  wire NLW_i_synth_m_axis_phase_tlast_UNCONNECTED;
  wire NLW_i_synth_m_axis_phase_tvalid_UNCONNECTED;
  wire NLW_i_synth_s_axis_config_tready_UNCONNECTED;
  wire NLW_i_synth_s_axis_phase_tready_UNCONNECTED;
  wire [0:0]NLW_i_synth_debug_axi_chan_in_UNCONNECTED;
  wire [15:0]NLW_i_synth_debug_axi_pinc_in_UNCONNECTED;
  wire [15:0]NLW_i_synth_debug_axi_poff_in_UNCONNECTED;
  wire [15:0]NLW_i_synth_debug_phase_UNCONNECTED;
  wire [0:0]NLW_i_synth_m_axis_data_tuser_UNCONNECTED;
  wire [0:0]NLW_i_synth_m_axis_phase_tuser_UNCONNECTED;

  assign debug_axi_chan_in[0] = \<const0> ;
  assign debug_axi_pinc_in[15] = \<const0> ;
  assign debug_axi_pinc_in[14] = \<const0> ;
  assign debug_axi_pinc_in[13] = \<const0> ;
  assign debug_axi_pinc_in[12] = \<const0> ;
  assign debug_axi_pinc_in[11] = \<const0> ;
  assign debug_axi_pinc_in[10] = \<const0> ;
  assign debug_axi_pinc_in[9] = \<const0> ;
  assign debug_axi_pinc_in[8] = \<const0> ;
  assign debug_axi_pinc_in[7] = \<const0> ;
  assign debug_axi_pinc_in[6] = \<const0> ;
  assign debug_axi_pinc_in[5] = \<const0> ;
  assign debug_axi_pinc_in[4] = \<const0> ;
  assign debug_axi_pinc_in[3] = \<const0> ;
  assign debug_axi_pinc_in[2] = \<const0> ;
  assign debug_axi_pinc_in[1] = \<const0> ;
  assign debug_axi_pinc_in[0] = \<const0> ;
  assign debug_axi_poff_in[15] = \<const0> ;
  assign debug_axi_poff_in[14] = \<const0> ;
  assign debug_axi_poff_in[13] = \<const0> ;
  assign debug_axi_poff_in[12] = \<const0> ;
  assign debug_axi_poff_in[11] = \<const0> ;
  assign debug_axi_poff_in[10] = \<const0> ;
  assign debug_axi_poff_in[9] = \<const0> ;
  assign debug_axi_poff_in[8] = \<const0> ;
  assign debug_axi_poff_in[7] = \<const0> ;
  assign debug_axi_poff_in[6] = \<const0> ;
  assign debug_axi_poff_in[5] = \<const0> ;
  assign debug_axi_poff_in[4] = \<const0> ;
  assign debug_axi_poff_in[3] = \<const0> ;
  assign debug_axi_poff_in[2] = \<const0> ;
  assign debug_axi_poff_in[1] = \<const0> ;
  assign debug_axi_poff_in[0] = \<const0> ;
  assign debug_axi_resync_in = \<const0> ;
  assign debug_core_nd = \<const0> ;
  assign debug_phase[15] = \<const0> ;
  assign debug_phase[14] = \<const0> ;
  assign debug_phase[13] = \<const0> ;
  assign debug_phase[12] = \<const0> ;
  assign debug_phase[11] = \<const0> ;
  assign debug_phase[10] = \<const0> ;
  assign debug_phase[9] = \<const0> ;
  assign debug_phase[8] = \<const0> ;
  assign debug_phase[7] = \<const0> ;
  assign debug_phase[6] = \<const0> ;
  assign debug_phase[5] = \<const0> ;
  assign debug_phase[4] = \<const0> ;
  assign debug_phase[3] = \<const0> ;
  assign debug_phase[2] = \<const0> ;
  assign debug_phase[1] = \<const0> ;
  assign debug_phase[0] = \<const0> ;
  assign debug_phase_nd = \<const0> ;
  assign event_phase_in_invalid = \<const0> ;
  assign event_pinc_invalid = \<const0> ;
  assign event_poff_invalid = \<const0> ;
  assign event_s_config_tlast_missing = \<const0> ;
  assign event_s_config_tlast_unexpected = \<const0> ;
  assign event_s_phase_chanid_incorrect = \<const0> ;
  assign event_s_phase_tlast_missing = \<const0> ;
  assign event_s_phase_tlast_unexpected = \<const0> ;
  assign m_axis_data_tlast = \<const0> ;
  assign m_axis_data_tuser[0] = \<const0> ;
  assign m_axis_data_tvalid = m_axis_phase_tvalid;
  assign m_axis_phase_tlast = \<const0> ;
  assign m_axis_phase_tuser[0] = \<const0> ;
  assign s_axis_config_tready = \<const1> ;
  assign s_axis_phase_tready = \<const0> ;
  GND GND
       (.G(\<const0> ));
  VCC VCC
       (.P(\<const1> ));
  (* C_ACCUMULATOR_WIDTH = "16" *) 
  (* C_AMPLITUDE = "0" *) 
  (* C_CHANNELS = "1" *) 
  (* C_CHAN_WIDTH = "1" *) 
  (* C_DEBUG_INTERFACE = "0" *) 
  (* C_HAS_ACLKEN = "0" *) 
  (* C_HAS_ARESETN = "0" *) 
  (* C_HAS_M_DATA = "1" *) 
  (* C_HAS_M_PHASE = "1" *) 
  (* C_HAS_PHASEGEN = "1" *) 
  (* C_HAS_PHASE_OUT = "1" *) 
  (* C_HAS_SINCOS = "1" *) 
  (* C_HAS_S_CONFIG = "0" *) 
  (* C_HAS_S_PHASE = "0" *) 
  (* C_HAS_TLAST = "0" *) 
  (* C_HAS_TREADY = "0" *) 
  (* C_LATENCY = "3" *) 
  (* C_MEM_TYPE = "1" *) 
  (* C_MODE_OF_OPERATION = "0" *) 
  (* C_MODULUS = "9" *) 
  (* C_M_DATA_HAS_TUSER = "0" *) 
  (* C_M_DATA_TDATA_WIDTH = "8" *) 
  (* C_M_DATA_TUSER_WIDTH = "1" *) 
  (* C_M_PHASE_HAS_TUSER = "0" *) 
  (* C_M_PHASE_TDATA_WIDTH = "16" *) 
  (* C_M_PHASE_TUSER_WIDTH = "1" *) 
  (* C_NEGATIVE_COSINE = "0" *) 
  (* C_NEGATIVE_SINE = "0" *) 
  (* C_NOISE_SHAPING = "0" *) 
  (* C_OPTIMISE_GOAL = "0" *) 
  (* C_OUTPUTS_REQUIRED = "0" *) 
  (* C_OUTPUT_FORM = "0" *) 
  (* C_OUTPUT_WIDTH = "8" *) 
  (* C_PHASE_ANGLE_WIDTH = "8" *) 
  (* C_PHASE_INCREMENT = "2" *) 
  (* C_PHASE_INCREMENT_VALUE = "001000010,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0" *) 
  (* C_PHASE_OFFSET = "0" *) 
  (* C_PHASE_OFFSET_VALUE = "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0" *) 
  (* C_POR_MODE = "0" *) 
  (* C_RESYNC = "0" *) 
  (* C_S_CONFIG_SYNC_MODE = "0" *) 
  (* C_S_CONFIG_TDATA_WIDTH = "1" *) 
  (* C_S_PHASE_HAS_TUSER = "0" *) 
  (* C_S_PHASE_TDATA_WIDTH = "1" *) 
  (* C_S_PHASE_TUSER_WIDTH = "1" *) 
  (* C_USE_DSP48 = "0" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_dds_compiler_v6_0_17_viv i_synth
       (.aclk(aclk),
        .aclken(1'b0),
        .aresetn(1'b0),
        .debug_axi_chan_in(NLW_i_synth_debug_axi_chan_in_UNCONNECTED[0]),
        .debug_axi_pinc_in(NLW_i_synth_debug_axi_pinc_in_UNCONNECTED[15:0]),
        .debug_axi_poff_in(NLW_i_synth_debug_axi_poff_in_UNCONNECTED[15:0]),
        .debug_axi_resync_in(NLW_i_synth_debug_axi_resync_in_UNCONNECTED),
        .debug_core_nd(NLW_i_synth_debug_core_nd_UNCONNECTED),
        .debug_phase(NLW_i_synth_debug_phase_UNCONNECTED[15:0]),
        .debug_phase_nd(NLW_i_synth_debug_phase_nd_UNCONNECTED),
        .event_phase_in_invalid(NLW_i_synth_event_phase_in_invalid_UNCONNECTED),
        .event_pinc_invalid(NLW_i_synth_event_pinc_invalid_UNCONNECTED),
        .event_poff_invalid(NLW_i_synth_event_poff_invalid_UNCONNECTED),
        .event_s_config_tlast_missing(NLW_i_synth_event_s_config_tlast_missing_UNCONNECTED),
        .event_s_config_tlast_unexpected(NLW_i_synth_event_s_config_tlast_unexpected_UNCONNECTED),
        .event_s_phase_chanid_incorrect(NLW_i_synth_event_s_phase_chanid_incorrect_UNCONNECTED),
        .event_s_phase_tlast_missing(NLW_i_synth_event_s_phase_tlast_missing_UNCONNECTED),
        .event_s_phase_tlast_unexpected(NLW_i_synth_event_s_phase_tlast_unexpected_UNCONNECTED),
        .m_axis_data_tdata(m_axis_data_tdata),
        .m_axis_data_tlast(NLW_i_synth_m_axis_data_tlast_UNCONNECTED),
        .m_axis_data_tready(1'b0),
        .m_axis_data_tuser(NLW_i_synth_m_axis_data_tuser_UNCONNECTED[0]),
        .m_axis_data_tvalid(m_axis_phase_tvalid),
        .m_axis_phase_tdata(m_axis_phase_tdata),
        .m_axis_phase_tlast(NLW_i_synth_m_axis_phase_tlast_UNCONNECTED),
        .m_axis_phase_tready(1'b0),
        .m_axis_phase_tuser(NLW_i_synth_m_axis_phase_tuser_UNCONNECTED[0]),
        .m_axis_phase_tvalid(NLW_i_synth_m_axis_phase_tvalid_UNCONNECTED),
        .s_axis_config_tdata(1'b0),
        .s_axis_config_tlast(1'b0),
        .s_axis_config_tready(NLW_i_synth_s_axis_config_tready_UNCONNECTED),
        .s_axis_config_tvalid(1'b0),
        .s_axis_phase_tdata(1'b0),
        .s_axis_phase_tlast(1'b0),
        .s_axis_phase_tready(NLW_i_synth_s_axis_phase_tready_UNCONNECTED),
        .s_axis_phase_tuser(1'b0),
        .s_axis_phase_tvalid(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2015"
`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="cds_rsa_key", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=64)
`pragma protect key_block
gl8oTb3yK39LjDQS0B4PYP+vte8cGiBpEmJ9JLxCkI04rBQJe5sCt4dvUGvg1Ga0GoPkN0BTvh6i
v1YMWuZiJg==

`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
LV5tnIhV6fXU4gAQOLXCxdxya9doivJt+Y+5yV24zJ1I56Mu4gOTYyKzdDBlwz49as5fPNOvHvtM
FEjflUU6R2Yh76tXBr2An7Tc7qdcv/WUX57JWpXSPQfxdtsoJzfNEA5lf9cFyHWa+eE27NH4fCIB
fHvZTqNYCqZpO8hMEWo=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
CtefK+dE5tJYyIkOlXrI1GU3HbXkaFgSREpPJj1NZdNualyVqOHiPJK5xJ71xxO6zkXYtBYfzkxn
9Eqf7SpqFizTSC3YZVNAp0ix3wloJ2xu9/08YGAzwYtrD72s/REOd9GdOS5BW5KfXcLDWxJnWFK3
mjj+cPJfHeoGuNLu6gH6HD/lNP6geaOelYYVD/TVk4P/j6qWfCikFKKuomVo3jbRD7F7QdkJDCeh
d5Xc8VxEXSaKIjFRuMTWZtjAQjFH5UpSMVhxV/fXhvzSM6V5P4QZA+memX692B8GYsTFU76iMlss
d7ocDlaRWbY0BTXFb2HZNfGcl+sqYKs8PYn/UA==

`pragma protect key_keyowner="ATRENTA", key_keyname="ATR-SG-2015-RSA-3", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
UTuJ2/FiXz7w8k47LqoJjpB8chaAWEBjYpgn4jj1PBd2l6Nj6avA0We0iYNi5AJkwcUofxaNsFtE
+sVWsmGPk/0vN5Q90wbwbfGu18ni9SqWiSNRSUzzfB9h0bol599BuMG2pbcdYlanUIn9oPi4ZKeJ
2M667aoQ2BTcU/o1U8nn5wuoiboeNIqzcJS0jj+j6J5UYz5aHgwMcFlCGUwSQuAp+2VIulW4T1IV
NW+4iXCF7wife+1/XS6RYcYu+n4km8U2A8z/nLIuNXSO1T2HaR6rR3YxTorPEFUQnfrre1FxRLzT
6pi4dXPFPyG1bXISdn2AleLyNN3VFQjTEgHwsA==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2017_05", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
FMUkchj5p9XvgJ9tR5grSuP9aw5xa30l1YgNWO9WvtYYjYtQnsPBns5ryDL+PXPqQYQ3i0NvbEVZ
mN4H44H269BdOgH+vRRI3SR79goz8NqADp1QSv06wD02bUASlMq9aM6Phdxmqoalzn7A7dWDa+nU
2QokmpYQQylaKE1ZbXrz6loBY1IeoaMxbsQcvxJcI2aG1HO9NfyR9d5i3K9UmO1t9jFA+8k+GsKj
kNnLxX6I0J9fN8wKc7D007S9DgoQs6+WuCL6CudeG25OH6Gy/uLkY2Udzdpodegx89FgRLo92dDh
+0eWKh3H5TN2vtQ9mtD1iH6zm1l1IqnYy2G06A==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
IjA88m1asiYMyCqMLSP/pVhA6mm9v8t5bFtEAMOvlQO8WTy5Vpca8kFPPuhuf6voqy+zwcLXRU9a
5UwLvCxgOEOo68GA3l4AR9WaPmcxPTPUwChO8zkHIDrS0eoDFMY1OTr1Lv8pbJknphtPExopREwk
KuHbtq4Mg3zw+se7q5E=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
nZ0uDa4zhbQfoZoNpOAKrHOsOrOlSYjg5j1zWlifZ7mksZmmo1GUwbu4BrFKsE9nPAJUOa85AaS6
3sPqXGDLUL68TzDI06mN0/idhoIRBSJNinUfJpw4Ro9h/zNx1E//RfaHklSArW0rHrP6JnabQq/E
ywpKofyKtfWBjZrTJqD+xFD3BsXO9W35e9lAY/pTqzN6C7dC2o6xELYMw7a37e+7TEDqEPb1kk1i
VC/DX7v1veomIkT4wlTej+pa1pSQH6uN/huOhLuz4yEz/zZdnoDInKQyuWaZgdQV+2dfYBgbf+po
404pK0Ii/DBBTh6IKooZGzVmsyG/5MKNX6F9vw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
NSIhe8jaC+NZ8YAnJDsFwkPiuhy9Dr5nha57aHhcc5pEKxN3Nyrc1UgLCVXRjSApYI5EQp4zxq/U
Mxn15Od6+d4ZfRMawYfXunwd+7uoCGVKcoMA1D7nGpSggP1ZZMH9jKZeHU68q8iPeBu9vkMu1cMm
7N8WVrtJ+AR4lpJ6hHLZsUxIKt1+BP3SyAYDUPtvEIIflpbWNDl5Dl/ziP0+pIggZ5lxCZbfmyyQ
IuZV3W4dW8WKqKi/0OJYs0CiMv6tLZ1BNW4ogmX35jMZzAaBBMiqzsQ0qMcKmujU4VEdzhjiNnTN
r4b/fe2zQkK0PVioZihOPNbtsGmKHZEpVnZYhQ==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
5WWZW4Fr+8wIyzqUhre1o2uT6lpRgpC/IgYvyO6cD/ZU8WYMvLF2CF0KPraxj379fSH+u8Iayx++
A6DbbdwZbTAasYeBJ0juGgZImCDFRFreEZ99H6O61YgI3x0r+iHcOSLiCx+eT+Cp9tT2ypuSd7cN
xZ08QYqiTzfuJujmlRXv7PEAy/Y6x/05IwPxyRT5YiULaNqsIZVE9QHJVtbCvdNu94To94E/Q9im
uzfDS+sH7npyhbeL9PFgJ/T4xUSJctvRTYfbV34iLVfLG1I5DZz8hvnzbsaTN2gNwjn24WSxv7Gj
1f4psQBV7karKzRvSXamThf99KG1nrf7Cz+QBw==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 33664)
`pragma protect data_block
LS2kgdEeIkNNNlKbDOPQ7CU0aAhcHFOscWPdD2d7jGVnRqVosvPOd+aUGG15uQiGWfY7/+podr6q
X3Mqa+tNww+vQIlX0C3PhnhiJkbXH591POZldj3907bjq2OoHBDHS+WJ9Qb1W5ZDOi7B+UYguItV
ORGPsljsOoEW03mexIHikEgnQiDMpBfo24UB7s3sKG+XDek5DqjuyQdJJyPrnlApHJvIvr74gOqy
8GRMEJNv4rTZKx1rRFgs2RAhRNOVBWL3v/ld5VysCU0twHaOByDOgQK4n90ErAQEEdHO5fPoTdvN
OHEJPadzz2kn5BjQWSlzCaijuzFQv3GClZSYyu10AR2dVvOIh9yCafhA8iSTIvhlN0p8YFs9o8yS
PDGT/8guEN/3t6H1c7VZjSJ8Q/ifj3HOMKmaPysNj3g2RMmhBf5E2UNUJ7msQ0n4F02+IlccFbJ6
XhlR/uyTUXhQRbfZjJBis+orGKuJ5vhITKUBYOUYoR1aMlnZn+T3AFOZm3ZqJih09PJo+V1R88Ur
KGnpXa5r3UQ3g8PcpM2qlKz1US2lr37LTBPKDh3mNgITepi+9ughGHcLabQE4E/y2wEwY9tr38xp
8/TbIaGFKxnNI8daC01/JOqBxfFMPoFaJpjI6FxNeRudonWnaxZjtHnLzpnDQHdRnyaEEpDexEN1
g5sQQCsuwJj1t18Q/VA5JtrBPLKhRteB0boRDIaz4/5LwoE2uwkFVUy0WycQld+yN8Uyo9WTPQC1
B85fL935Zs3QzIjaMF4FnQ4+ZLCJK9/kwCUVolrniVQRnsjY+TuL4dfutkNJg06zLXG3iMJ4NtzF
rdTArZ8nZHC853sM8yQjL3YLuE1ORbly1c8hxCQ+qyRNNpu9HvwNhRWch0GaxSLUi/l1AU48xo2Z
5P2JBR4t2EqJEFjsg6OXq6Fzv7AIpQYY59ySIn6ZVh8KvSHHhsNXmj6ncfrP4dblqoVTmaD25kan
oOUCAu37QITgmHx4wr15lleL6Ob5B7xT3Wct7jS1L7n2ovUr4i0gXUJvK5LnIT2CAib/dOX7pKEt
vMM/UYcpvnf7oDSqQKYWic3JjyPQViBNJolz39SKMcVpn1yQC34gHAvL2Zxyr5Q8oOqbjbGJL66J
xv7gFLJJTcyJv2WponDxyADA/XPdSVNmcID6s+lJdjeZakQElfsczjlnOQRA8dHlGGIAtLD4L59S
V1UYrcPLcqUh9HqKR+p/cg//479vIKHCDG1ELWWkvp1qYSBW39FW9WsKg0wrKXD8+9bDdxhCh2Gf
XakS/uVvfGu/bzcadFDlOBG/ULgQfIRhkHBaJMcEsNMhnXNVF9Ff0IDX+B+z3Wg9+iowl1853KOT
6leku07X8pBBswG+Ly1C8FrbfRz9OwWvQiTahpwm1MDviT6qtZ9nW04E2M0ouRn0cNPlEl0DtaTx
hWbiMkgcPYtYEjBeHunihcEOlJtWj4ZH/Cb+GgF+YaQNVO+yJuUxrextKZl6PiZo9wjy/F0q2WLT
GyYQrj9UYORljgx3VK1tK/QpeAYsXYLthDdC8GXJVBf2Zo6v75ZbgNNV3Uz53YCpd5pdsmHmsWKt
UWZtdw9StrfEAz+mX6rH8RtWpEQ2+9rj8RLDJ1dh4O7jvW1dStXP0CBEVucTsxT2ZbOb/mPp1H6A
UWFKK9sUfElbh/AxTAZaZfH6Z4lzRs0eLzmvYaxaGgRPFBXAwkZkOHnIfJxB5m12vsSE2XJDXPc6
FzEE1SDmqCbLPuAA4Z1wrf1YOfkS8/x4uwiVtFo/dlXb1ztFV9Ai3JanuyAqVNWrzuVrOt0YKWwt
wWydK5mCr9wrepC+uBCR2WiqostTiwUlUDaqPJ/4lzpddY0aaoEnUlRthLo/r8Bi4+EtElbIv8L0
25KMaMjwe+I0jH3yfbfNZs1ifg+0Z+yZ/9PAQ5SNJbNT1SdEKFYxoWWKmktSZmwMSEy8UKQpuVnp
AI3U1JSAJPxl78spOa15UOc9cjyy75iahPghxfi2Gzz7BNaSe55sWNd9Q+eWMfJYt8wPplId0veJ
ze5FsmZ3ONKTs3vaPSsmkJ3kFBmhaWk0WcFthRrUC+8a7SyuoJaslHGp6PnCZ3JL+uJ/xspaF1AF
MW2USDBOuAsGangczKwyqKkixUZ+H/SX4O9i5N+sM0HLRf1k13Vxummk1/E4hhwBQBkll3wT3Zjt
C7XNy24vsHMcMitNgSktkdhNwmDtytgGpfEtXo4dCDQ77fIUCvXp7i2kdupLB6jBvPlVEx+Vb9G1
K7RHqqtFU58tZCU6S3rKVxU1KsJff+jFavFOsJ0vKKAZAWveNwQNHSqBOUIyOwgRvOCu8X1cLEEi
/BRdV5mAAzd2cO8K6LKFyPKcUJf6cfahqrSUca8unHuoYWILHqBM/Bf/AjTbMdqV37GAqdWbZX2J
D1TIM9BQJ8DqgfqhKabXBM+44rDbadnpVdlHRFsTreya+yzxFSJrfhha4PRJ2lMK/H5wOstYgtVd
P6JVMB3jbX9XowoQPfQ+eRpwy2KRYt9enRPwneMpo6uKLqx1afvn6lGjKcCtj4fQQwBRLAUDtKRx
H6nOXVxvZih245LEAmic6jEtGEWXJkYZ+RF19j32eradPEJ8/iQa7JRXi7/XbJyYzf29pqRsVye5
fgvhbG+CZfxgn+Q3o4TxGdIuEceUDulIpmCj5x+W/lXpZD9OY6nF4fG8nu1iu29xHNz/QL5GzUWm
ecIfiwmSoDlgBQ5FMJcEVtrCZgXUiGVYVQXypHoUkNLLiW/K2xMp/XEynT4O3oEq4wPHVp1xtLws
OtUvCQLWs84s4MX2Uw5RaDk3qCuZYGysOz0nghn6rRE0oa5mL/2B+LPGv570QzxnE+JMj65soSUQ
6VdvaCGgVjGAWrlfHLiaN9Z+udD/FbuCTVBDNUqzE0l3vu4WM/U97IL5wtJWEKbG86ealDpRrQRE
NiAnWOJtu2GDYKDD8l/INxCfjAkDPJqB17DsDwX43wJUqF8p+OlgDULsbZm/oC6P87GVeUP641uJ
9GAzXfpe/We6bpPrtxmWDeITTbAAMBcaBV0wh4jQJVCWbO40/vVN/ky8V1XkQKtNn+yVe1U3c25/
k337o2gRyXcwYVRPtkIc1zBvqSQTIZE6cyTIPC9Poxlzl5zEtzRwFGURGTY7GcsrcXgYkjDEgYOR
tkHbz9i34B7al+8Zoa/7caJ79gEcDz4Denw6c3iYXTgAAhtJvQLUXZ+h0QZfJm66c9XXJY1uYyMk
tjJKc7EQrv0iAw9P+myRhzNwsGi1oS4L0F3e6txIr5puP6iQxilz/bPaZ78Pvtvuzhq/IpnbK0Tc
nMfKjWD9+m9VD8/UdSw8fUKB/uWSYz799Xp+XkFA+Pk20Om7hzXDynaBQvtslmBK5vX2r/syCF1U
1Kj+6r4rZ8uHPdePUlICKnZacvVpcbSEwI7BItXTOMW2e0r6qMPRJGPvcNHR96YLND6nHMVgoyly
MnLTDv7PmamfGEmJ0lvX20cRnk9xOzCaCmGiZa6p75GWsskvRgVsgVSVfEMjDRZvCmPDs4qT/z1S
nQs0aIscRWF7Gyz8d2XgdhSzSTXy2LWgBidcbdoB6f6sOwKF0LFQz+egv9sQKFYZJZZTe8VaD18n
lfRP+Dy+VzxoER+ZkFq9O6nBqSlGpH+6ZcvfYS5oLHg5wjyb/WMv9Zbx4HZn+sJOjdrmxJ+4Z486
pgzWDCXpav4YgGLoEFc3KXYOzM8CX4EmTtfomAWqMgr3YLkI9kXx+v+GJo1HFyTtagwpE8OxU/M8
LFNFjkbon9Dp31UsfTaNPugC1yDDQ7oOL/o7/4Kjr1J0PuY1Iwgygq+7SWepjjMernKKwHxnOsi2
EaY3r8XD7qdVACxBRRgnWjOzR6HyRcCnS4GTEk38m3Mnl0ZfaQqtRcQHlht4PJVuV+PKmpTWgl8J
Vl7PkSYaIkzswsm8pagu/Mf9AjgW9S85HKuy09RQXR/XdPF0l/GJd1X2r9qVzGQ/iKERq/Jxt8Wm
tUO5Ml8lBwiwTxS6xQDwbL2o5+di3VJCOcnAdcgkdJf3J5Et9vT+XW8QkJ5NxsszXaf+lM6GJpzV
20bs9s60cdyYm+OqPzuBDGRUQobkix2jE34WCHgObFZnj+547z6kyWMHlLUAx/j9+lP0d7SBoMzw
PMBSERH4RF0LIlDdSdbJecQc1UeugUPnh/k3CKC56kmyfOeisTuJmUbiI1+2AV1W7uLiDw0E+7Mt
+Cb1xMrq/UwX9t6wAUKl4lyrBz1UZbMIt7h0Q7Ad6BCALlUAPr8EarZpSLlbYEAHEu7mw9IBwpNG
pkfuI+yJXvNG3T6jVjpDTK4tntwEP9Y7VEpRpluAEsYw+ra9tjV3fgXtQan2s3zeZGOHfOgIQzWx
ZdMcGjaMQE5YZfpXx8A1oo5Z1WkztlthBFFJDjXKJ3Gen8m0HIdCd1ArB61tt+rD6fAfTGESy3o6
U1TPW18ae1K3zUSFlNv/CIcWtjtZcz987/pmcksUXf2nmrx38XkrLPDtuz0Iare4iZEJioaN19zo
UQM2eRcCMHQgIfyQogr0X6imYy/rDJ7oIMZc8V+lH2btmA+cevcTniFdlbVdJqpbyfTFk/ynSyfy
DVa/2aN68m2sfy5lJQwLVRTf86+fm3fqSxLLCPLWRxO/9qUuyP7WynrnDH1suLwY9bAK7H6YZmNN
78oRS8JoBFctGuF7aYwKarwqR88ZLtkxYzq6RnZMzWgBs9pLgPl2J45aHHWORGnVkGcfF5kxLWxk
GGjugqg+X43opJHje58wmnNuCv3gHrv2zyRwaWsCFukYQ5fj7Rc0caxuGCehlsx4suVCDbL971Zq
cv/CAXe8KVQEkhR0//TUdwHOlmwyT94uYrZrNso/jvtVGQMj0FUx9CfGLs62oxebCOQIy7KEG1aW
l17laAHw73RNcO5NKiiMWe+mhCterC3JCakMLHj+q3CFFI5zI1j9EJOcSAKQ8PVO6hVtCwX00SEo
PKqXYQx4Cf5B3VqyoplX3+HjArUMJYWMf0eahFWheolTP4G4VzeEWSOui+P78ThcU8L5kwAZNExP
4Llj8CazEw3wB0CU7rb/bvp51mWM8O40fpXS9RDIQGbODb/mjTRTtaqznIoVB/WMAQcjnxnrZ8LN
8uferTpU7R9GulpjZ+cc31RtXzykr8etGKIDSaYDAxUMAYcvj4VIICXx4upRp551Ll9nXxF+nhZP
WVt4cw5ZyzWiHYzUZA1kVUl4Vn4z7iitg8wAcbwVOzoABEw0kVvIy4yyItLubBcDgy1z9yT5djJk
OiJDW6dqnJAj6OHxLsr5vkmzgQZdiYOymXaRhOnWdcZBSethR+bBbvJiofSXbWJIW3eWbJnl5Frq
n6WbvD8R1cTqaBF/qLjJDd02GTaW+bfQs9lSrPI1VmJBhlt0GuuEmcoBFb1jAqiRBMO/omR1lQxK
d3OXfoA+U/NQnI9QqD7kfzqUq8BxXyInB34CGhkxgzVuQa854UU/7Mlucw2xouuoommHad1QQg7k
Qvj7h7EavDKWdDskjNRaVC/EXnzmd8gjdBJK3VxtmDg3HlvxZMv/3YESZXtqQ6hSqGC8cn4nSRIL
AzBaF516aTY3KmtY7D6McR5s+6A7uCKTOAIzidfF6B2KTtGG5KVUHK3He3vR+vsgvmuuE6y/uL1W
V69KbqvAiqtuTlYxxgSxSN2GR7zAkOl3o2Rw/CQRjtt+D/ckUSuC7sZ6HNKCZbY+of4axk9DCo6P
N2DEU7FObEaT63vOb27JV9EinndX61KChv0QW/VJ4v8vxQWnLWgMDCMEB/3g9E65NoUMUOF07UTw
yIkxXSk8sFmvBAml//aZJKBf6SZ/UfxAjQEOHOkThPZMUuHOcaEfX1MhWcdGiKjUj3a30O67us2v
rhaQ8tYEusoYB8tkdGi6Bsc7uBxQwaHOLhcbhA2BIKey+cEj+z4Gk7R1NZdn72FcDvBKkU5XUiSe
slMxaSzf0gc+sGd+z52cNY5kA4Yfc3vMYg54REyajRwpuqfn6exkyD9TVvLa2SsUvm9y15JgKSV7
gzSHuVMJlkZD4IXxE/xlHtjDAx9QXFU3tiGEwQqMwaZxX/9YSG8/mdfExeS2HOd5U86MJztb2Dz5
mq2PhjZZ7YrnZITINOZFZpRnOdaHiXBOHG3Nbwi17y6Ja2NtpmLxaBwZU8jMCMsIlDvgXwOggOiB
fB2hfpwWblyFlp++RZti/aFiFRt509uQ4WL7GuWAALxbL71nNORfguRKF4/5JEbXaupm9aV0Gkzo
a16A/0I4OudLeQdVYosQ7czimnC58nLakpzgmAK6rU/0hunMJUCmA1w/VxhEVSQYFNQkbJ0te4gz
UclnuEw3Lpb6j+xMWhiIU8ZaCbqaWPBu9RlHSuED3qnnHY8c1L0PZPCFvlHqFqZk5/y0Q8cC9/hZ
xh1lRvG+LjguhX5bFBhWvZ0IjWUuXaaPHJFJFHN4dHH7WXPisvXt9j8fYSlNeuPrrNlkZBglL7wU
Md0JeVF8HDFKmviQlUQ0yUm2h5KGnqnNpWhSff7W9COpi5SyATnkn0kSQnT5elsUdrL2G6YscQfw
T5qNGn/fuPi58xBMLonYJV1n6kFzNvUSPjSNTIcv1z1HteljDLca+FPN8B3Whq/4Sv5GbiGSa/2P
LoxcXv84DTDnKOeMQ4RMTxtGdlnmT2eSACFhZ6hUPCDONBRp6dWCX3FZFleFWqEWokzy8kRZ6Lb7
ieAXpgkLq5s2ZUg4aHf0V839jyoxws4v9XOlVtv+L4Mm5/tdV4qsG7QXV/eeIXnzM0IcfXkmGVzY
bBKZShstN0IvtXahuuvgmR7m5eppOajQPOgu9rCyOKIBU2n7OQiIHJZb8Ch6Qxfj+8HQoSRtQwIh
ckqRlLrJNlqAl+e2nUBhUhXYgunnEb1spxctwo9fm3DpmzQWaHjW912EnG/j3d40dpAKKOhXcMX1
Jv17SM4tuHn+l6jrBNFtxZwfRqZPoUiRyBgyREVm1kRQj4OlTikMe/mWAIFl+XbHmfopzCTBCzGK
sEIO+/Rz1sFJ0Fn1WQdwUfeayv6v82Ntr2g49mxliNIRUVGpwvd1uW51JZvUjYWkZsUY6IWsKlJC
1jbIkyANsJSqDI7MuElScbJ5stbzwKewwLSBSi+YG0tsasEOPQpyRDsqhGksLHidkkjD1o25fPHw
7edNr+Gd6s+fLjAL0m1cXQSFuhbfbcV2eJTkPza8ruSKQ+xBGaAqgk902v4TAYrvQrhzTrYyv+iI
hNl/llEt59mdPp++mz2SMrgs39kLmv9s4Qfh2ob1A1FTB9uo37a/6kwCC1dyX8dqlD7DIOIPUi20
/+HfwDRx5FYBBfCvkK06UDnfOTlyd2q+lqKc7DAidICzAmCheAx1q09Ovn138FBgRe6xFz7a2PcM
VQ6bkvIs7PBIRhguhb81GFHkjut3yu+AyWT/LuTumfshevxSwZ1/d0nBi/SQfJ2N67UmfVrgHojf
lAiKiU4Wv7mqzD5WcFFPWoVTPDOOfEuKQ16IFp17u5rftDKPMooZ4R0OWr1VUK5fJ9+bdxbeOpRM
FudPC/GZQJRV1HzdmS9oD1zvLF0Ul0eIYzzNnzzZsJHWJVlFbtG5ket9T7ey9cbhTcP+FxIOzIi2
bI7mDmDxj2NIU0LgrbUVVR+ueQcckgZWSFRZuUIixZoJvncMzexibjxJ/scCR/+MWNhRFvMZ8dDp
t4FVsci16ID7Pg/qheZ05piLJXfedKk5cnjkM8T7w5eGeJjWhFYItfrMcgQbTInBj+VoFBOBZjBn
x1ObcMvfz8fN/el9mtBEcW3gGnAfLnHHmWvlOaOt7aNxoaBo9QIkpqbHynrvUEI7Ewm7kVRi+AdZ
4KEPsruNxI/MojoN7AGexOxxk8+kKsSvT0ht4zHRKS9hYIx7G5JvfTrsvjX79WDRqzd6suxUyXIi
KytWKGLrnCQuW7cbvCpxtLgCND4pgZMZzjUfF2VviXBG41Yxag5J8C/Bx12KiQSAmjAqxQqiakeC
jpRtnFnfGd79Y+5F/kLqVfKXncQ2GHhANWO+vsGZvbzZQb5iVi/aXLhaUt+UE2/+sn4akABH0Kf7
OgJ1DfjG/jCdQN42avZ2kBlJufkbs5WRF2U6IbFu0pxhNww0heD89IfGKdG9NMuqZPGhGlJLRSNv
uGhhQF3FhdpVbRAvTmJrYoX0ETwPMNxSDaVgMRyRR6CJcUaHIR2W2A1AALALfWHK5xvp2DLC4JE5
BLMFnv94KQe5Fd7odcLYdfw3iWkgywa4GTzQ6auFhLh9nAa5/tZ4P47wKAhUGp39xAImQbBOD/kZ
w932IrgfLpU9HtdMhpHhmdt9R+x/2suzo2ZE8T2wICpZgELgj9U+1iP6JUz+qwMKsNQtq1qbsbPd
rKB9vQnSN1AEeLLjx9LarMXLJ4vr4t9tLPPquTcSIctEheIoKAdQJylFFB4WApv/8cbOMQAx4i1T
Yl0rFxrb4tN0MdecHBLx3taW5PzVlznwQ4pjPacDF80eMMLuiHv+DGsxQIHgXhsVEKluas+P4gKC
IbZ+FngZgJHbAXn55DHbCJQtt+jU+mqfliV5hFceltfLQBMaQMsGhMX5j2SugdtY+0P+DSxRiRyt
sgMBWVoR0xb/CHg/hUAYRFIwdqyOaPPWPwhrh4GlC/F9VaqqDILHujNW08kQFsFzEdWmmfoxOeoL
HhtnPJcau9lqKVaiwifa0LZFCznf1F/EEWhXXgRvRt4YWDx8WM0ZQKRbqgErTL90OD7imESk3HDv
JZ0D2C07a79qKJ4LQDmXVAEtRVFCRi6L2uL7jmsatJPK6tfWTX2CH1R7BceQyRS4zwbo8fAQ9s/r
0X3Kosja5J8rLCdP/20nY6ICD32NS5VVvjX2Biles7/Gntq3M3n3NxvHIWCsBj6DjXB4E5v8vvF5
+a1dgVslbZDYj2U2lhaR1xTEVBzmGdPP4pQroNigPRPs6I/i7eLT82VksJYWxcs5N+WgbMt+Zh/F
G9mKiQ6WE3rfsZoU03wkQA3jjyuAfuJpJ34n68JWZziAn5+S/ww6T8zoIfxiIJP3VQXpzlR4eX8S
qSsN5dQgIMyDYTAnNlnJZCJ8HYX5t1e5BH0S/ELvmbCVr+hpQzn17J4xXppB/9KCBp69nq9rTUcS
mQt3TNmV0XErFZ06b38oRWFbVYu4O0d6Q35FirUQRnQKXKPWiOs6oSXXEFxBNQ1kJEgEcLJiYAxf
2Nalgu7T/bqaf2qzJy48D7W+ci/XP4I+rjTWxSR8YE74Nn3OLQ9QGtgyd257a4qCPC6D4yCfxrz3
2ZFiohCN85lqBGery5y+WkPf1NaK+6u2YsJjUF8J9+xwqY7v3dtvA6p/gLsl9/htuaO3PXxepIQ0
J9WblAYoz6FPyZskfEsEHIIEX8P7XYAT5nBgF6pvn+PpQ7TAre2JjWmH3O4Dp+Pj9STX1XcaDw0f
fH89Ddy8Up2hVhb2uZI0prEOqsu2uM9i0nzy6FQKtDSQNbzWtSrrFEWVDYHQk9AaFzVMIyvNotRe
zVfgy900HnvHPq5+wiVn88xZ3wmvxXzZWW2Oytja2L0sZnAwWUUiPMoZ4QJidJdCyPG7QeN5Kk9z
SLZ7oVaEQuK/4qcbRQfAsP8pZLLToZioARBxJt1nmnBnuDQiNLEO8Lvmyzas1hUFxubA+zwJ8DlS
JE8TyCd9ucugC/Z2m/PzMsb1EaJvolycYfWVrkV7HIjqY1n5JqJqhop0ktTkevqDJuL4wa4v5V1+
Dbu9RVXt6HZxuNk148/A5uShoT2pM5Wf1cJsvvwxmj8R27uwrdb6b9nXRBh6Jn7eWy4OF2Kn84rn
Kt5fa+zEtVJL1SAVMaKoFx8gKbMq8b+yLVDocQGzcKnLkKmpr0iskLYU8KJrPQQeC9yf9m1OiGNp
FHfYZRQbLATBTCvgprxzH+HRvtjJWAngG6gxXsXxwt7VLjF06RJPb4sJ/fMBTJrNd7r9fqTxeOkq
GxAW5bJufF/haMweKUKBZKx2uEOmUz0hH7yYpf1/IoW1P/beOheE2IBz3w5J43w5Ha62CIJ4lPqi
oNWcjoeydK9sPGmwpxy7YFsrLODr3KoUMTbvU7vvJEAMofkkEAds6TptTjurSOc6OuPJzAE/T/hw
8HL1QxMZ0H2FBPZ/pJsKeUZa3eDGKccvtxZUEoCoVNn9FYU04BlwB9rEXY9uRAgbi9nyPbDPdFRe
1eml+3bns0FbvV6/9PKCLWeGJb9uFUfterRwBzpPtml6piFAQhkPaf6zdhvFGygfsuDJVa/6jdP7
Hp6P8ZFlxyjCPOGui9yQPYSRGqHzYA0FbY1ND2U5GwXPYmFqqO7N9ecgIw8Ez/N9M9Kfk7L5QPEu
8sM3hHfVXKa8CRlec+59O9rDb7+e9RUDapym7CeatBzodbAt1fkZayDYNKFMoI71bUbbXuH4N+wI
UROc1OCG92vRE/dJpvNHKZLDPKiXV/0gRYKv6QQ0qfR2oroONU+mmayAPG5r3COmOAQoocj9IyhC
/Wfh2UbMYunLPeFRh/GjHahIOL0S+REMuedI6iV7lAryXbTUx812YZjLjTEssqWwVQRXC8XcftGj
U4sI+Pm5AzOamCKuvu+EpwTqJaXg/qExG4ga425mSSNvq5eyKvha7EfrT4utYxuGDxKxIBGPgUIF
ZkqtNzRnTJi9JPN2Qy3goIxzFY6QETRiRR0GvYtVqNeF2tL1qgUeiv8zZ8o4N1Z/umYBwcZzcW3t
8gS4+lSwkGHXVuZRlicGdHY6L/KHe0K8jYq2viucnv4pc63uxmW1vk5WRh0ssyV/8RrePkYZ3b5S
oBD1gIqIXReUhbAVMgaNCONfL702+c7+1e8+HYT67NXVhIQZQYUxtqep9NE734RQ5KBJ5+90eKLq
9MJVVPDECW75h57BYkwLPlq6+tMOYo18slAGcGMiGE5tkNhLm3pqN9ebF8XrvohhinUZIVeKO/Ik
0OPtTC4CEI5Rja/oMiSR3DeUsZ91mRcOygpk5+BGQuNPYWbm7fzN3nY2NxXn7cqHaV6l270RDCRr
c1Y3IEZsIDX1VJ2eP1DqNcpecUg0/4s4tOHkG+FgJbBULZXyholPqFspHMCKfoqb2xmCj5ja8lvl
FopgwVW8mTG2yNvtzEHsqVImNQgNJAuKOr6xSV9DnhLvD1gAIhNYOJaNhVW97Lt1CwXTEFFnfvV9
vyzbAasDpufjAiN56oETtEp+xvDQbGIdwN93GA3wTmTZLHa8YZgcnNLcq3LhDo42oE6+K88Y61Wu
70S9ngvCXnKlDAEMB1D952a0ds3Cr5omAi7jQ57nt9tIzMJtoTuNw8zEIQSrsF/zs3hDbrLQOkO4
QpYsjX5NIsmmksy0pnfmsw27oJarbe2NpKL2S7mWloHcMeDDHZPqDrHLzv7MW7lgfsVin8Sa4dOi
wOQabrKav3Gu3E+xRguuld6iBsNKiJcum2ZYUbn58043F93tnGSiHF7CiMc9qg1i5ThOYw+MPmAg
QKCOR6IYM4LbRb70OJGdh2A6ArE3hb1P8GGZD7StzDrbSFi1Q9WSXzrzK+gaMaavI7jGbv1/EK3y
Mz4ZphLYnCB/9d5yC2IMkG8AMJgDM3dqtUk/Z/2uwDiNQ8g4LaZDS+wGE6M/vhuO40ayoBVNZX9O
w9m6B0ionLArUja3k3+kXisd3Km/gNK3k73iyMtqZ/4piziZaM+iNifTrG9f3fAE8TcRKtgLyPmz
I9BbNGRrxMOFzMnfw+hY8GJWAsmLPhl2oU6c+9204am+5kdG6kU41YSttKWjIpKOTK8fZL3i6L/C
Af6cc1V5Eu3caGbw7U8WHyXXcUZOLG1Jq4tIKv15/V6Qbt4+ylM5Rv4xnRO50yXh32kXsdfHtvqG
z8aUJ/SMN8tIYRjrFt/wFqLVFz8A1mTW0NLkkEXHeFZg19R5LP2T0x9ge0HNRZn6fAqv+b2/9cJ1
r4d3gKHZRvKCJQkvJWDH3WZsJ1dgRFA3rumXErevnHWbH5mxSR+NqHYLxnqRHsLoy3mZkjp0dpL6
gYuLciItICAHb67pfnjvuLBU6acYjbpgat6/YHJMCeJ6pK4hGrxRdzCbuLs8pVArmeqJTqMwMl4S
cpH34/cP9NtCP65i89g7cMJmulvwPqqe6lc3b/c4oUGFBik/WTy2R3F42i6BjOUGFY/2WKVzjYhk
RGgoiqOZwDD6A0hO1I4Bl4bxkEcHjeiA9brBrNq/RKiUkuziDXGBm94+4Tg0/dSr7NhgrO4tnAP0
WRCP1kVcJpnCbJBQrB8oz9RJVkhxEQB5SWF0Ji3KvlUyPF8fKTfj1QMXgY2BtxIxS3HiulJ69yS7
CqnKTO9Sj1TD32Keh+RcImk/K0hT2iwFgZNwcXOuAdlwfcDuzTlQKemOAiT//qZNxlU3RuIVTosH
ILmICTu2ZTa1nUCAAGj5Rqbk/A5m6PvMUYErpCnHWUp70hfzMDJR3Ry4761qLA0uRDDufXaKlQAL
k1c4mfPddpqrOXvkV2suHOr71HSQ5LXIV6Vg0Rj/kfDifIq4qiciUExDXyRl1kDg10YNrfuSm9z6
OPM6KRDQsllNNTMJJ0Vui+WPNigbXUIAe2y2+lGRJyNFyxdRTtcHdKAlN/BxQhJPEizP3h3faqvS
hI/G5jmfxMFT9w3T1R+A0+WfQnFNC1EYdz02cPdDbYHM7HUpu6Hz2a/pFwR4MR4aoGRsvcQv+2pc
MMjxUjaJfjdhF86KPcNE3fXNNZv9YJ+nUFuKkxczY0AaimppFk1sxAiUvioAZGewkoCTjSZ4XkD6
qAL/ipUsVZGc3jtRr5kboPCWEcdmE93Ptn9y46FzCTbNhwzM4P/PyxCq9DMazdjLWRyhUHFX0ZKa
uYFt/0A9s9s5EAskxx/rJcSZ/dZPl7CTnyN1ZGY76s3b+PgeEFGADfnOtazbcIBRHKka0ornmoC/
fWWZo80Dc3h1BBk9K5+HH/XP5NPvllKdQVc2NnQlaAiGQaej5brCJD28PQd3C23BUt+7lc6A1gqG
Vo7/adGGnFYVekADOlqSRK/+Z4QeGypTEWezmAebID8+PdQ6PTxFJmKSLKNV3Yb7eo1cMmn8OtNY
OQlbKzPIWAwOOuVrEXre+qCVtsLE7O7ZJbidx3DSfFul7aby3E1uOaX3vtpyMe9Ff5HmAGCkH9OX
ouzusJtbPHNEiINwrxzHuTp216QTT59U1LmmyVEpBmvxg88sJZ9AHtCOFO2mlsgF+jbbjIC/otg3
BlOsk0GAmQy/OJtVmgoxs9isWAkc0ov5y2w1dp/UJFe0siuliAIrLAm/bNBC4UjkF42M6Luc4BxP
obyi595D7gF6OdOnOlUQQf0/bIuX27+zXXIudTV69op8wwxkfPd/xM8axjEmm31k8Y+kftKvuATQ
rx+2GXXmoqHnHpz7w0cf5jIG/xJFOma2QxnSgk9O4gry/ulKcQLoznv+7lK64hM04+PHcszoikPl
O9s06kRsTbp4qPY8V7U1dRZsiWCKSH0lMaLS9w8AJI7zFnHiYbI9DMn3SDXHzqpy1qzy3UU3IGyf
DavXitftquHCTtYCpJindFZctkBkNGpvaCTiP4GzJ0sKN4BL+wnEC6jZXhRoljR1a7mHN8YcuF5v
+6wox+rlr0vYLFxJIVbi9j2UIf/dS2XU23PQ3WfQELIFWafibHuw88yvbew2RxkZQZkkQEhB7zn5
nlpUwSCP0F5atoOIPrGPkA0Q1gdycE7TdVPSK4jiujJTxCt7T0x3b3m2Djp5rY12p1SVoGMyUdiS
pURmYTMegBOUL1Ieo2fdC/nNBhpVpN2w16mAvAyKwXUP8vcc9bbquDFJCgM/rZvlMcFAGSIWNAzu
9xi/EACToYgA6yayfBRnwxclVPOq84Dp9dZ2BZxKJb4S09K9ouEKcRtFvI/DH48e1j9jPYkV7g3/
TVrtrizXew3JWrZISMQdanWRGlk/8pwN6xR0GddreV5wfAEg5H+ahDsn+pE60OFWpTXZ7UpL97te
WLh/lI0CQzpP4OMLhkqyvfWQ7ZCS4rJdFq2NyKA4qe4ZFB30DQ9a4vKI6M6YJpOwWNsfiqhNDT+p
WfXr6/53yBJX/+qYmb4KVm2nEx+Cp1wyRZE+CdnnphRWHScPwpQV9B1s6GlVx/8SYbN5AuEgffmz
LWdMxHTQRYPuKw2a4pZ/8y2tSn27PcdnD5ufBZEeCaR+85lYaOQw1QCTo+VJ1NM6De2sVKuNHQVb
I1eeOTE8Gb5n4jNWqsDJ+jygZ7KDG4mP+2QR/qd8mCE4FHLA8xP2l8IQKBExa8mT+aS1ktBdU0rW
bSxAm0YZfMrSG5NZ/vPHtJEeD68bejMRHB4hmKhA9056UMhlAMFJxnkPSZzrqDaJOmke+RxEScaq
ocbZmOqUOuGJI5lINc5n8y08FPRZJOcifzi+/C8FnX83QGaL1VzFMMeLbnSjkwaW4DByf/12BF8x
sec9aXYf81rhurmFzUhCd99Ee0JilrvxgtJ54V6M7ct3Gaq8H5Iqp9R6LjIqQG8v2FF2RbjANW0J
jyPDxorvoO07jgQrk0n6pxcSAwX1xI6Z2+X1SswnNndS6JeqeShM3n8Imsx0uHIjYZzIgfn0mEjF
jQhY01sddk0RaV/5AeibkG6jsARutSu3wDIihS79zEnoAdhYopdVK1OcFrnvcXCaExxiZ/CqrJ/R
tFIrdZbtxKx8KmDqOwXNi9KNXYNG3xDN/feUMJHEKVGwngiglo8ZU80bV7tvtUoY//eah9UIwcXe
NZ0O5sTdcTsZF4kog5hVYp15UqweDzXeooNcRJC4T1m+ER606MZkicn8a4Kvol9t40rzOeHdvR2g
8rNmZ3qtPBFhE+p5169rvbI3kQRJP/4iV9pckac3LX/e4tkUM8ewf4DqqyGiKIATGCIxefHh9WG+
71vhrM3Vbi5dLjeRIYwHZ/zICcq1+6KC9nwhSHwo+ZBBKkPKp3ujUqY1ubK9kjRoS9fZX7bl29pF
URZVELcyLm1e3xAqL4RefXiNb8zX40vEzQLpTDjrvMlXQ+HWKK5iefy4Px3Zmxrb/HJzBv/7b8EW
sZIPKg1jV/5frdRITHjZcNOB9V+8HPUyvqX4/rheK+N2XgGJVMSwih5VzUfEMD5RgT1JXmdTwcFf
saXHtLUVGxa25B8JEgjDGOzdBf/DMykb64OboEtlifhT3oVgSDMFsEobVzE3+iT/miVIO78pFamA
nK8VszPw2MVu395BMr6K+pVNcd88Se9Eeyf701lDkMbZmcKZhcJCK+C6lrM201HAKhtL2OjA5Me5
UcOVlalMC9wDDZYhqtpqLYTQNuPjEIno/NzMKqFSSSG8UaAZkL1R2nejII6p9fcZI8PCt4iE+5ld
ruSjC8VVXnoLaFE+AZumFjreutBcAkyVLaA8bKhUs1Q7HsLw3zfTWOzQqRbKzwgsKYYYqGt4PIce
sQEN5LURiUEKBQgJyezqaLlqpx28AYYWzo806ZQ7+j/Ru/LFiybom94NnNwwSKrtLuLol/Dk9eoq
rdFmhwjeprEra7+Lok3AjEZ85CaVrwJrKfuBZAgNrlnW2UTFQcLOIeanvXyqDUSntknOwI7cxoRx
7MwEV32cb09x0bT+zAvCiZWtzE/Q5FRzKkoz0zXol26hFtwRNv0/uia7BwZ76JkjcKophNp+cg/U
xmZyw4aXsqZPbA6sqia2JR2QqTPGWXRYqycKyYq6qc0jlQoJc9vDyT/NZhOCKf5KhE3txPGTpAQp
d34ViHttffPAxrIUfQ+UEV3GhAXEKOv20zJQRfronNcpWOW9aY/F38pcve63upFpywkRiS4Q3f+N
fm3mVAs0jUqVP+gxkqzWP3sNpmARxM/MZKYz930M/0XYXR8LgC5dTutkQs8YSmu4r7KyZ0++c9lg
zc9uFRxHVn2+pQxy7JsMbFUR8eYxAF2N8mTxVpCP8q9Q4XdayCDkc4GJd3L8TjUHa6KB8qkcZf5a
Khi/61yk0jGyXmJkxDBFoJzH+ygt0XVPZn3cSLeCPQtGQwq1z3lIgfaIv2iO9o3Q7Kkf5s7oECQE
wP6Kt0H2ISypV1t9guCRPvymZ81lK2GUqgsyjPWtet6DpvTwwiYUAWgdulqv2dTBjo+x9ZXOY4TO
RDBQpq2YP0ynmK3j8P8VvsSC2drATJwXihnq4h7cL8iuRXIGzBaqINY/Xx7Kz8rkArndg2YmiTDZ
2smfNOaPPI4GZPyXkNccUYeYYFjypDrAb6UFPEL1DFcC9DJPQRVm9zFHm0UnvMRYYQRi2wtpMTa8
Xfu8fw1AficfgD3R5GvRM9wGnrRtGyJM2+/fEw6xi/9hBuIyVClWf2YDJWrNc1zIVwrPdXKtalPA
LvPakAG0DvojFHGAJMKqr2poxuCtM/ZtCjn7jZY5jjKgpNF4vk0HOPZRSpB7a8W2sdbOATqVWP0i
v0dXEiYdvjKk+ZakpkunCWvt9whgdbqeSE+WRKWQLFzrEWxsP7l7dwuP/+1c+nX+8yNvg8FIdRg/
IMVguSsq8bGNlmERDa8dWC/w+elaBpNYXKVax4aOrDbGcuiLAGgiRCjy57NRB0IqhAjKTOCUI3uJ
N/lX5qXEBQN9wH1tcXpmuSdRXnHLNLDxKo99nH5UTsbKWbShabIQOs7Ra8Pr7n7Twud+j3+CTw5h
raojCUlLUpyZysm00KCB05z9jbh8zYlwD1Oyx7ESCrcg9sSNTq76FxoDpUdRSfn4w9uV5u/tlUiA
trJpBk9R6PbdhF+1KZ8RQDxKqNuamUaYDu73x6sIsRoTO8qtj97YADtw+jiir09nCyDogCimV2f4
gCv/I7p6cbVx7M69QGo+5ut0nRFAXSaMH4lUmpDXxI+y5IH9D1mQBrR7kir4AJXjygZClm2t+dMx
ph24lttKNG87WMOG64G71J5sv57mpgzs6hdwWypIn16vLy7SPR0zVGssaUcxFtyHSs2YMNdoTs6a
hN6jATMmn4xqZGygONIZ2cfzIsN9VLOc99V8CXTjoFMvoEnQl3H1y7fOfjkGDEVlVs9bbCiw0zAY
6rtSJfIr95g4FIFPe4TFkDnVaSzXr3tSPs11piIPZgZh7U3a0w/tzFTk3cfQsCP9KQLtlRNsLceL
h3RJu8DPg23poE/o3Ow0H9+ZU+BQw/oNPkDmnAdhLIr9WJkFRFICTJhiUdgluAOkd9XKiF2nAgqY
F6hroTcgJK7+D8+a/uDuILM0CrHN/6dnMIBiv2r1a5T/WUMjAmyMJPC/eDWUWgce7jaY8+SPlDPQ
ipEW5r4qAR/jGKm2ZE6ihCXXsxKwVsH1c4OwfLhsi+TfAQYL/m3lyb8WHCCXm+YPI2u0GR0vZJaM
tym9fDiAi4ZlPML0liyqAIOtVHUyAD9Ro9/+cR+ll4Nsay9sMoa9zCEjAuAt+mFeTwZkkWXxkOC5
RXFPCtDZw1f37sFBX3MTwedVrCztkm60itjqlKq2Px7FOog/2fKAR89+JV+NIgdhOJ5BDi8cq0m+
lGIL8IgRNtTTg167fvvQtxw7a8Rb2ibiiPsdS9arNjaaeVrBgQBuO8g5CLydZjbkyJ9o6wGiWSft
C7EGA1bfk2b5/IB8oUN7gjs3whHauk9MwktVL0qGoxbm/QF6BMRIh1gRf3CggnXb2DWbbBPZvgwB
3Bf+Targ2a4h3+pdHHjWRAsiD82Wsvp0dGi8aJ3ZW3aWtinTmdJjoXJSyKytrnOcjQVtmTWvJ6pt
k8UNFiDmFIcdLut/KxywpYpTTlK19Q19aUwVukxtThmeEv5uuQ/tPnNr85nOK7Ispgr/8312g5v/
6x5GXQ1KzLleIr9p5bhfMmcaC7sfKd9PwJ+1CiIDjhoqJzZKGgrBBRdyNBpo7nQD5uBXYYl6EeMS
M9ryAKiLk9cqp7KezmQHpSmEmEdBGxEW10mgWWyEH6EhLEayLerW9vS8eQKELvQ9amGCFi7svpll
XbO0Ss1qQB/oUbbHhB6FPuQjCYO9cVJ4SrFNklE3wz6XaMMaDuUaEMMQqqWDJuE5HBK6qItFeri4
VRZJzvFvo6UemvomW+mvDvLMCO0N+Wee9alt3ErJeP4DZX+VAac1SmxcjYuzOAnbhn6i7BNh66Fu
PyA45Rag4OIDZVGuoh9w8AwXu+KhaoIM1WvVWNiNCTypFdz3Ugqi7xuaAVY0BUyeoe8dxBeY6XpD
PcYHV6aebL0TbSq8+PfGnQYksgcolMHv7UvKcZ05QOPM4eXP82uSbB5A4eLzf5CE43kbK9Wh3YCO
njnIY8tjYMOWdm7+e2FH+/XdAbL26FOXu6s/gsS4slIpyJ88t0E2u5HkvqO1478MSSV0jp38Dw4N
iWwwYzZgqATtgtukD4UmhtkfUzWId+W4p1Cr2ekV7syNECwz2z7VyFRj0lRjXDcOU4nAILnDwrzg
T0o266jrbIk8lGlzV7jlJNRrchPEvJVJDP2hRpdfJv73brVCsJUSTkEhPdnpVppwggTIXi54UUjW
1fz+IV0qAJ569QvsoH4biItKP57v9RuJXWV7/DgvwSNeJs5c2pmKLH/6tDxhPeBM2gj5U+B1gqnr
s+VPB121z4A2pJBbQ1BFY48G6a0oQf3mdtne2OhI7pjUAzQ6a56FJGNUIP1gNwDKBb1retWDtMK3
yfVsPm9Dw8vYPIr46M9VP+DcigqaJ+DxhWXfQ/PJ9dtvhWPjlJ/fy6+IBysjMuRtmfqDtp5HnWOo
EAU6dh05iK9zX65y7EUYAQskiqcfqg/M1/UBrEHLgF9E+aXuv1Q1SCN3mQnDN7hhgeaiga3ijkly
aaIhGZmpzKAUdaFZiuHS2GbejiTzE5pYj0A7aV9bizSozUNN82gM6WObwoiDUd3vkPm3hOpxkxnK
lrEzL88qzmKhO9x6g14kMZj9oClu/qwlZgWStIdF1YyESWavs4TLhBdfGe1V5OIbLoU8TmKLfUI0
vCmQf/4fP6f2Z3Rl8AZ5qcBlVyAaWU04M1zi1yxJTXBl5asXjszV7xogN+wpOPlVo1ubq/jyE570
p9XMgXXUQoT8ym/GZZKuSwwL5h3d1KUQV7cqyykohvyNvVks8GCCBU/DhATvHMe8pf2vN+cvcuBn
LY7uj01ZhZtx05i39SkTspEEiNA7h+yd2jget7Y4Vrf2LOCtqMyYgJRtlvW1hcuqofa1vKrSVsxh
n57EEqN6cH/if0aygV7izuKFhjlIYVgoch+y+Ubz4Qq3CXdJzKyAn98t+c889f//ao1/hSHxzRbS
ToD/WTRzU3u9ClZU+MoThuieUs9hyWYD89+6aQGHk3CGzAAJTdP1c17aM1Bj5Ld1R9TslftdQJAS
GcGvNkInuAhlJxHM93ktdORDjiCIr8600joxMsg6FMEvtyV5ch7y0Bg1It9+vJLRogP/LpwYPEfe
iA835+9dVAzT0Eidg7cREepnrHu62DUtF/+5DMjEKj8w9BIB4+bXt/gw8mKk/e4zyL3BFhnkbz2R
Mu89FsCCvm0BQZ0CPMpAA880i7E5RzXCUJFHzfGFrQwPMEirp3jwUnYkQqfwuZTwyo1I8hopxM28
FUXdQov/XCNtXVhcSThh6ncVhTHoDz/ZtlKfT3pRYegdPUGlGdnoQOB+h9ZwUUl9Uvts4147cg8h
1r9NiY+VBTBnCgjHonzo9txfcq1AJoGV6XLQhsON/Mo0Tz2G4CC2KoNskLV3LWD6MU3s+viXaBEj
kH/tE0SvVO9FGUWKhlBnVCCuWX6iEqsEAe6btthCEvV0QReQKZyKMp6MQfGcj8KYUBMDs64YpI3s
1lBbdb0rbB/qHPwPSP3DNhZZ1vELAfmpYOzBHw6e/KEoYch9ThRvlS4DUTXxYlEcAaDSC+J28d8w
xeYWffdw3awz2PGpaIUfrDlVZNNAKr81CGthcxKWrHCCR9WbiGNWmlqMfj87j/ZT8QX0gMrdEBGF
gQM3e/2VndvWFk7zFBfqi1ecGyPbw6UhPsFHa8omryiMgkgj4fjOxpCP8O5ejzbjFTdH1Ok7/4R9
nwgJmNCFISHT8gmv1mZ0TblQ7ZqBksNcp2bNRyZw+FNzQyVx+UH/XoV+ZdQcIDFFtyUUkB7vOl0E
WzHLG51yDBanetXv21BpS328Ero8b+zP/iO0CP4CJBiyinG+W2CPPDFuMDFSkAyU+98LlA45eRTX
1NZKz5twDVSLa7micUED7Rq9DjLq4F71NrDTAXhLRymRz+HdBYBg58JG7MTRQX9mQILQKbuzlf67
WbWoXNq9MbYuEzx9T6AnplJf+7xMCrKSST3eYi//L5I6KUGEvo4EPB4pCokc46ue5rl1juyNdWuG
cHNMtAB8SdQs+AqczSO2UXzmVXjxhSHt96zCytgeCXLV1sOTKcd8qoCZBHNOwp124KjDowk1wRBd
U1ahTubx7gdj/gWtl74gAOjrnYR9E1CVKuMDsfVsDc0Y6Nkqe+LtyPsrfgp6JLQrAQ1w3p2hX1d/
OJwNpCwsMvYBashBGFh3gI5B24R1LECd6+n46b9YHDo2hnQA+wlAdoW+T0Zn7HNBIudGeQRgW549
Z5g1FuCJ66KA1V8aUrVL/Y9kz2YtpLqvOs2fQKkZLJuEqsVmwwhZmbtXEhvBLR/4PkI6KdUEfPZX
5r6kbBpaFpSLzZItbJh5YVoiYCY51Epp43lW9QQaX2xuJpxnc32XkBrrPW8sktrxCBqU8zBJ7gy0
daazVJkT6tAERm52G4KtwpZ2ik5v6Ayh9qQ9W4LtVPethspFE37I+YY5ahExqVPuTX09oUzaZSA7
CFClZYMtWFIsw5zo7TITJ63iUe/7nGanlnGnydYvi2rDWqzvXLud/Pfjs6jH5xXoEAvZa9R6W3Pr
42W85HIt+0Qtz2RCr+CJfDMsqDlx1rsZqETOzjpEvmYgNzfCbNOySrdLFTJmp4f2QiL+lcmwW8SR
WFMPSnq0Ma+EiPTiw25TxxzBNvzoCEnpDu5rCJUbHzzHm2QlSpP+5bwqXfPygu/MAvWWHxrLMC2T
zRdAcCSJi5VNCUUqXuSnZgykwtDGm+3RZTj59h1UY8budXi4O2nk+slRJbHd0MbmlJ3IHjc+TEI+
HaH4+q7qZ+kttiwxX42C975EjST4HHwos8p1+Kk0Mrcz8lMs1VKH1i3TUA8RBLbU6H+Xb1Xsf/Sl
wIgswHUD8ybSrH+W0lBwvSM39P95aAxpUx8ETmx/fNaC55lKWUG8B4E59GD4Vb7O7ED+XiSFZzAW
J2++1D/uGVPv43s11LKNBX4gewpz9o8SVnKld5EN6cLPL8MwvTVi4qOF/lBpxhYi+Ep9Xv5TNY65
bMmdaabs7Ca81/CVKOM/PGTLIoQGvFpdXmi5sePt0d69DRNvdTuxLgbNbT3QsuAdT1XpmsdymWk9
1y258G33gBvmVRA0z1dt5b7FrOmeg/50/R8j1ZNRF4KG4si1xDaUCV85wGTqYVaDSlXlPZ4bSpVO
KoujIYRxfhJhoJkZTqDZje3kNKe6VsjcWuIDBOidG9fAss0G7elwlX1tjvTm74egaHPi+9WkJhcO
Xoe9N3XTJhzOCnmnFJTzm0buiWteZ3z/2kJrnXRjh6smnKP1CxwtmLSSWc8pNUfReltTlZHbcaFw
tPEaaoQZqssDKy0teRoXo3wOXURPrwMEu1NH9XiUVIwufXcnC+hbTEXRln4cxfSmfodLNHP1qdq3
w7G13AXepyo9zNlZNJlokN0P8a2n1XZC0W8zVbUMy6i/opMaf6Ng8sIn9LE8WQ31RkjmS//KE0P8
ZoBgXfqvF7yRtfZcKQk74qRXl83znrE+DDZwXNEhB7zvzDFdqRGjQ+EVn4Zfll/o4/+DK+X9nzKb
CliN+78UNDT3aPfxu3ilW3pRLgU4WtIes7QGJ7CNl6h81Q2Mm/4ivzK9XRVrN+ReESIYwlDu8gTf
5SV9hUyJZz71SakVLMqmXw99pA/9Y/aMrxcsDoorp/+u4WwtytrgMa8sV+VOtCwDiP1RPGFFIyTW
GZlARjN7jziRJLhMXutByZONUHQOSji0eYVdSJZXyJy1x7aDvgfSSxUoM0xPnOnvu4YsLOcAyn0N
731mCbCZBfQ2uXzmu+JijWszhs/EIoLOU91sLYw+FO+Bv9kR1E4lfHUWeH92pKv57nr6ErCFwJCv
iap2MuA+VCT5fVe6MOo4GXp9z7ccnIffdTjoXhjY9mh2NqgQ5U2xSHi1/0Ae+wtJqfHeTflh1kbi
6oQd6Lfd50X6n8huLk7ZSJqhgADj/Xve0vEr0i3eHzXkRR3vLLc1eOxKnHDrK+LTzU+dsVEPluP7
n2Jqd17uxE2kY2w3yVtaWm2QsGWv1q/I9Z8ZjaOWqgTvP6TXfnZvzYoUJJuJfuefepK+oIa6U/U4
A2UIgb2acK+Ax0Ve3KUDhUQRYty81P2f7XKg2LjBNt/xSj5ZVOCgGWrjkVNhjnng2tEA/1WDUBia
EVdUkKfq+upoOEOsxOsC2Az7nJz3T8vqQBiYn51NiSs1Q2j/UoREhdeeNh9BYWh9lQU+H/mm/dxn
GiQmBnz6/qbJqwiGXJYlQZYfFvrdT+FReUUnWGlKlLe3bNuJR9ECPnuYBwOoeJN1jh0JtBfbF+gh
AyT+a7XlkLiPJmsHeiqoqtoXFFqb2FiyGKRxsxA1itLu5dA85jX5C28EA8DwA4llm9iHE59cuZGi
C1UfGEKCryIlq6vpUsBkmZyztbrVd+817j+8CJlefgfyLQ63Qn+tk1tAn3QsX+zz0QujKFkUKEn/
66GPQbJ2umxPJbF+6Co03gKWE/BBwRM4JMJI6HTO1+8CDcYY4/xmzPkvCOF7RuMcB5kAFhmlo7Ne
5xFtmgZa2RrPOA3/9j4jgjOOHu/zDbo4Ju4uXj0CWJLxnZyh+NH8cYWRgIVtyaU1lRIXSRHdJuB4
O7GDPhjoxWXrmQ68Hke0cONqxlF+ObPMZ5THagburidTbe2MowDFBPhncOUw0xVzxYjQyrjB2eEV
5fMTX/8sRTRIKr4rEpe83hDISimSkzgQ8QfEq2vLMBaSXSW5PeaLIzd8sqLi2HJBSEYwXl6GHsOo
R9jKR57mZsYbmN6hT7ODDIkrJM1nvIQwNrFUQqX1ec7E3hG53T+m6UL8ue7wKM5wr4lOOqghkbGT
szrFvuXM/+Pi7HTaiElKumsBHedPUUreK6mWgqQPzFWQsekbCM4fbKOsB+GFIsP0/aycsvJRL+fJ
Ri2VLe4ykGn+ntqEbcK+fqnMMKmwMty8Mg+lDaE0HpcuVNOQm6+rk8HnEfKWAZ9x0FQVWsBNJjp5
h0ozeP8k0zM2rNPaEUBj7YCpYjB+/KCuaS07hKQR7XwsMcoERcZEC06PQgVuajMDeKt6ZJ03qBgD
iup0TsFoxfsKxH76PbipYhLlm97/rokXR4H7t5II1T0O9mMKGrX5ruSiI+11SqlcIG8rQHXZJn8j
s/uahBq5fnoX00FhBZEejfOLKNO0zdWaWI9bcSBzN0GqenMN0gAYR3QVP+GnVNrpha9wDkYlBuzD
wVnywItXbi3oEG+4PIRaLGHJPNmZZHsjUJyMJeUYH764LFoJ1+AMoVmxy2zYeSOIy23d3wTlgJLm
pwekZpxnue3LrU0WXISzVzi3A/lzT7p/0GvGuyGTzWje2Wvf3qLjwVeQToVNqG4yn0FpCpWJHGPL
i6RuNlhj3vuq0e5ztWfplmcF6ei81QN80oKI1sRsDB+DChCewArJMXIJ4DbA93X8v+Iv8ptPvxx+
grm6Xx0UVQW1D0kyetjvfvo7DaJ/06y5s/uyPdyspl+ng42ECMEbeBAi+ECgg/dtCD/881JweqkQ
PXZvyQaksSCd3Mk9hT/G+VBh2A2VhzHdaZ3B7P1XDf8ultrSHM3fdKLATIbo+6s05mzQBDyUkPs/
XIVeC5bEYyZMyL1byVCjclIwJ6PlTUNJHv3y7+YqMbXAAPba+/82s9tmtKVdGEcQDZpvNjX6GqXY
CNTc716/pojQksLe7IEILIS0r5AEAVdeZSU7hqBKtpzyKgAutirKX6SwkQpEnwfw4Ih74zXtTx5l
Bsx8ZbE0oblWUrF2H9R6DHxnFAbBpD8ZpgxWUFjg4vcvvSta7Lt1VDdwT/7LrpJ50j4rYyd+9Icg
83p43sJb1/5TZhHOCCWouZSz0aAcCiKPbj+i4PLuZrzhZzEldXcLxNGFRHrIGkbn0Y2K0Rj9Dr5v
ScV7PYzvvOCvV19bNyK7TtJ2doKm7nfbPpSn+mfOk2q3cHCgw2aNzci/MrJgtE9AgUZ83IGZmZK7
yggtDrMTylWlXtPomKjiqjIOmmrMjciRbL1hNiZE8n6WwbrH57rQmgHPlADcY0Y++uewCbbcKoJs
nFxkElchHl4xamRrrk0Lh+mZpWVm/LnjRG24CiRxWdko0mSTRBWw2Pqa82UdW3X2VDHB0iNnYFzc
c75f4o+G3TimO/pSsSsAnoeOEJiUBO5rgyuxj0sNE2Qgm8j/2WOpcm9hOImSWSa2T1GvIMWg3k0q
8HwaCarMtiFwvRI2bV4gRSdGFwfrC/qgGJrHAMbO10Ga1O1iDSBkHSUWhXXbHkENDImDgOfiwFH+
X7AbGM+omyqAL3zgawzYI0DBkyvjsUaacbDZ6HxiB+6x8gPXQS1vyCcADKXnRw4JvLLo65js3bAv
gX5CrZrC+snsGswznZtkty9ld4BXwOiwe590Kk87R8cK5I0g0YAd60sIpQFFuERpIrgwJJr+6l8D
a/pBQfNvbPzT5HLBweHW2l8B/HnQBsPuuQn4fdsMIaabl8SdgARibLv7wceHkk2qRtDSXO8ddCuF
+J3GTMK0MfDPtIbqbGEOYAGpfGsGmWxvGk1jOVxv5xiVZacgNWD8Cb3KFK5w087a/zpnF0kLnLzr
P76OENDivGA5RdD3vW7GB2QTO6VCnlfRzbRy2mnkGA7xyzsmcThEgM6/9PXhUMWYKW7jX7Hwy9Q+
qF5LdeY5P7Of3RIdf0RFXYomnsyl+kc90PEOA8krmNWspTxIkZ17PsRiK9FXaxT4lioy3MXZWAYV
HbEan7BBlVEJISwYXkQBF8t8qO291RPYjiIdLNkm6WxTbw/lK/vFZPNxCVbcso2Wq2XR2yAZZTHF
bL4vUwCQBBfI4rrpPOeDBAcAQiviLRjfjy6zefQ34mPtargJPm3ae6kfXnhDs63Q7EoW6+wBjbrE
eTW0m2XKFgH0Kd8u/KxdbAhDzbWDUsb1I/2tK3G5pD1mOfyvqsGpMOvf1dlQhrjL0GXEc/W0b7Ya
Y2IXoTZUlTnRy6gUCme+/KpcWdwEVMv3YZm7ZGMthEXfAD+zxDLs/3b0+xvkBYHvxT3HLD9JlZ1i
vFsNJE1grIhbIDYOPAZZKqVo7648Hh6NCuHnSD+EOLfJl07lPwOvaFxQz9O624DREwEk76svfFhU
oOhV7JfEIHSZUS2ioKSzGIIIMyZyrG3Kyezs4XyRTiyTtoSfezbRs8XoJbhFcX904S5mJQwzUWRq
B4f69FJICo9rQGqj6i143msxYAeCuVGjfuTYAusBdg8c00CwEGHl048nI76O8aRgq6ePUMXXIYmz
NlFeQkHZAvOmzZJyOVrJpyUg6RMv17x9NGTCfLmdSQehyZiFq+DcqW6F/4rHutKuhSZHYeeuysUD
vCFKuDeZ7rSemaggfd7TKbdBFxuvoZgiJDNa6p5faWY0iOyIWBiK3NctThKZo2ZVH4djbULiQsED
U69oe8Q9hWGDq4uHOc4RJgF3UUpdO6kxuJaz/YNQyQTPurL0pNAN0n74Z2H4d6RSkbiJkMqZYS+D
W/VnrjBU9CC5ZhVcuu4wMwBAJ985vVJLJJdpW3J9+WBXW01cubBapxVk6XI0mn6O/sh/e0GR7q9M
4Ig98XYMmWHJ//yhEt3uJmjKij4Sq1xcnfB0nwfXvRXcNLAv2nr02YGVYdo3HwnOq/udBg/9RaT4
/wwCT3SdgGwMZ/q8mwIy1hHXXyzj4UmB3Rl69HLMBhwqlBanZyzuGnkyUrNO14GSIuxgwo4ds6Xi
GBndlc1pH46TRBVqgg8fi0WD67PtZbz8f+/AgZIwDTKTsa9Ub11r2rUs2PYM0xN8ddr1SFvh8Vfu
Q3NsCcEMOKS073mY8sHlXiuOcu+R4CKFyms/AwGtK9+9PQjqzpLzvwlZAUpiu+YD5iOvAg9Sndh3
Lv2qr00e3B3KoW72NYPa6OxvIdUStM/f5NpmI0Vr5+q/w41OpBL1/jTY37XiOvQY+y0BgI6sIWcQ
nlJa/J9yc2r9OQUshmMOGSVPnCpPnt2mk3Lbd7YcjDHr9i/b0lfxOIycUSnevlsrx7adOWBFHXoK
YkotOVedNEys96BY1YwDK7WvBxr4qkUrW21sH7/YTPKSHarJNWNhkrWmPKO9w0+O6b2sxWnbkpG+
gsOt+gB69MWyxT1MkK2RHUBaLIWY/C7sgMSoOwlGIl3uhGEHDP5OEU3SwZljX2DJY/IdQ0WDNUkQ
ng4r6jxpNDqOOwg5QWuZray0ilBtMdLgLeagey+23oFGuzoltGk7oa289QswjOk8VTqbhEe1n4bP
LM0Jz08GEC7vhUQqy5QoAEAze5ZMZqQePSuuIOR+vnfGEOUDlLgvMFHug2T5ejT3UlGe+o8W0IYA
ZGQnjzSwhcRqlBsit7mrs+ZKqAsiQaNSAC0fjTGyhVQwKYSyjHz/gqnWyeDbWr9Nm52p7y9Znolc
Rqbpj0iAPkw06nkVecT4osdmEdS43+/FBi2KYC7F8dETCahh439zH8rvXXQndEpCrtSV16YlCeBd
dtLvEbpg1pMS9W0H3yEiIbaR6WJyrz4bz1tY+aUcqnmO02HCOXODK5xNwGwXZx0o4Q74PLY/skJp
Fkb45lSjyUeRVUYnwz1bET82RKyHQAC3bSjjHysYQTOmsS1f3SUfU67l39fntNsE/T788EofZAPp
VojWpeR9zW6gezEv2Xu4Ltk5JZ9rwzS2wFgtuLeoj38ei4h3r2ur9QfqJHERLi0EiElK1kRQkzLS
BQpZ9QUSOhhr6IOYuhnbzeRtpRicG7FErfX2O3CxqAg0mPzLK9Ywp8os4yM2ETOTWqIR2u9BdERi
UwWAskEXE0gj1n44LR/YD1AEUYqjNaNKE/7C1iv/JXX+iijZiY5+Cu4T89tB52VijbmLKb0MyI8T
fth8SaLZkD3BNF80LsD17/PbIwvcYrJMUxRq95v5ScAtLy4O4mpVgT60A2smIm4MthKMKJuwmLyD
3wKml4zS+Oc9TKTU7xcmUPp65avjAV1/OPLO0B2cx8FJfojYEcbeJTX4Hu0/KhJuSDiAIW5+CpF8
eq/PPnP4ms0vah/CqhFMueG6Pylf1zJ6bNq8Nb5v7pl4m3Btph45PETNU0pHCsSdyfNHNwpaTWTP
i4I7GH9+jdi8LzVfdrj7xtU573FgCA8OGmo8XwD/b/VNTsN9NvmIft/Qzrbg5f4AlSeSOdM0nCD7
nnwm9f4t5EgAPB12RBh68rfj6iK44hV/qSq/OGGvUMmy/5Q/YpSpCH38cY2i7oi/CTTDqm4EeyLR
WV9rlPxuKB55rIcNMIhZlIvz3K4YOSZuXm77pATkF4nhBI2h7BEBQ0dY0BJzIjMu0a9zsNQbLQPu
psaffPyjQipAAxPjUPi70/1IgKGbo6IssnI0mrkIg7PGFS2yY9i1sJZ82R1ScCeElCB5ZPA0PlFY
0zkEhKbFSfjAxQTApewUOG6fRmr9W4CzFugE4Otx0PnpeiHbNceEClMmfYtZyUR+sWyijv7VwQlK
Xq6mA/6cQfPpVSfepBEyIPx039Ivx8SawscwO/KspWBK/0fnmsUuaW7bqmxqf603kkghZaHJKtNk
TshRSb5Cg6yTYN4E2iTKbMNrjp6n+cXNEZbyV0+zKnSPv0ytr13GGmaZtup6750sXu1YDiMCrlUi
WeMOxER3xQ2FhUBWcUcmkPFT0ZwQ17lrQXdr/pr9QTIOS79RJBj2hiTpoI6yr4iSRkVbBM8uW2tC
u6RXUwWGLvcQTiV7sC+DTaGkptso7WnHRanUF+YPM3P6WoPgvHT1zcV2LR3bwWifj8qdXHw/i4vF
+sWfBo15QrxzkGBpQPlJe58NCuGiu6nvxSq8PzaZjzFntRs4yxY3KQuV3UNGGY5+iywNhkhae/st
seZTp1n7irSLdD2RUVXYo9rCqh3jZ/k5YXAakFdhdS9J0ISbfexaOke/Qrx9iB4h8GQt6zuQMHSC
gw3qjze1ea1MZjLJp9w32A6y7MgSSHCV3tEQbP78MqoXyJASAKzZ7s7eLI40Ivlf8LFJqD2ecq8D
7+vV2I57QPJN3sS+mJFSIMdfXoG3MuDSYjwXgmDGmoh+qlsQa1n62A+Raw4G7iWZ1kztRHEqSh7X
5l4oj5r6kvfXCJue8TEj25xmStg8GlRuHZf9YFakYIwUGIrNHJtEjZUDSvBX6ULFSgR/B3ODNFML
enPQCPYL3m0OAfvxHa2VBUXQ2PxDk1bH+VATUiC44+Twtv5j8MQxaqrmvek5qscgvxA61ZZnVzfn
9o+wpKked6YrvRbqBXQyIBY3r/B2Ap/1AF6YoLrnkgazKZh3u08KDPYiuuH63QfQfrVd3C5DZuBC
6PABn5wIY8SPTDSf1zhYlXQeGwjbfe/jb3iaxLobrbbAnQRe/ZYRV2eRGelU3O40+88hL1lLIah7
ttfGKLiWZm5E89TaNqqNWuT58Fq8naOlAJkRw4IvHqiDadBzROJN+JkiMkSwDQ2bALUmBm0V7x4o
9m2RmvJHUMJDhFZId3/hxAI/7/zV3ksAbC7c3BTXeNbnAkIuV5349ZpiL2sAXdmVrlnPPZvg7hUa
/jMr46syR5yrs+7Nei24spET5equ315JndEv7jmZwlljiw76mZr1Abb5OxrvWFgPG/pGTuOm27v4
qalIljV33Uh9FP7+qYErlOydcyV+6d98LW9OxwB5aZ4DUqqYsIn5wkTMmMXblMAE/S9TEoNVnFoc
MCYMBitbV8Vls9s6U0uHke67CyxjlLISsSQugM1m6pfjxQV/heX7z3tFMAZNOqqtnx1nNardbF8Z
4jOAGceURMOMT8xIAS9r8ks19W7RlujfuBs9ZWpuW0ogJ2vQCGmDuKHExvcFfBSLsc8X3raRa2Zm
JGfp9GhJ2cpIuqM2wiyWzCVzg7h+4y7bcZu62vBeKFYIet374K83D72rE07VKiMF6f3I0ay21LRA
J6g2CK5NmS14vDuwtUHN1bSKNum6mMCpQPQM4ODHlpqHvwfgqM+WNI9p6X0q2lAmmNZANosWY6+F
DR6eTsB5Q8fypfJZXeqElvkgRE/411WvrL+LaUzrwNQWhLtP+PBBsqftbMx8SBSfWVZ0uh8n5l7S
tEGVbI8gTKp2Z1+poD4mMdmEjCNhgHjTEdP2eRSEAPAxw85vb3l6QSscHMj+TI5tmOioGJn+KCUB
HIUWCw26+smHYkA4GJUpit9knwz4peQYLbCdsAlnJWmCkoJp6emI5JFUa1CU1e7fHfNFbECv7KKW
A45xa2LhuTBukrXXX0LYPnM+VcB+VDYJh0MnTLV7a5lx0cARrA2+Q/hgaOnShVhiFtVQ1sVrBtyx
AkgDI6n0LDplrrO9gt3q9tneAAMR1E4xoPKxkfSBBILOiw5tcXxcM0hPKBI+quroS2GX+iu5tYJ9
QuPl1JJpeQ6kEKG6WfxE9gKjC+/lGwovDOpTpEuXav6A1QhTeGhJZ1djxNzutMxvUyDP6ZEqAJtC
YoQCF5d6Yv73Z3yQIe4Obj7+DuSa2xKmwBkt9OqNghE750cKiLJkoDae0Tszz2+Q3tJKs4538u5l
OrpUVn7GIPWuOCW1kgnX928+KInuczMtPalIC7IJz8hckopNujNEjQrcJ1CpOJcZfG0Le8Lrx5E3
Q5v7ox7bwSHOwi1WxLcnAz62OK+u9+3Tq1AzHNBMQyMZo0q9tBxomlcadpqnee41iDZFc4duCA9f
k9M9lgqMyj0DUv63y9Xa1p82DRltPzGM9rnQeTD37VGSPpbSD/WCTsACuCLtXPCU/CbM6tGx3FB7
YjzPGV2brGtfIFaEB08EX0CPeJWN4gIcazBP95b1+MoxI5CS0d0gECOceESJRsbljMXnV5w3Vh9n
1vZGn1jqafen4PWmBzPlMElPo8I7RYkntlq7Bo6KjDfr/xB8FFawIbU3t5CVDGNvlty4T+J+IseO
+6nGN9XFjbqmNNo5HQOXIYgVmrEKgDG92QaFubGpcLty86RbPcOtgfZ0+GBYaJ5ERLBYwqMYvhBp
BJN7pjAEhwwBnZYTasr77p+XkfKDkjK4LZYQvpGPbcnkZ8/9U6bGJNYg+uPvW0GyUtEquc06N3Do
oVhGvuc7swt+qd+IVmuVFVX1ok6tB6NMS8kr5JY/gGNP8z+vFdmkAF5bj6ppMjAgeQBk6dEz0tD2
Nb1dVnudPC47HdYApZPHYrIimA6yaiWPEs3Cd9RAHMrw95gr8uij3Oey8YUURXMiHyqpolETc75J
oT5lOIKdBEzBiy+h4rLdonBWQ3Sj0Y2lFwcgC/8EM0ZvmUQgw4QLPA2sPiwugDaIwjEv0IYIzMrG
IZ43+A3+TZdkQKLOca4Z7tDK11s7a8klYF1EL8KeqdVIPHmauX0jEWgi+/OTyytbFkHmKTeeLrz8
1S26rdzgnDB22WTQPDpzuxurdEJu3GFkNfhZidg4eQIISu81RZC+3gi0uU97hdMM3ic6GR4ooY0f
iR3Bx9idAu+1HvEq8so5uTd9R3o1XR5duC5/EO8dq/3VYc8awWOKC0Nkl93gPsolgCk1suMQHxP5
NKMhDXDaKhlFaGxUiI/JgDAZa8YTqKzWiJZ9xoBExPHKYfSnJo7eK9DC1LouNBmPmGsaZRDf6TRT
yG+W+MJxFMTQZJ76sH6jmNP4cHhmUWO1Wx0sg6oHLJwI5f/WVk9RMUgYd3eViNz7AvzLTs03tjtb
50oLrGZ1JIcJw+0e9GxeWLlQRoR+vbVySNjizPwI4turoAU5/KJDycWnDMzOzNliVKs4tsxdpBkq
To06GedgExQni4FqmOOPws9w0ksSm5E/VWE0UHpl0GF8BicekWdDSVB5F+a2M3CuAfoUiamU7WLx
i6J343wl5SXF6/2kylMTG30u0v7FrLux1FaGEqYqswAAf/7a9pQxN8WQpaar7Pi+rUcT3BvXqdqt
ZxtmBDsD0P6kP9b1BJ1esvjEVOvDLztslKKI5Pwi09zHMADNWj3gKfxT2HJ3pcgz3aZ/3qjhQWl/
mrQjQkKRJtSKVPmILL3KJi9CCPYFgrPn+L4ecMwOwOtPoeS+BJiG/h7RM7/O0WkZDrgTa9NuSJcZ
us8ProauumwJdLyv5edp07wyQZ4rQDZJwRCrAw9GVUN3rGJ1Y6/RlaQsaLh5FCRYDlL6tkVxBQ6n
K0QD4XX4smaqnB7V5tT/KDjro5FpP9NeFObx5zbse+wR8p1vvQU5/8YEExg0UgZOgoofiGJ/hn/1
D2qj1Ao72dEOExe9lUEHfQOLWnAIVtzh/TinSqShiiVXD511cyHdVc5Hzw/+ce55pzdryB5WCgWZ
Dm7vWjrKcZqk23yIADIXs2SqZpK+F4lOwX+btgZa6bafrX5OWJNt845FRvatVq/bd9u36Jsfo0YT
yFoGZyDrEM/uzl3keGygISnRcaitm7ogoWdaXcL0UpkcpGGAJcocZlxDzHjLKMyyrAd4xvm83wgr
EtxgeMmjArMWUEZrRGvFcTOehhbEX+O+BOHZWGea0d2SYk/vv9bU6RhUVSYu5cNlZ5nXcaiO5SL3
LDC8PWn3gdHKqx2qnX5C53YNhQEiCMi0V1z826X0M/NxJqSDeEkBGT20Gi0cn0dCil+x7gTZvT2X
/DuCDh1GTZ3ZBPUi2lXvF5VaOLpZD2F6FsyIjQl0YxV82mmftb7mHKAci+og1GEnhJWMfMpgyk5i
BFSVADW41HGexHVzay22AqJzLjGVe/7sZNv8VMzWenT/M4OwwtvVTh/CzOy6lw9jpzGYXqeYkmi+
OF7HniOqMX/nTNoTr1If1WfXgbyKYhK1Uf9wT5cW2sGzUp32xil0iFuP7iL4ZOIk7Y1kMHB+Y2Nn
7UQ2MLWbRqfcSdXvgEjraAlA3glunUE7bxYjJE1/nmeRf2DOlI8HcMGt9RqfPH3/eLlmiVmOR6pk
ZzIr4EKWRUx3fYxkPNrTrOBLZXP9RLif52np/6RakjKwrCHHySotriyTqeQIrDD/Br6qdjD6QhmT
ch8J/MX8GqzKNLeqHqPYQksk6gnwq3gp2kSdG+ptj3UNH3dWxPZqaLclftOjkHFncat56g+MttIv
zoLBMpIDxRygVpStuOy5Fbu4x6EAKFY7rm+DjMxCfgq4BCbzmRbOc5KJs6dZ8rHoVv+1impb/wxq
FpGHnpCBH56GVqmYfw7Wa59IpsUBUAUp+wGje0Bbu3EUJgjKLI8Pvlzd6auCvTRA3RL2Mi8mSbyp
SRM7B6ta0ornt+DGN+AGaKlVHsYohxc3NLd50Hvrxfydqik771RhPrhjKoV51SHSDz+lFBNZCerP
TcU3S+TnghoW0dh5TbVC9MhP9r+chbKjBjErYQ0bTsyEapHa1XQCnAgnb2/XicYf4vCbBg1IYtJv
wdOC0XWGTFiWkCYE+rY8Dy5nijVizreTnuMEFoLr6Vs6FLuT9YjZS/1FgGsna7ZMCvWEGdOiOHt7
eS/zjMNUjsb4lF9iv6P3GH3KeAtK/m/UqEqBVC+DsrT/bDro/wlp7YNK/DHvFIkBJVXInhnllAEM
kgAB+pdqxjCVBTpzMopgg3u50QSgiZNsryQrZa/rPK4n7OBHfyU22l2bdGab3MdnYyc03PhsIKLw
Lpyyig2MsaKahKwi5OcoVSYG2/ZWLDyDCmOWrW/O6E7yLWJGkZSaMpQWjf+GoYuyizMVw0Vp7/GR
xYeSpNqu5VAwKtJPISWcsuoryOUtBgE3uZHvuqU9tSw6Xee0P8/XriaQ0c4wrnaKxWagw/FvPVkV
R6wvByDcAFpp7l2PnHET0p0hIKGOlBkKzbVEX3+ARUK13ViTK/enek7QAGejRfPxIm+WFYrcvkw0
KBQIOKpxrVDccZAZSeBG2fKJLovfPTr6PYwRDN/DVRtscU/coIe70zv3C2BSQ6bwUztH2Y1Mf1hI
L8aAO9jCfX5DnPnyejf4sXzH4Tek0jijCGi7S0MW1rMVvBmaBg547STZ3qoY17+SDqdMypvnT7Ry
jYNJZYjILQfNDRFhlRWomlEYfkciLUEo7wluwP25bvGUWcJlnQUqyxMHHqZ2+s7nyGuBPJU6EZXE
rKwVPY+SrBlR1AFyDf1Ca/d78IJCBh6gVZiHi/XAznml5h+WX2MsTk4K3oEY5uYbrOgMuKPlOhKB
DNGkZRWKQMklG2F4vtNYq1f3XoGbzVWEu4sfoo8wCz4qjf8ps5gxFQBWnoHSg/DYBP0ovUTbvL9P
YEoy50Ha39TbTGWFYOIMvVKZGheGEzA2aB/l+c180XYFS+TLX188COtSy6zTARtZ66VAD/9ETXXR
uZH6MC4r8AE+db7MQBFsa1C/h+UK1vl1GHw3Vqd1Hp8QidTe27QIUzUadScdS5WlnJx3lVHn1U6Q
XoicXatecd0s+7QCgu0h9krDAkfE2FtvsedrnMv1O2fOLPZmofAVnu52YxLeqiuBidv0MW84+1hL
/1r9F2R4FfdCiiAwbjfgNkFP7n3oOiKTps9LR9/RzIxndBr5UgbmIXjUsch/lp3R8AugBjB4zbZz
kpH7MHCxlzt2bE7CdlJ4ycdVeNqFr2JCfHy9HChHL1fKNPSmY4XnZ6hh8mNW6UNlTOaZJxvSDUVx
XTtAHGkiylXVUh7aggpZSacWCHHs4Bz6P1l0f81Vf5q1viOZrdKbVAlQSDyXsIAG+3mVVWcbn0oo
n/mC5wEQjiW+qow/Y3qmzsma3W0H7op+VGxhUPLrpoX1CfGZ6d/Yqjy4/z5ZFS8SL8Reyi98CPht
ThzJJAO17TumidaftQUWobxeElnJPJU5byLQ818QAC1ktypfRBpFQQMCJFTe3fuajUG6zzbMUl1I
k0BchGGSSYYXLotV21MsjwvaIo1zrP6esKYabbOLdmo4wCFHpm0d6RbJPefo/OrDspCJFwtWs0Kk
rNtdX1B1MHil+XCI/HK2MMus+0LqXAOsoQ9YMe5kGwou+5dyTl0Hi5ZLZd9is0mRfCkUy2JhaPP6
rgSksg13nRaMnBd/ql60rmGbDBqRDZrL+zPJ++ZMQIdTryY7wRSGdGn0jOS/aVynRM27zqsyejkl
4s0CjQEFoULbf3SAa9nHs+iYh3Lb1aLYPf1HoadItxUz5g63LQtbhBed0yegj9CAVGKK6w9JSlA1
/+ft/ecVHLaru8neXshLJ7qzMO6r6aFoWEHruXObtCkzFCYO69/5iKOo8HQCwL3shyt/0OLhRGJ5
fMnpRKPpL5k7KieXLj+F67KGc9Xtvg3T0HuD1sAbNc7+ay1CyuJqhBC1JkJC/Bq96hY2kXnmgoMY
jwNi8WS5/5zK7bytAffXT6TkWXl6wWiPkhE2m9JSPc+VoXzx7FsdWxGRgHN/fbZTt8HU8rNRort9
7BYyUHOYBgGMLLxqCJVIHoFkLg04ZRZuLj6zbT7nslr1RwcY6vl1PdnGuBTTpltbO4jzAuNtKTGn
XlXCaKEPADdb4mMdKen8BIuwcZbRxclcAo8Tnkbq+y3qvtkJlxTCOP05kZepcJlWeWTdMTVutH0E
sJfSiK/gR/DmT52jOeopbExUOOw1SgTSiIkcDns/ptc0HwvDmRwzLq/6ZbON0nth5ynypmJ2A1GY
SH/wo4xSCBHPLFh/MiUcc6Mktk1PLg4da67sUv7zBhimz1siv067/zf0MSQbs8NhjwPkTJ/BgNhT
64RBdEHMjJRClD976ekCHQGpPX9b8Tb7uHrOAkVKBE8b3gQkX6xyjUMZcWFN8ueAC1Jg1Xu402mG
qqLkHF1j8HEhluW2u7ENrYYE22/B3yu1YiYmknnR3nGM0c3qk5vVvgGf5o34zr/zEQVgRdeM8Hhl
EDhzUob+tCAiWhYojvhmQ3UXxmqLAmgO2b2gOklFe/WJy0fIMfdzz+kjzQKlb9g1MKZtzHCkC1hz
JDVoEGpbfgmUFS3EtLDPwPXBvPs39qThGMaQ4lF+cpb0n7SB5y8MV0PHuivaqY4nn1hmH10d6pY6
aFLnEt6xaGBsYbYpC9iOZiovV7Sr+Md7wO+wOhzaKsm4QYE+p3rlcy+jMtrltvYF1iI8pXWsEe2D
DcUxASoOvffOlcB9U/670LyJiyFboyKgH1kaP1UnBaCG5JjCe/ckv6oLWXSWfVBBegMNp2qDWwsb
2DlQFrUSNha9L9WP5gYfOWzm6PPy3dpFRzQaFyUN5wUPDGiQ0dVwQYfvML/nBiCnl2DE0zKXRnUJ
7fEhzmTOtwdjOL5RQOLv7lS6un1Y/qrjcmvjwjKE0QtM0ivYWP5eqf9wibcU2I9Y4eEL+rb70rco
v0Fig6smAnC57uBNy6nWJqhJPTFveNRfjSsxlezIn9HDslwhwi4Z+irMS457S/U4WEy547IsDrxR
ZiqTpvGO7FfrjnXXuvVzuOT4g7GwWeTXToK9SaOyNrEk572UM1EvLE5qs5tYJMpj8QA0pRyhJH5q
cJi6tELv3RpxTwig/ilXonRTebPP5k3y+SaZig24uszpQAlto9v7/UvkAnTt24tdjl8TzqwzDlIm
XtpvgceaT16+XwDFKyl+T3NS6Fz+ZGrO79oJjTqgkkCdaVu0dw2hMzZLIVxcQEM8gFYv7rd9apWR
3QYC9bxAq4pA0BH33DCQyPej0XWoKOiVgqSFoiVj+KOpZtCU5Fj46FPdBjd3SPkZNwZ+pMjf1dwy
yGOhuSceQkOw5IfXdc52Xlh14mk7jP5uuMnZDgwy4RdI0/I7S9oPWX1fb4mDm10Gp9GF1pzMCd43
NT8lPXS0TKmJcmwmdoyHkRMLm4Qn6b4hoZ3y9qGtFI+uAw5mUg60Rbv5ir/wPHjuHfqafyjRj/6u
cYuCFS/ux7DJk4F1JlSpzcMcl8yFA5zdt/2RY2fe540lRySOCBcOzt7H8zmWthmdZTaVX2K3m4F4
34ujhFtnwt7yRibBEZ3KxwClxkQxyzsB1vHHRAfzCtAFJ/3aajJBwnSiCBYwc8g7ELHCJ4IHLxeR
7CMKFrmBdj8SvR52jbV1BxlLyXYm8fONeDrNKaWVDTj4fZh6O2/p/B/FubdsJBmYERLGnFFuPD2M
QUNGJYsfhu0T3CWN0Vqt5R7rcXeQug5culNH532QznS0jOVFCYzNaBjcCnCs7KbdBttvrtfnD4RS
Qgqf+aQE0VgaapxaJO/G+LaYQ2dJqaCsf+9wsJGfYfwCcq9BTZ+yXyB8IIfcCczUeek3muHfmdsM
ZjvS3/KFvTFLnJHfZfHs85B0BgUgysMGLMUcd6LRabD6+RbBa3fBT7MjL968wM7GYbAaieCdVLld
9BCKXr+DB3ic1jscsts0NVQq+DUWnsGvotOptuVzOGOowRwDRMErzQgjkPnNtp70NoY2RMgZQ6u7
7qofjnCj9dS4UF3Fm/34hOT008juS/NBV36liA5aascEBTVrF9vt13ViCGNtsMI2IllxmzvOZ4FH
BQgy/G/9MOn9aT7DRY2wKsafCNtLEpeyqjM3k2H/iL+IL+sOrzq19YlZLxIbdTvUE9ofl3vbpMkh
mdCZOXMzTE7SGhRa92JL1l3389ZsWhQBDfyugj9mQttuYPg2nbyfcTgh+4wv7gUU8v2x1iNxfzrC
nB0L52yJoULLgbuMMhW+9GUQcoR6D9L2zyzyyXjYeKOASZnpu2WJi8IdI8gPWfCN/FIkjsMY9poC
8TCPSafJKtcW5mq4pGamZdRI++dJlTO9aZ3RqrRgNs3lrSsSf62waZ68qQb4eLgcHJyYFqBgfVqi
PTIxuyEvdGbnUnFxkhDzoOm/x70ewSNos0Z78a9zj86EuElbJYgLfakGPUQvjihmPGZuPEINWX7B
oY++Fu7Hp3bsON0M/K3FCy71vIDSWqutdnEolVTbyHAycf0cb13u8BbH3aBd0W8erLjxzXLXptsE
fsUEdYt75UbsoyJPXnXnyH+2Eh/beJaZXKhs+A5JX7W0IV0lwAuNaEYMxLNRT07LRX+E2YJlntH8
dXQonCzmA8bMKuH9RzWDvT1MHQddKnwNqYFKVdmtAh7IhZsV3vzYX5UtwYGWxxWxOkFp8tfYXn7C
ygrjXTAnxkcM5+P1ZC3X4F4i1D1JtS+703r9EFod+I6C5J8AKX4W1EXgzIEBAZ1x2Mp5HhOQet6+
q8O5roy8N2n2giBivWKotK6SC+fsNnxRVcFephDxHQPMD28Z2Fs7qjYvMseMI7kHaIib5k+Nj5yS
/Djx0JsFvVksemcshIPgteofi1HfeZ/QDpM65evJBjFAoddDHEpAehqgwQj0nmjQWbmugrqliLk7
1VGCys+1YhcGmcu1p8qCnoTCM0nQn2wQw6sswZSHJQ6Rs54qoCopL3a3SOwMYexWMfsv4eAnQiWP
kgqnD2MVC/V81naaCo6AJVwyuU7jaCUwipcup7MWpcdBaHvkMLTcY/C/lb2YQM+dPZh/41aOi6Vw
NVJIJWtpGFGjbAZDayHr13+WktsUtgzY/l8kdqAlCsoGiLC+b9evCAg5XAeTjwFkWRC84/wHDzFN
OgOl+jJrYDcgxnBTS9/5+7fMArFS3YxvF6o9Xb2cktTym1f2jkVLjboZK7I2+hW0xxpnyrbxUF1Y
cCHmHdwFSDtPrwI7n2GUTpVotlgIlCne+VZ+gk1xRP0FvTUqHqJ3k3lzMHdkWyNnEDLyioKV6Dns
m4zxVcEYYPNdjs92W3rgGpGd6slG9syo0hRY+IvaWD3BXfR/TDI+TLyMRxP0Nu59A0oBlR923O/b
VCoyaDk87AHYiSbPcjiz/3dN+SDUMQIxNFvNDVoIppEzaOVpVS+IScvnuZBi3ZKgleUB9N9i9xm7
dcmGAGpz/yyu0V7Wd2jPtVMTLExfK+uDI2ydx19+aFDZjYbebRDsgccbyliJO/zVM97a5ePIkFH1
IZ0gk4AqkYXIKXGDjmMon1wjpuI7gSIscETxtfEEdzrHL0Ro8R1nRzcZUtkI7IJhuNFK66ZTj0zd
7m210E+oS/eJm6fEOmyyUvayBQgQonJ7dEz6pEDBxJa4O9fQis0e9zV4dQ19OBIwuSZ3AQiA/r2N
mwmWv6/9PEE4ZIyUlwIoK7KcpWtfafvONSRydikWyBnz5aLJPuiCwA/z4bWLeOGxbKeVCxdqrkjG
UpxuKiZCr4BgFN6+JxMlsBavJIoV15CMuPZS5Mg8zqcjN2vxMo+exVH8TPgzV0Tj0ML7qMCvylvi
lUObHbmhHTMvpwN2CSIvRTYsIhHJZJeXpjS6zUEg/JOovNNPQyqah/uoJy1nftfduXgSQyNQY60C
F87pVxBCnwBtvTLRDjEPp1RQlxxvBnLEmfN7lihAv708wKEXF3sfSI6OC+4gdfXdqGc19VvhzqRa
c2oTc91rx1qeCIl3TLY66IgWzpslxprl1hTDuFI8cSGfcco86X51k8JrOO5YEgK6WelbuVkEemPz
SQu4wOuTNl3dvYVCe2ZUj3UKMZg7ecRu5Lnvyi1C8i5VUTzrx658zNJbJz2NzpSNTKIgT9HCpqIf
mUpOGIxfY8u1GdPfj0Bj3+R2cN0sHztcquuLPnxjreX17qmjMKcNiEziMijvEzClaaFNxtq8YS8k
UZ/4ECexaADy/YrYMQjk6l10I8WYIQx073iBYy3a62JFd6TZJCS3kJ/FO8HAU1rqUOy20OrusYdI
FnD66pRXZqjIHLNjCQBAFew5N2z4DEBFTiTNhtWjJb7cPCFMlKFd8PPYdEuUeneyWdaGSiYlGYTr
rXx/HHKQpQ1CuR92YzkVWaz0ZgiiQCzTQoi8xRbu39h7mGF3ltzn5MwgDEEREYw5OPidFgEAkoZL
2/ItQpT7ZykxlRufap1S/hryPnh98I+/+BHkFccfBUCJGQy08L0JXybb1m9Vk1+1i+o7semHsYBm
nmCoQdQQRxnafJXCxR1t0YEVkiuQ6tW1VRwD7ECeZpjMi2qiUuXUhlaoDaDwyjW/vXY5D3OgHS/I
n1PPYmdxs4SaFTW3DjXMedNmdhQ0yYt3WXaecK0BStuVYBQMAYu0dWnsRjpop4Zmw0h5uchLHT8s
QYlzxpVXSbQTJai5PEcGaXHzLf82oTZgUOME9wJ8o3QsCgYd4UwgmSp/gfa43xnRMR2RiGTqijMo
aEwPCziAvN1pbIYT27xcCZmYmFUInrtWbWwq4il39Vz+MrBuh9tvtTPhFuRbi4WmaGIbX1iZyRVC
NU5ItXeBPVrOci7gmgzNggrMl93bi5qIJfnnEZ8luy3DupFwFn+i6e2wB0Ibhc4pcl1XwpNJ21rK
7BJHC0mCbccUQOlLy9Yhu5fqWdrYyrL8uRGUVuspzqszmykY7SFVTNFkqYzhVAii0xs+zlmGs3Jn
1W1IcZ+Qi7Mf/bvBsCTc4Yda6MKo7RCEDz48Y+Dy2tOVJTTWZ4ZIcK84ejnQg71d+Xmv1F933UFE
8B22i+JossPjY1PM7L/lj1Yp9Sosb6Zap23d2JU1sc3vNupoAZ5lgyzhlYlc6AXSfFFK2TkwFqUU
63GPk9yL3leJ7hJVCiRj+8Qjb5NV4jGlcZ48fFSQdo7pG3Dd9g1Z1Ydsemh/tfVM7ZUUxuQVwo9k
qMf3pDnJ2vNvKEAe4k04MI4+3lHK4xDDsM5AEdhNJGOiTNxXfwZywnYcLZpkkdOlVqACI/5m+dri
LgUJ6ylJJTn/o1soubtkA6+kfvWbKLjd3czbLJeIGlo9TbBrpm99VIfavAVPKJDUrtSdCC6W5MHK
Pjf5d6SCubO4PFlXQI1EqShR48YEjFI0YIWXpzCXbbTXJIJXNdjeZvYrzhEKBxCe5zDj6jpUMecr
D/D+7X0ZyfCeVmQe/ZNjyq+x+CKnOA30Mhf97ykuiGf42QN+IUci/HBr+ZS8q4Q2NT+Yo9lkch2d
et2e6QucbpDtBSjyECZVVbOqUlp7LWpWGgC3E785kY15CL86xh1zDwGiMlNd271cCSTcEG1WguT2
s7p93SJVbfWcD8VNAZQpVagPkI1TemH6Cu9zXtY1Y28hb4xUiMkZ8RJZ1KKXmMkd5K2KP4wMKADe
l/wsXMZc6Q5tMyTzPDNAAMCDl94Q4FrfUYEM+2EPB8swMKFZMRPoKD0554WbSuyy4eDCIYQoZ05N
1Txja3wJrqX2slpeiwLgunwNJAb0jtSjGHV9Q7T12h9Xj8/c6ULAkPy7VzZ8OZ20SoiJCLi24vMJ
M9m92UF80msdD5uxiVRA+KHXBBbvA4vVD8yOMwklIS1lqbFLUS7rafewHzQi5tnUoIPg5VAgWZU1
HLR0jP1CXdsXl3MWGWEYRJIpIv1AFxLySpIPBgAmfLtqKWFjepXRSIXzWJXTJ7L2RyRnBRQ5+FEw
KHCCdiaQ4ETwJvFQG0ggo4u4OCOCKL8GIE6EKo+yl6HSV+FmuI1pXY9YivmC9XLA9ZDJuyRiMz5V
CD6HWTQZEzo3LVeW29uX+U8PNXmK6DBR2qW2WJ7iFrEBSGZE6KJZ7wWPQeLcjg9BZoDOolZmVI+q
7VaKoxAFOeLSXoLE7QAGjYNf40/kVR6o4JuR4+sXDfZASweP42QCM3t7byA/bFozAm1arEVuJr+y
PbncFJWvBNaFz0TLS+lVi5sv90W3W7k6ZoPu4mSGb7crmpDOueaefMxsBcyFt/WDIXF/IO+/6Aky
RpghAxJngznrJWVtBlHeLS9M2g0UoNJ+H1FjKL9U78BzweDDDcoNrP7EytpdWv1LqBCSUzwacQpA
GFS6u1UitPDxGQ+f+uCLertDRSzNmLKPL8CFQ8WaeDsYjxn/Rmau4efQ6olEDwuZw06/+72gjWq7
aaMWrLBLTazjFLDcW51CreCFwNqMI34tab0Rfa2HjkAT0OVn/tm2jSluDggu31m7McVbplS4zeNI
0KqKjrDiora2CWyKLbK7imAXC+CL2XDjOawmyjtOC8CoSTHYM64h5HUnl/+qwZqSOVH7rXg1UcIj
qxEoYAhLsuCbNf7EuaDf3Vi0iuB4mIdvn3FfD7wITgx0mIZ+CNGUONUL0/Ti1IvaNFuUS+uJvMyk
RLoY8WtrkAI9O+dEAplNw1rqYDHnx3kIsKledanpKoBA6ylJsbcjIRvdcRK9E5zVX7Llie+kmTqJ
sLgTfrwdXzyxb0DU3Bc1ipPwxj6UzHPA1sDb4qHfrK8GgE/6dmFOtmEKg6l4l78J1nRBuhpYryy9
1GIziPUrUEQG/yEaK+D3hm7zCsnqEWmEeF9x8W4ZP7pR3w3d0qygxh1XaY9cUhhIDZXoILT/wIfO
yOSYc15evc/dyK6ABX+0ZdBl+EIKUQf4rqBcmNAD0I05YzN7Mg12g6bnoKRgoznWeLQfLjpVuST3
9Hosm+fvSrSyK6hmUflR0Ud06FpmDIaV1lXNVjcksmARDumLYav9ONfKa9crB/0cYcnEZgibmykR
vg1iUhatZx/l3eznsObBmjW7oqUiaTVq7Qvzh1KJEaexgV7cHqq3V9Gf45vCydf7BqJ/wkydDWE9
laIY3rVi4Yhj9kuukTCAM4Gw3WD7pBnMvc5y5gGxeOj2XshRm4FZ5ytOWzbUCfJP6OUFzKLkarzQ
r8PwuAxNKEypS6b1Ytxywc3VTpfyVIoGHhIdKMJxCGyaTiGrqlaj3Go5WlvAtySTItPw3XOKrbUo
8ZqwBg0tG2NS7OFDJ6SHbFM2RT/4M9POY9i3GTxLbNo2KX0L7IMr059n5QlXb8hnRqs3ahYiVBwX
j/1XWBmn3l3eIww3NC/FH0npeZ5B0MbEp56zjxtSe97VWqbTwviSTm8IeUX9Ppfd2BPtmBzKrzbo
CTFak7V8OuGi4YbEYKL9mwgjclMbfczzna+hyRZsLC4WeLu8kjhD5dswsMUPwAWc6l1zk/3jxZbu
xlI2Cqet2FQ9Ts8T3lloZVGNW8kaSOxxTYliLQe5F1BQ+JaZO1UacZfzQA/Kuc9QBn2wmNRcOjKZ
sCYPvDMVxSk3hK4kqtzjwgqW8qGLYisD23keRJ7uhhDyyPXp6HQS1raZkTVHXZ3FevctYcaoZka/
UgPSlNTQKbLmKtUbJrZbkczMhSWPocKnyrsp/dWTRMjXJXG2BZoLJDxcmkCSVOxwCYcvfUAvzgqW
p7ZoMElI5cxpBoBeyUl96jBg7SSniPsg6/yL1U0VgmqJtwfufuUmrpn18HWyGRDKmDIJLGq0Q8KM
ahiNcx2TI2s7M7RTKNlqKuCXRWc9scNoPgNobIrfcHeoZSp0buypZtx6ZCRPw/sTt3iz9JssPJeN
GccKGFn2B1PPH+/wMvnvbs4GFSjNiiqtWDhycS5ujFS8cSVL8TpWNNr3rc3Zilkk3+pqnRYMMs8I
cDKG/mx1fd41wWDY98d8Sen8zl4UXFZsKQQpz5AJcwZLrYV2q8VNicqWm5LfV1oSPuE40MyVrmt8
Xuz7mYMgDzZt6KuHc4JJ4r56wTxRI5s5v5xoS4yNgjJU/Tbged3iRHfW5uurZCCMeupzJ72pGMEG
Sdu7NhnmHo5sRjKIDiBKw1h2cq17Pval75DyHA6KFTtZ13vV4VnUM9Fv1NsGZDrV2cCRcJn523Ju
6KjjI4h2WJc4sNzr7W+7Y0dpmMkVnQVsFmf3+noenl029AMC25MoYgvj7rlZkJyYG/AEeJR3HNmG
lefBjrWlnCJqN7P6uMrKhQ9ivj/XcyEWX0h0w4QrQo/ZjoazGVmqqhmBt54D1kfWHbFzqo5O7rjp
ZlqYKc8qvWpoBIYGEwKiI/iRo7pDNNRdSI5IwSAuTVHUKyB5Gi+2ztqT5mc0wOEurlpEOkCUjqrP
uncYWePEgedPc6JD6qjugkR801aq2T15Gi/gUXV3c17llojav8TieQNwbKAaOblJMHE3wZKakZ/b
DsfkoxbJ4YbeFDSbT2zGTqIbFsypMkd5RK/uKvWaldsXehImUVM02OQGmYNPB0CTkcpM69JvASTR
t9e4VdYGoVZf9EY0UDmfK5z/SeGwDQVFnVLLd6kxgm7Iel8JX1wWTEM+UoNoshQlIMHQzYnpY4zc
ARhgSrnh/AiQXyXb3W4t7CTFhzpV4MRrOwvbZHzw3ZW+b1Yr1slUuAX9K+5jRvr48IpZq07jAi+s
ILgN0a+oSe3X+vDHJ8h9WLrSF4OeC2j/6eDV3rxNuoDybRIL1Y4wH+vUFWnyKgCgwV92cZFks4et
k1XkUl5ucMVjwAWGGw0r09SJ7S1YXt8Zz/BtK4fxkLm2eHzePUvgYj0fHKhOMu0AhOfltR8lolW3
8HqiX4PHM98wSsl6+jy8wYlnzYv/tFCkTbJ5TziCdHVvx/ILGKqW84yLhESwdg4asBSy4cpDRRTD
MYzKjbHb6qwKH91QiWlN0WQk7NziMVi1q0fEhkCyI7RmHeVVjF1xu+iAbIEL2tKSC+bmKOVOETvG
BLtGf0y0xrZ1N6nO1HV6DJp2Z2Z+xrKphxM64uKH0lqAQjGKM2PWpUYuNkOSooYf24q6y219iQS/
3XRCtUjx8RDu0eeIh/jtWewDddjL1D3l7tU7QPolI+FajNWTZaQHDfsIXc0JYQNyEk41WiU2BQc2
EgX9ShpeWRduwM6csDDy1LS3rD61mAhoafGWrX2EJQGySfj+inNwkeuXtRDxd5B7zxhLg2DdWknx
MPHBHNJEF2BbvGrZJCbFguvhoxXWQknpPydnl25lzpQXV7zopEorgIgXr03tUkl/SGrdtQ+Uw3PS
q9yIiQ/xZSBm4+UTAPqGR+ALGzcCorzwgPLVoCA9N/X3xWpkP0MeJ/C+6B3k/UD0Y2vPScEHjlY3
qOGABNb+x0H5+LQFqcBY5qtVnyTIczgJChVagXVotMCvLz395afZy+v5SRUzac8jZP19nG7hE0Xd
c8pjHKvn7flkLx9/NAx6PiPesVJ3/r8xfgr29NWN3HwrPB3UzlfGcH6voonZohCVXCvKuzYsHonA
tbAtQVW8pM1yhNupD9bCC2HKFGH+Y9VdIAfGanaDBbXTUpvJ/7zlDm6dPied96JlsBLaBe3Z/sQh
Y+HP9nhcDLQqgZtzobC3CRivtq+jW4lRTrnKEX8rvjfBxyaMVNuFy2N6p+DWM1MnTEN0xR4SGe3m
opyv+ic0UGC/uxMb5nYxEQ6oWUnJZVOlxJQFSfKOV9ljnPA3MgrIT7CnUUbUkh/XOPHrsWcj8sBl
cN0yfyEqgV34aX4MwyASkdAj7jqp11b1YYKAjspWQlS1b0+OPa5V95hIGkBoOGBhy2kHVyAEnhaX
oVIy9jGHCbJrfEZTSxpL7UP3gWGVwMAAeV1V5UZqdwXonTdXQ9OfD6tfNbe5CsES69gi280JmJif
H3+rDJtmUNhj9BuPseEJcxMYGvCw01uATBlag08BVP0AuJhw55lYXZXqPAdTzpoD+j56f+RviKOm
RkTUrIkcCw/QqGtOlHrn+Q85VLS5gJXIn/1Nztnm/xehxND69myvWRNziq1zGBWIhfw4XhwmomUL
5PQzrKNXduUuwK6Bfrs2JGLrqBlU0sUri3Gr5pyjBBSnuK+rwCCrwkBkRZr3qbrF6oeBfaBpKN2V
6Qu9wtf10JMd2FcJl+ddsE2lr9jitVmp1GwVTx70GFqB0/o2AKnqAcfZN57NyP12uvpNOZ0uYhgv
p3JQSzM0j6lK80OGKHZVZIkgJbp43D8TuGxqK3NpygpUmQ==
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
