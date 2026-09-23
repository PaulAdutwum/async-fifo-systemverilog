// 2-stage flip-flop synchronizer
// Used to safely pass a signal from one clock domain into another without
// letting a metastable value propagate into the rest of the destination
// clock domain's logic. Built out of two of our d_flip_flop blocks chained
// back to back.

module synchronizer_2ff(
    input  logic clk,       // destination clock domain
    input  logic rst,       // synchronous reset (destination domain)
    input  logic async_in,  // signal coming from another clock domain
    output logic sync_out   // synchronized version of async_in
);

    logic stage1_q; // output of the first flip-flop, may go metastable

    // Stage 1: catches the async signal, may briefly go metastable
    d_flip_flop stage1 (
        .clk(clk),
        .rst(rst),
        .d(async_in),
        .q(stage1_q)
    );

    // Stage 2: gives stage1 a full clock period to settle before use
    d_flip_flop stage2 (
        .clk(clk),
        .rst(rst),
        .d(stage1_q),
        .q(sync_out)
    );

endmodule
