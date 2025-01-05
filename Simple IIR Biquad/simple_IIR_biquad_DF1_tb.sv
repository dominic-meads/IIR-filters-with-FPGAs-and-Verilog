`timescale 1ns / 1 ps

/* when using the testbench to read the ".txt" file with the samples, 
place the ".txt" file in the sim_1\behav\xsim directory so vivado can find it. */

module simple_IIR_biquad_DF1_tb;
  reg clk;
  reg signed [15:0] r_din;
  wire signed [15:0] dout;

  always #50 clk = ~clk;  // 10 MHz clk

  integer fid;
  integer status;
  integer sample; 
  integer i;
  integer j = 0;
  
  localparam num_samples = 1000;
  
  reg signed [15:0] r_wave_sample [0:num_samples - 1];

  simple_IIR_biquad_DF1 uut (
    .clk(clk),
    .din(r_din),
    .dout(dout)
  );
  
  initial 
    begin
      clk = 0;
      r_din = 0;
      fid = $fopen("simple_IIR_biquad_test_stimulus.txt","r");

      for (i = 0; i < num_samples; i = i + 1)
        begin
          status = $fscanf(fid,"%d\n",sample); 
          r_wave_sample[i] = 16'(sample);
        end

      $fclose(fid);

      repeat(num_samples)
        begin 
          wait (clk == 0) wait (clk == 1)
          r_din = r_wave_sample[j];
          j = j + 1;
        end
      
      #50000
      $finish;
    end

endmodule