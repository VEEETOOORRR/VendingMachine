module vending_top (
    input logic clk,
    input logic rst,
    input logic confirm,
    input logic cancel,

    input logic [1:0] coin_in,
    input logic [1:0] sel_item,

    output logic dispense,
    output logic error,
    output logic [7:0] change_out,
    output logic [7:0] display,
    output logic [2:0] state_out
);

    import vending_pkg::*;


    logic       wire_credit_load;
    logic       wire_credit_op;
    logic [7:0] wire_credit;
    logic       wire_can_sell;
    logic [7:0] wire_price;
    logic [7:0] wire_change;
    logic [7:0] wire_stock;
    logic       wire_mem_read;
    logic       wire_mem_write;

    assign display = wire_credit;

    control_unit cont_u (
        .clk(clk),
        .rst(rst),
        .confirm(confirm),
        .cancel(cancel),

        .coin_in(coin_in),

        .can_sell(wire_can_sell),

        .dispense(dispense),
        .error(error),

        .state_out(state_out),

        .credit_load(wire_credit_load),
        .credit_op(wire_credit_op),
        .mem_read(wire_mem_read),
        .mem_write(wire_mem_write)
    );

    credit_reg cred_r (
        .clk(clk),
        .rst(rst),
        .cancel(cancel),
        .coin_in(coin_in),

        .credit_load(wire_credit_load),
        .credit_op(wire_credit_op),
        
        .credit(wire_credit)
    );

    comparator comp (
        .credit(wire_credit),
        .price(wire_price),
        .stock(wire_stock),
        .can_sell(wire_can_sell)
    );

    subtractor sub (
        .credit(wire_credit),
        .price(wire_price),
        .change(wire_change)
    );

    memory_vending mem (
        .clk(clk),
        .rst(rst),
        .sel_item(sel_item),
        .mem_read(wire_mem_read),
        .mem_write(wire_mem_write),
        .price(wire_price),
        .stock(wire_stock)
    );

    always_comb begin
        if (state_out == CHANGE) begin
            change_out = wire_change;
        end else begin
            change_out = 8'b0;
        end
    end

endmodule
