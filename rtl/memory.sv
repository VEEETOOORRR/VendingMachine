module memory_vending ( // TODO Adicionar interface para carregar valores distintos de price e stock 
    input logic clk,
    input logic rst,

    input logic [1:0] sel_item, // Item selecionado, serve como endereço

    input logic mem_read,
    input logic mem_write,

    output logic [7:0] price,
    output logic [7:0] stock

);
    import vending_pkg::*;

    logic [15:0] cafe, agua, suco, snack;

    always_ff @(posedge clk) begin
        if (rst) begin
            cafe  <= {8'h19, 8'h05};
            agua  <= {8'h32, 8'h05};
            suco  <= {8'h4B, 8'h03};
            snack <= {8'h64, 8'h02};
        
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

            end else if(mem_read) begin
                case (item_t'(sel_item)) 
                    CAFE: begin
                        price <= cafe[15:8];
                        stock <= cafe[7:0];
                    end

                    AGUA: begin
                        price <= agua[15:8];
                        stock <= agua[7:0];
                    end

                    SUCO: begin
                        price <= suco[15:8];
                        stock <= suco[7:0];
                    end

                    SNACK: begin
                        price <= snack[15:8];
                        stock <= snack[7:0];
                    end
                endcase
            end else begin
                price <= 8'b0;
                stock <= 8'b0;
            end
        end
    end

endmodule

