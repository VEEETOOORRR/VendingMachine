module credit_reg(
    input logic rst,

    input logic credit_load,    // Sinal que aciona o registrador
    input logic op,             // Determina se é pra acumular ou zerar

    input logic [7:0] coin_in, // Moeda que tá entrando

    output logic [7:0] credit // Valor acumulado

);

    // credit_load = 1 e FSM em COLLECT (op = 0): credit = credit + coin_value
    // credit_load = 1 e FSM em CHANGE (op = 1): credit = 0;


    logic [7:0] registrador_credito;

    always_ff @(posedge credit_load or posedge rst) begin
        if(rst) begin
            registrador_credito <= 8'b0;
        end else begin
            if (!op) registrador_credito <= registrador_credito + coin_in;
            else if (op) registrador_credito <= 8'b0;
        end
    
    end

endmodule