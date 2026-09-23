// Binary counter with a Gray-code output.
// This is what the FIFO's read and write pointers will actually be built
// from. A plain binary counter can change several bits at once when it
// increments (e.g. 0111 -> 1000 flips 4 bits), and if that value gets
// sampled mid-transition by the synchronizer in another clock domain, it
// can land on a completely wrong number, not just a slightly-off one.
// Gray code fixes that by guaranteeing only one bit ever changes per count,
// so a synchronizer catching it mid-transition still lands on either the
// old value or the new value, never garbage in between.

module gray_counter #(
    parameter WIDTH = 4
) (
    input  logic             clk,
    input  logic             rst,
    input  logic             en,        // advance the counter by one
    output logic [WIDTH-1:0] bin_out,   // plain binary count, for address math
    output logic [WIDTH-1:0] gray_out   // gray-coded count, for crossing clock domains
);

    logic [WIDTH-1:0] bin_cnt;

    always_ff @(posedge clk) begin
        if (rst) begin
            bin_cnt <= '0;
        end else if (en) begin
            bin_cnt <= bin_cnt + 1'b1;
        end
    end

    assign bin_out  = bin_cnt;
    // standard binary-to-gray conversion: keep the top bit, xor each
    // remaining bit with the one above it
    assign gray_out = (bin_cnt >> 1) ^ bin_cnt;

endmodule
