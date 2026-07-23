module control_unit (
    input logic clk,
    input logic rst,
    input logic confirm,
    input logic cancel,

    input logic [1:0] coin_in,

    output logic dispense,
    output logic error,

    output logic [2:0] state_out,

    // SINAIS INTERMÓDULOS

    input logic can_sell,           // Output do comparador

    output logic credit_load,       // Ativa registrador de crédito
    output logic credit_op,         // Operação a ser realizada pelo registrador de crédito 

    output logic mem_read,          // Ativa leitura da memória - price e stock
    output logic mem_write          // Ativa escrita da memória - decrementa stock

);

    import vending_pkg::*;

    logic op_valida_flag; // Flag para ativar memória somente se a venda se concretizar. Evita descontar do crédito ao devolver o troco quando a venda é cancelada ou quando o saldo é insuficiente.

    state_t state;

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            op_valida_flag <= 0;
        end else begin
            case (state)
                IDLE: begin
                    op_valida_flag <= 0;
                    if(coin_in != 2'b00) begin
                        state <= COLLECT; 
                    end
                end

                COLLECT: begin
                    if (cancel) begin
                        op_valida_flag <= 0;
                        state <= CHANGE;
                    end else if (confirm) begin
                        op_valida_flag <= 1;
                        state <= CHECK;
                    end 
                end

                CHECK: begin
                    if (can_sell) begin
                        op_valida_flag <= 1;
                        state <= DISPENSE;
                    end else begin
                        op_valida_flag <= 0;
                        state <= ERROR;
                    end
                end

                DISPENSE: begin
                    state <= CHANGE;
                    op_valida_flag <= 1;
                end

                CHANGE: begin
                    state <= IDLE;
                    op_valida_flag <= 0;
                end

                ERROR: begin
                    op_valida_flag <= 0;
                    if (cancel) state <= CHANGE;
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
                if(op_valida_flag) begin
                    mem_read = 1;
                end else begin
                    mem_read = 0;
                end
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
                error = 0;
            end

        endcase

    end

endmodule


