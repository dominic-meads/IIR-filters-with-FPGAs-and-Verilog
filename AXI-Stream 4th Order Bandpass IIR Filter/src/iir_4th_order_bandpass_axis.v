`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dominic Meads
// 
// Create Date: 11/15/2024 10:05:43 PM
// Design Name: 
// Module Name: iir_4th_order_bandpass_axis
// Project Name: 
// Target Devices: 7 Series
// Tool Versions: Vivado 2024.1
// Description: 
//      8th order Buttworth bandpass filter with coefficents generated in MATLAB from the following parameters:
//         - fs  = 500 Hz
//         - fc1 = 5 Hz
//         - fc2 = 15 Hz
//  
//      Filter consists of four DF1 sos filters cascaded together. The indivdual gain is embedded in the numerator coefficients.
//      All the coefficients in MATLAB are multiplied by 2^23 for an integer coefficent width of 25 bits (max for 
//      7 series DSP48E1).
// 
//      Compatible with AXI4 Streaming interface, but does not have fifos, so unread data from upstream device is lost. 
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//      See coefficient generation script and testing here: https://github.com/dominic-meads/ECG/blob/main/SoC/IIR_Bandpass_test/MATLAB%20scripts/Bandpass_coeff_gen.m
//      
//////////////////////////////////////////////////////////////////////////////////
module iir_4th_order_bandpass_axis #(
  parameter coeff_width  = 25,     // coefficient bit width
  parameter inout_width  = 16,     // input and output data wdth
  parameter scale_factor = 23,     // multiplying coefficients by 2^23
  
  // sos0 coeffs
  parameter sos0_b0_int_coeff = 514530,
  parameter sos0_b1_int_coeff = 0,
  parameter sos0_b2_int_coeff = -514530,
  parameter sos0_a1_int_coeff = -15932677,
  parameter sos0_a2_int_coeff = 7814858,

  // sos1 coeffs
  parameter sos1_b0_int_coeff = 514530,
  parameter sos1_b1_int_coeff = 0,
  parameter sos1_b2_int_coeff = -514530,
  parameter sos1_a1_int_coeff = -16534189,
  parameter sos1_a2_int_coeff = 8180250,

  // sos2 coeffs
  parameter sos2_b0_int_coeff = 498645,
  parameter sos2_b1_int_coeff = 0,
  parameter sos2_b2_int_coeff = -498645,
  parameter sos2_a1_int_coeff = -16019050,
  parameter sos2_a2_int_coeff = 7687568,

  // sos3 coeffs
  parameter sos3_b0_int_coeff = 498645,
  parameter sos3_b1_int_coeff = 0,
  parameter sos3_b2_int_coeff = -498645,
  parameter sos3_a1_int_coeff = -15487989,
  parameter sos3_a2_int_coeff = 7253728
)(
  input  clk,
  input  rst_n,
  input  s_axis_tvalid,
  input  m_axis_tready,
  input  signed [inout_width-1:0] s_axis_tdata,
  output signed [inout_width-1:0] m_axis_tdata,
  output m_axis_tvalid,
  output s_axis_tready
);

  // internal signals between sections
  wire signed [inout_width-1:0] sos0_to_sos1_tdata;
  wire sos0_to_sos1_tvalid;
  wire sos1_to_sos0_tready;

  wire signed [inout_width-1:0] sos1_to_sos2_tdata;
  wire sos1_to_sos2_tvalid;
  wire sos2_to_sos1_tready; 

  wire signed [inout_width-1:0] sos2_to_sos3_tdata;
  wire sos2_to_sos3_tvalid;
  wire sos3_to_sos2_tready; 

  //sos DF1 instantiations
  iir_DF1_Biquad_AXIS #(
    .coeff_width(coeff_width),
    .inout_width(inout_width),
    .scale_factor(scale_factor),
    .b0_int_coeff(sos0_b0_int_coeff),
    .b1_int_coeff(sos0_b1_int_coeff),
    .b2_int_coeff(sos0_b2_int_coeff),
    .a1_int_coeff(sos0_a1_int_coeff),
    .a2_int_coeff(sos0_a2_int_coeff)
  ) sos0 (
    .clk(clk),
    .rst_n(rst_n),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tdata(s_axis_tdata),
    .m_axis_tready(sos1_to_sos0_tready),
    .m_axis_tdata(sos0_to_sos1_tdata),
    .m_axis_tvalid(sos0_to_sos1_tvalid),
    .s_axis_tready(s_axis_tready)
  );

  iir_DF1_Biquad_AXIS #(
    .coeff_width(coeff_width),
    .inout_width(inout_width),
    .scale_factor(scale_factor),
    .b0_int_coeff(sos1_b0_int_coeff),
    .b1_int_coeff(sos1_b1_int_coeff),
    .b2_int_coeff(sos1_b2_int_coeff),
    .a1_int_coeff(sos1_a1_int_coeff),
    .a2_int_coeff(sos1_a2_int_coeff)
  ) sos1 (
    .clk(clk),
    .rst_n(rst_n),
    .s_axis_tvalid(sos0_to_sos1_tvalid),
    .s_axis_tdata(sos0_to_sos1_tdata),
    .m_axis_tready(sos2_to_sos1_tready),
    .m_axis_tdata(sos1_to_sos2_tdata),
    .m_axis_tvalid(sos1_to_sos2_tvalid),
    .s_axis_tready(sos1_to_sos0_tready)
  );

    iir_DF1_Biquad_AXIS #(
    .coeff_width(coeff_width),
    .inout_width(inout_width),
    .scale_factor(scale_factor),
    .b0_int_coeff(sos2_b0_int_coeff),
    .b1_int_coeff(sos2_b1_int_coeff),
    .b2_int_coeff(sos2_b2_int_coeff),
    .a1_int_coeff(sos2_a1_int_coeff),
    .a2_int_coeff(sos2_a2_int_coeff)
  ) sos2 (
    .clk(clk),
    .rst_n(rst_n),
    .s_axis_tvalid(sos1_to_sos2_tvalid),
    .s_axis_tdata(sos1_to_sos2_tdata),
    .m_axis_tready(sos3_to_sos2_tready),
    .m_axis_tdata(sos2_to_sos3_tdata),
    .m_axis_tvalid(sos2_to_sos3_tvalid),
    .s_axis_tready(sos2_to_sos1_tready)
  );

  iir_DF1_Biquad_AXIS #(
    .coeff_width(coeff_width),
    .inout_width(inout_width),
    .scale_factor(scale_factor),
    .b0_int_coeff(sos3_b0_int_coeff),
    .b1_int_coeff(sos3_b1_int_coeff),
    .b2_int_coeff(sos3_b2_int_coeff),
    .a1_int_coeff(sos3_a1_int_coeff),
    .a2_int_coeff(sos3_a2_int_coeff)
  ) sos3 (
    .clk(clk),
    .rst_n(rst_n),
    .s_axis_tvalid(sos2_to_sos3_tvalid),
    .s_axis_tdata(sos2_to_sos3_tdata),
    .m_axis_tready(m_axis_tready),
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .s_axis_tready(sos3_to_sos2_tready)
  );

endmodule