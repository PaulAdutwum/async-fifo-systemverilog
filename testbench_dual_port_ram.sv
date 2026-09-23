`timescale 1ps/1ps

module testbench_dual_port_ram;

localparam WIDTH = 8;
localparam DEPTH = 16;
localparam ADDR_W = $clog2(DEPTH);

logic wclk, we;
logic [ADDR_W-1:0] waddr;
logic [WIDTH-1:0]  wdata;

logic rclk, re;
logic [ADDR_W-1:0] raddr;
logic [WIDTH-1:0]  rdata;

integer errors;
integer i; // plain loop counter, wide enough that it won't wrap like raddr would

dual_port_ram #(.WIDTH(WIDTH), .DEPTH(DEPTH)) dut (
    .wclk(wclk), .we(we), .waddr(waddr), .wdata(wdata),
    .rclk(rclk), .re(re), .raddr(raddr), .rdata(rdata)
);

// write and read clocks run at genuinely different periods, on purpose -
// this is the "asynchronous" part. 4ns and 7ns don't share a nice common
// multiple, so the two sides drift relative to each other exactly like
// they would with two independent oscillators on real hardware.
always #4 wclk = ~wclk;
always #7 rclk = ~rclk;

initial begin
    $dumpfile("wave_dual_port_ram.vcd");
    $dumpvars(0, testbench_dual_port_ram);

    wclk = 0; we = 0; waddr = 0; wdata = 0;
    rclk = 0; re = 0; raddr = 0;
    errors = 0;

    // write DEPTH values in, each one just the address itself so it's easy
    // to eyeball whether a read got the right thing back
    repeat (DEPTH) begin
        @(posedge wclk);
        we    = 1;
        wdata = waddr + 8'd1; // avoid writing 0 everywhere, easier to spot in waves
        #1;
        we = 0;
        waddr = waddr + 1'b1;
    end

    // give the write side a little more time to make sure every write
    // has actually landed before we start reading
    #20;

    // now read every location back on the independent rclk domain and
    // check it against what we wrote
    for (i = 0; i < DEPTH; i = i + 1) begin
        raddr = i[ADDR_W-1:0];
        @(posedge rclk);
        re = 1;
        @(posedge rclk);
        #1;
        re = 0;
        if (rdata !== (i + 1)) begin
            $display("CHECK FAILED: addr=%0d expected=%0d got=%0d", i, i + 1, rdata);
            errors = errors + 1;
        end else begin
            $display("addr=%0d  rdata=%0d  OK", i, rdata);
        end
    end

    $display("---------------------------------");
    if (errors == 0)
        $display("TEST BENCH EXECUTED SUCCESSFULLY - all %0d locations read back correctly", DEPTH);
    else
        $display("TEST BENCH FAILED - %0d mismatches", errors);
    $display("---------------------------------");
    $finish;
end

endmodule
