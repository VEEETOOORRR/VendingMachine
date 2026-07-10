module tb_vending;

    import vending_pkg::*;

    // Sinais do Testbench
    logic clk;
    logic rst;
    logic confirm;
    logic cancel;
    logic [1:0] coin_in;
    logic [1:0] sel_item;

    logic dispense;
    logic error;
    logic [7:0] change_out;
    logic [7:0] display;
    logic [2:0] state_out;

    // Sinais auxiliares para registrar eventos (pulso)
    logic dispense_triggered;
    logic error_triggered;
    logic [7:0] captured_change;

    // Instanciação do Vending Top
    vending_top uut (
        .clk(clk),
        .rst(rst),
        .confirm(confirm),
        .cancel(cancel),
        .coin_in(coin_in),
        .sel_item(sel_item),
        .dispense(dispense),
        .error(error),
        .change_out(change_out),
        .display(display),
        .state_out(state_out)
    );

    // 1. Geração de clock: always #5 clk = ~clk; (período 10 ns)
    always #5 clk = ~clk;

    // Captura de eventos transitórios
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            dispense_triggered <= 0;
            error_triggered    <= 0;
        end else begin
            if (dispense) dispense_triggered <= 1;
            if (error)    error_triggered    <= 1;
        end
    end

    // Captura o troco durante o estado de CHANGE
    always_comb begin
        if (state_out == CHANGE) begin
            captured_change = change_out;
        end
    end

    // 3. Tarefa apply_coin(value) que aplica uma moeda e aguarda 1 ciclo
    task apply_coin(input logic [1:0] value);
        begin
            @(posedge clk)
            coin_in <= value;
            @(posedge clk)
            coin_in <= 2'b00;
        end
    endtask

    // 4. Tarefa buy_item(item, coins[]) que executa uma compra completa
    task buy_item(input logic [1:0] item, input logic [1:0] coins[]);
        begin
            $display("[TB] Iniciando compra de item %0d...", item);
            dispense_triggered = 0;
            error_triggered = 0;
            captured_change = 0;
            sel_item = item;
            #10;
            foreach (coins[i]) begin
                apply_coin(coins[i]);
            end
            #10;
            // Pressiona confirm
            @(posedge clk)
            confirm <= 1;
            @(posedge clk)
            confirm <= 2'b0;
            
            // Aguarda conclusão (IDLE ou ERROR)
            wait(state_out == IDLE || state_out == ERROR);
            #1; // Pequena margem de tempo para propagação das saídas
            if (state_out == ERROR) begin
                $display("[TB] Compra falhou (FSM em estado ERROR).");
                @(posedge clk)
                cancel <= 1;
                @(posedge clk)
                cancel <= 0;
                wait(state_out == IDLE);
            end else begin
                $display("[TB] Compra concluída com sucesso.");
            end
            #10;
        end
    endtask

    // 5. Tarefa check(expected, actual, label) que reporta PASS/FAIL
    task check(input logic [31:0] expected, input logic [31:0] actual, input string label);
        begin
            if (expected === actual) begin
                $display("[PASS] %s | Esperado: %0d, Obtido: %0d", label, expected, actual);
            end else begin
                $display("[FAIL] %s | Esperado: %0d, Obtido: %0d", label, expected, actual);
            end
        end
    endtask

    // Procedimento de Teste
    initial begin
        // Inicializações
        clk = 0;
        rst = 0;
        confirm = 0;
        cancel = 0;
        coin_in = 2'b00;
        sel_item = 2'b00;

        $display("==================================================");
        $display("Iniciando Testbench de tb_vending");
        $display("==================================================");

        // 2. Reset inicial por 2 ciclos de clock
        $display("[TB] Aplicando Reset por 2 ciclos de clock...");
        rst = 1;
        repeat(2) @(posedge clk)
        rst = 0;
        @(posedge clk)
        check(IDLE, state_out, "Verificação de Reset");

        // Caso de teste 1: Comprar Cafe (Preço 25) com exatamente 25
        $display("\n--- Caso de Teste 1: Comprar Cafe com valor exato (25) ---");
        buy_item(CAFE, '{2'b01});
        check(1, dispense_triggered, "Dispense do Café");
        check(0, error_triggered, "Error Status do Café");
        check(0, captured_change, "Troco do Café (esperado 0)");

        // Caso de teste 2: Comprar Agua (Preço 50) com 100 (troco de 50)
        $display("\n--- Caso de Teste 2: Comprar Agua com troco (100 -> troco 50) ---");
        buy_item(AGUA, '{2'b11});
        check(1, dispense_triggered, "Dispense da Água");
        check(0, error_triggered, "Error Status da Água");
        check(50, captured_change, "Troco da Água (esperado 50)");

        // Caso de teste 3: Tentativa de compra com saldo insuficiente (Suco Preço 75, pagando 50)
        $display("\n--- Caso de Teste 3: Compra com saldo insuficiente (Suco, pagando 50) ---");
        buy_item(SUCO, '{2'b10});
        check(0, dispense_triggered, "Dispense do Suco (esperado 0)");
        check(1, error_triggered, "Error Status do Suco (esperado 1)");

        $display("==================================================");
        $display("Fim da Simulação!");
        $display("==================================================");
        $finish;
    end

    // 6. Geração de waveform;
    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, tb_vending);
    end

    // Monitor para depuração
    always @(posedge clk) begin
        $display("[CLK %0t] state=%0d coin_in=%b reg_coin_in=%b coin_val=%0d display=%0d confirm=%b cancel=%b dispense=%b error=%b change_out=%0d", 
                 $time, state_out, coin_in, uut.cred_r.reg_coin_in, uut.cred_r.coin_value, display, confirm, cancel, dispense, error, change_out);
    end

endmodule
