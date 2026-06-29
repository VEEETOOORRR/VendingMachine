module vending_top (
    input logic clk,
    input logic rst,
    input logic confirm,
    input logic cancel,

    input logic [1:0] coin_in,
    input logic [1:0] sel_item,

    output logic dispense,
    output logic change_out,
    output logic error,
    
    output logic [7:0] display,
    output logic [2:0] state_out
);

    import vending_pkg::*;


    always_ff @(posedge clk) begin
        
    end

    always_comb begin
        
    end

endmodule