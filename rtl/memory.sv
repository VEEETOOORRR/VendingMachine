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

    always_ff @(posedge clk) begin
        if (rst) begin
            cafe  <= {2'h19, 2'h05};
            agua  <= {2'h19, 2'h05};
            suco  <= {2'h19, 2'h05};
            snack <= {2'h19, 2'h05};
        
        end else begin
            if(mem_write) begin
                case (item_t'(sel_item))
                    CAFE: begin
                        
                    end

                    AGUA: begin
                    end

                    SUCO: begin
                    end

                    SNACK: begin
                    end
                endcase
            end
        end
    
    end

    always_comb begin
    
    end


endmodule