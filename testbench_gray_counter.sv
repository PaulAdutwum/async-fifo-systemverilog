`timescale 1ps/1ps

module testbench_gray_counter;

localparam WIDTH = 4;

logic clk;
logic rst;
logic en;
logic [WIDTH-1:0] bin_out;
logic [WIDTH-1:0] gray_out;
logic [WIDTH-1:0] prev_gray;
logic [WIDTH-1:0] diff;
integer bad_transitions;

gray_counter #(.WIDTH(WIDTH)) dut (
    .clk(clk),
    .rst(rst),
    .en(en),
    .bin_out(bin_out),
    .gray_out(gray_out)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("wave_gray_counter.vcd");
    $dumpvars(0, testbench_gray_counter);

    clk = 0;
    rst = 1;
    en  = 0;
    bad_transitions = 0;

    #12;
    rst = 0;
    prev_gray = gray_out;

    // let it count for a full wrap of the counter, printing bin/gray side
    // by side and checking that gray_out only ever moves one bit at a time
    en = 1;
    repeat (16) begin
        @(posedge clk);
        #1; // let the flip-flop's non-blocking update settle before reading it
        $display("t=%0t  bin=%b  gray=%b", $time, bin_out, gray_out);

        // a value has exactly one bit set when (x & (x-1)) == 0 and x != 0.
        // that's what "only one bit changed" needs to hold here.
        diff = gray_out ^ prev_gray;
        if (diff != 0 && (diff & (diff - 1'b1)) != 0) begin
            $display("CHECK FAILED: gray_out changed more than 1 bit (prev=%b new=%b)", prev_gray, gray_out);
            bad_transitions = bad_transitions + 1;
        end
        prev_gray = gray_out;
    end

    en = 0;
    #10;

    $display("---------------------------------");
    if (bad_transitions == 0)
        $display("TEST BENCH EXECUTED SUCCESSFULLY - all transitions were single-bit");
    else
        $display("TEST BENCH FAILED - %0d multi-bit transitions found", bad_transitions);
    $display("---------------------------------");
    $finish;
end

endmodule
