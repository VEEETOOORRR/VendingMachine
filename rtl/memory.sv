module memory_vending (
    input logic clk,
    input logic rst,

    input logic [1:0] sel_item, // Item selecionado, serve como endereço

    input logic mem_read,
    input logic mem_write,


    output logic [7:0] stock,

);
    import vending_pkg::*;

    logic [15:0] cafe, agua, suco, snack;


    initial begin
        cafe  = {2'h19, 2'h05}; // item = { 8bit (preço), 8bit (estoque)}
        agua  = {2'h32, 2'h05};
        suco  = {2'h4B, 2'h03};
        snack = {2'h64, 2'h02};
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            cafe  = {2'h19, 2'h05};
            agua  = {2'h32, 2'h05};
            suco  = {2'h4B, 2'h03};
            snack = {2'h64, 2'h02};
        
        end else begin
            if(mem_write) begin
                case (item_t'(sel_item)) // Subtrai 1 da memória. Os 4 bits LSB são estoque.
                    CAFE: begin
                        cafe <= cafe - 1;
                    end

                    AGUA: begin
                        agua <= agua - 1;
                    end

                    SUCO: begin
                        suco <= suco - 1;
                    end

                    SNACK: begin
                        snack <= snack - 1;
                    end
                endcase
            end
        end
    
    end

    always_comb begin
    
    end


endmodule