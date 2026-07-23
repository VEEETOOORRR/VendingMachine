module credit_reg(
    // SINAIS VINDOS DO TOP MODULE
    input logic clk,
    input logic rst,
    input logic cancel,
    input logic [1:0] coin_in,  // Moeda que tá entrando, registrada em reg_coin_in

    // SINAIS DA CONTROL UNIT
    input logic credit_load,    // Sinal que aciona o registrador
    input logic credit_op,      // Determina se é pra acumular ou zerar

    output logic [7:0] credit // Valor acumulado

);

    // credit_load = 1 e FSM em COLLECT (op = 0): credit = credit + coin_value
    // credit_load = 1 e FSM em CHANGE (op = 1): credit = 0;

    logic [1:0] reg_coin_in; // coin_in registrado

    logic [7:0] registrador_credito;
    logic [7:0] coin_value;

    always_ff @(posedge clk) begin
        if(rst) begin
            reg_coin_in <= 2'b0;
            registrador_credito <= 8'b0;
        end else begin

            reg_coin_in <= coin_in;

            if (credit_load) begin
                if      (!credit_op) registrador_credito <= registrador_credito + coin_value;
                else if (credit_op)  registrador_credito <= 8'b0;
            end
        end
    end

    assign credit = registrador_credito;

    always_comb begin // Circuito combinacional responsável por decifrar qual o valor da moeda que tá entrando
        case (reg_coin_in) 
            2'b00: coin_value = 0; 
            2'b01: coin_value = 25;
            2'b10: coin_value = 50;
            2'b11: coin_value = 100;
            default: coin_value = 0;
        endcase
    end

endmodule
