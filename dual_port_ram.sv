// Dual-clock, dual-port memory array.
// This is the actual storage for the FIFO: one side writes on wclk, the
// other side reads on rclk, and the two clocks don't have to have any
// relationship to each other at all. That's what makes the FIFO
// "asynchronous" - the write and read sides are genuinely independent,
// which is exactly why the pointers crossing between them need the
// gray_counter + synchronizer_2ff combination instead of being compared
// directly.

module dual_port_ram #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
) (
    // write side
    input  logic                     wclk,
    input  logic                     we,
    input  logic [$clog2(DEPTH)-1:0] waddr,
    input  logic [WIDTH-1:0]         wdata,

    // read side
    input  logic                     rclk,
    input  logic                     re,
    input  logic [$clog2(DEPTH)-1:0] raddr,
    output logic [WIDTH-1:0]         rdata
);

    logic [WIDTH-1:0] mem [0:DEPTH-1];

    always_ff @(posedge wclk) begin
        if (we) begin
            mem[waddr] <= wdata;
        end
    end

    always_ff @(posedge rclk) begin
        if (re) begin
            rdata <= mem[raddr];
        end
    end

endmodule
