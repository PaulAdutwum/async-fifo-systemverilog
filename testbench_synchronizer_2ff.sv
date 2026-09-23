`timescale 1ps/1ps

module testbench_synchronizer_2ff;

// 1. Declare internal signals to drive and observe the chip

logic clk;
logic rst;
logic async_in;
logic sync_out;

// 2. Plug in the physical module (Device under test)

synchronizer_2ff dut (
    .clk(clk),
    .rst(rst),
    .async_in(async_in),
    .sync_out(sync_out)
);

// Generate a clock signal: that toggles every 5 nanoseconds (100 MHz) frequency
always #5 clk = ~clk;

// 4. Run test step by step

initial begin
    // Tells simulator to dump all waveform signals to a file

    $dumpfile("wave_synchronizer.vcd");
    $dumpvars(0, testbench_synchronizer_2ff);

    // state 0: initialize all signals at time t = 0ns
    clk = 0;
    rst = 1;
    async_in = 0;

    // State 1: Release reset after 12 ns
    #12;
    rst = 0;

    // state 2: flip async_in in the middle of a clock period, off the clock edge,
    // to mimic a signal arriving from a totally different clock domain
    #7;
    async_in = 1;

    // state 3: hold it high for a few cycles so we can see sync_out catch up
    #23;
    async_in = 0;

    #20;
    $display("---------------------------------");
    $display("TEST BENCH EXECUTED SUCCESSFULLY");
    $display("---------------------------------");
    $finish; // end simulation

end

endmodule
