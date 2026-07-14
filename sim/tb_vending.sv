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
    logic clear_triggers; 

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

    // 1. Geração de clock: período 10 ns
    always #25 clk = ~clk;

    // --- SISTEMA DE SEGURANÇA (WATCHDOG TIMER) ---
    // Impede o loop infinito de congelar o PC
    initial begin
        #1000000;
        $display("\n[ERRO FATAL] TIMEOUT GLOBAL ALCANCADO! FSM travou em loop. Abortando...");
        $finish;
    end

    // Captura de eventos transitórios
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            dispense_triggered <= 0;
            error_triggered    <= 0;
            captured_change    <= 0;
        end else if (clear_triggers) begin
            dispense_triggered <= 0;
            error_triggered    <= 0;
            captured_change    <= 0;
        end else begin
            if (dispense) dispense_triggered <= 1;
            if (error)    error_triggered    <= 1;
            if (state_out == CHANGE) captured_change <= change_out;
        end
    end

    // 3. Tarefa apply_coin(value) - APLICADO NA BORDA DE DESCIDA (Seguro p/ GLS)
    task apply_coin(input logic [1:0] value);
        begin
            @(negedge clk);
            coin_in <= value;
            @(negedge clk);
            coin_in <= 2'b00;
        end
    endtask

    // 4. Tarefa buy_item(item, coins[])
    task buy_item(input logic [1:0] item, input logic [1:0] coins[]);
        int timeout_cnt;
        begin
            $display("[TB] Iniciando compra de item %0d...", item);
            
            @(negedge clk);
            clear_triggers <= 1;
            sel_item <= item;
            
            @(negedge clk);
            clear_triggers <= 0;
            
            #10;
            foreach (coins[i]) begin
                apply_coin(coins[i]);
            end
            #10;
            
            // Pressiona confirm de forma segura
            @(negedge clk);
            confirm <= 1;
            @(negedge clk);
            confirm <= 0;
            
            // Aguarda conclusão (IDLE ou ERROR) COM LIMITE (Timeout)
            timeout_cnt = 0;
            while(state_out !== IDLE && state_out !== ERROR && timeout_cnt < 50) begin
                @(posedge clk);
                timeout_cnt++;
            end
            
            if (timeout_cnt >= 50) begin
                $display("[TB] ERRO: FSM nao respondeu (timeout). Estado travado em %0d", state_out);
            end else if (state_out == ERROR) begin
                $display("[TB] Compra falhou (FSM em estado ERROR).");
                @(negedge clk);
                cancel <= 1;
                @(negedge clk);
                cancel <= 0;
                
                timeout_cnt = 0;
                while(state_out !== IDLE && timeout_cnt < 50) begin
                    @(posedge clk);
                    timeout_cnt++;
                end
            end else begin
                $display("[TB] Compra concluida com sucesso.");
            end
            #10;
        end
    endtask

    // 5. Tarefa check
    task check(input logic [31:0] expected, input logic [31:0] actual, input string label);
        begin
            if (expected === actual) begin
                $display("[PASS] %s | Esperado: %0d, Obtido: %0d", label, expected, actual);
            end else begin
                $display("[FAIL] %s | Esperado: %0d, Obtido: %0d", label, expected, actual);
            end
        end
    endtask

    // =========================================================================
    // PROCEDIMENTO DE TESTE - CENÁRIOS OBRIGATÓRIOS
    // =========================================================================
    initial begin
        clk = 0;
        rst = 0;
        confirm = 0;
        cancel = 0;
        coin_in = 2'b00;
        sel_item = 2'b00;
        clear_triggers = 0;

        $display("==================================================");
        $display("Iniciando Testbench - Cenarios Obrigatorios (GLS Safe)");
        $display("==================================================");

        // Reset inicial SEGURO (negedge)
        $display("[TB] Aplicando Reset inicial...");
        @(negedge clk);
        rst <= 1;
        repeat(2) @(negedge clk);
        rst <= 0;
        @(posedge clk);
        check(IDLE, state_out, "Verificacao de Reset");

        // ---------------------------------------------------------------------
        // Cenario 1: Compra bem-sucedida com troco 
        // ---------------------------------------------------------------------
        $display("\n--- Cenario 1: Compra bem-sucedida com troco ---");
        buy_item(CAFE, '{2'b11});
        check(1, dispense_triggered, "Cenario 1: Dispense ativado (esperado 1)");
        check(0, error_triggered, "Cenario 1: Sem erros na FSM (esperado 0)");
        check(75, captured_change, "Cenario 1: Troco correto (esperado 75)");

        // ---------------------------------------------------------------------
        // Cenario 2: Credito insuficiente 
        // ---------------------------------------------------------------------
        $display("\n--- Cenario 2: Credito Insuficiente ---");
        buy_item(3, '{2'b01}); // 3 representa SNACK
        check(0, dispense_triggered, "Cenario 2: Dispense bloqueado (esperado 0)");
        check(1, error_triggered, "Cenario 2: FSM foi para ERROR (esperado 1)");

        // ---------------------------------------------------------------------
        // Cenario 3: Cancelamento 
        // ---------------------------------------------------------------------
        $display("\n--- Cenario 3: Cancelamento ---");
        @(negedge clk);
        clear_triggers <= 1;
        @(negedge clk);
        clear_triggers <= 0;
        
        apply_coin(2'b11);
        apply_coin(2'b11);
        #10;
        
        @(negedge clk);
        cancel <= 1;
        @(negedge clk);
        cancel <= 0;
        
        begin
            int timeout_cnt = 0;
            while(state_out !== IDLE && timeout_cnt < 50) begin
                @(posedge clk);
                timeout_cnt++;
            end
        end
        #10;
        check(200, captured_change, "Cenario 3: Troco devolvido (esperado 200)");

        // ---------------------------------------------------------------------
        // Cenario 4: Estoque zerado 
        // ---------------------------------------------------------------------
        $display("\n--- Cenario 4: Estoque Zerado (Cafe) ---");
        $display("[TB] Aplicando Reset para restaurar estoques (5 cafes)...");
        @(negedge clk);
        rst <= 1;
        repeat(2) @(negedge clk);
        rst <= 0;
        @(posedge clk);

        for (int i = 1; i <= 5; i++) begin
            $display(" -> Comprando cafe %0d de 5...", i);
            buy_item(CAFE, '{2'b01});
            check(1, dispense_triggered, $sformatf("Dispense Cafe %0d", i));
        end

        $display(" -> Tentando a 6a compra (estoque deve estar vazio)...");
        buy_item(CAFE, '{2'b01});
        check(0, dispense_triggered, "Cenario 4: Dispense bloqueado na 6a vez");
        check(1, error_triggered, "Cenario 4: FSM gerou Erro por falta de estoque");

        $display("\n==================================================");
        $display("Fim da Simulacao - Todos os Cenarios Concluidos!");
        $display("==================================================");
        $finish;
    end

    // Geração de waveform;
    initial begin
        $dumpfile("waves.fsdb");
        $dumpvars(0, tb_vending);
    end

    // Monitor para depuração
    always @(posedge clk) begin
        $display("[CLK %0t] state=%0d coin_in=%b display=%0d confirm=%b cancel=%b dispense=%b error=%b change_out=%0d", 
         $time, state_out, coin_in, display, confirm, cancel, dispense, error, change_out);
    end

endmodule