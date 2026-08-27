// 1 - bit D flip flop with synchronous Reset 

module d_flip_flop(
    input logic clk, // clock signal or hearbeat signal 
    input logic rst,  // Reset signal to clear memery 
    input logic d,   // Data Input 
    output logic q   // Data Output (Memory state)
);

    // Trigger only on the rising edge of the clock (0 -> 1 transition)
    always_ff @( posedge clk) begin 
        if (rst) begin
            q <= 1'b0;   // reset the ouput to 0 

        end else begin
            q <= d;   //capture the ipuut "d" and transder it to q 
        end 

        
    end

endmodule