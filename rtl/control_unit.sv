module control_unit (
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

    // SINAIS INTERMÓDULOS

    input logic change,             // Output do subtrator
    input logic can_sell,           // Output do comparador

    input logic [7:0] credit,       // Crédito guardado em credit_reg

    output logic credit_load,       // Ativa registrador de crédito
    output logic credit_op,         // Operação a ser realizada pelo registrador de crédito 

    output logic mem_read,          // Ativa leitura da memória - price e stock
    output logic mem_write,         // Ativa escrita da memória - decrementa stock

);

    import vending_pkg::*;

    state_t state;

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
                    if(coin_in == 2'b00) begin
                        state <= IDLE;
                    end
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
        credit_op = 0;
        state_out = state;
        mem_read = 0;
        dispense = 0;
        mem_write = 0;
        change_out = 0;
        error = 0;

        case (state)
            IDLE: begin
            end

            COLLECT: begin
                credit_load = 1;
                credit_op = 0;
            end

            CHECK: begin
                mem_read = 1;
            end

            DISPENSE: begin
                dispense = 1;
                mem_write = 1;
            end

            CHANGE: begin
                change_out = credit - price; // TODO implementar leitura de price
                credit_load = 1;
                credit_op = 1;
            end

            ERROR: begin
                error = 1;
            end

            default: begin // Evita latch implícito
                credit_load = 0;
                credit_op = 0;
                state_out = state;
                mem_read = 0;
                dispense = 0;
                mem_write = 0;
                change_out = 0;
                error = 0;
            end

        endcase

    end

endmodule


