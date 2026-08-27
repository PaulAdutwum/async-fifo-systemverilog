`timescale 1ps/1ps

module testbench_d_flip_flop;

// 1. Declare internal signals to drive and observe the chip

logic clk; 
logic rst; 
logic d; 
logic q; 

// 2. Plug in the physical module (Device under test)

d_flip_flop dut (
    .clk(clk),
    .rst(rst),
    .d(d),
    .q(q)
);

// Generate a clock signal: that toggles every 5 nanoseconds (100 MHz) frequency
always #5 clk =  ~ clk;


// 4. Run test step by step 

initial begin
    // Tells simulator to dump all waveform signals to a file

    $dumpfile("wave.vcd");
    $dumpvars(0,testbench_d_flip_flop);

    // state 0: initialize all signals at time t = 0ns
    clk = 0;
    rst = 1;  // keep chip in reset mode
    d = 0;


    // State 1: Release reset after 12 ns 
    # 12;
    rst = 0;


    // state 2; Drive input D = 1
    #5 ;
    d = 1;

    // state 3: Drive input D = 0 
    #10; 
    d = 1;

    // State4: Drive input D = 1 
    # 10; 
    d = 1;

    #15;
    $display("---------------------------------");
    $display("TEST BENCH EXECUTED SUCCESSFULLY");
    $display("-----------------------------------");
    $finish; // end simulation

end

endmodule



