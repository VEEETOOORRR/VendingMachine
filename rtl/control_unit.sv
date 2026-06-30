module control_unit (
    input logic clk,
    input logic rst,
    input logic confirm,
    input logic cancel,

    input logic [1:0] coin_in,
    input logic [1:0] sel_item,

    input logic can_sell,

    output logic dispense,
    output logic change_out,
    output logic error,

    output logic [7:0] display,
    output logic [2:0] state_out

    // SINAIS INTERMÓDULOS

    input logic subtracao,          // Output do subtrator

    output logic credit_load,       // Ativa acumulador
    output logic mem_read,          // Ativa leitura da memória - price e stock
    output logic mem_write,         // Ativa escrita da memória - decrementa stock

);

    import vending_pkg::*;

    state_t state;

    assign state_out = state;

    logic [7:0] troco;


    always_ff @(posedge clk) begin
        if (rst || cancel) begin
            state <= IDLE;        
            troco <= 0;  
        
        end else begin
            case (state)
                IDLE: begin
                    if(coin_in != 2'b00) begin
                        state <= COLLECT; 
                    end
                    else if (confirm) begin
                        state <= CHECK;
                    end
                end

                COLLECT: begin
                    state <= IDLE;
                end

                CHECK: begin
                    if(can_sell) state <= DISPENSE;
                    else state <= ERROR;
                end

                DISPENSE: begin
                    state <= CHANGE;
                end

                CHANGE: begin
                    troco <= subtracao;
                end

                ERROR: begin
                    if (cancel) state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end

            endcase
        end
    end

    always_comb begin
        // Valores default para cada saída
        credit_load = 0;

        case (state)
            IDLE: begin
            end

            COLLECT: begin
                credit_load = 1;
            end

            CHECK: begin
            end

            DISPENSE: begin
            end

            CHANGE: begin

            end

            ERROR: begin
            end

            default: begin
                credit_load = 0;
            end

        endcase

    end

endmodule


