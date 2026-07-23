# ============================================================
# Arquivo de Restrições (SDC) - Vending Machine
# ============================================================

# 1. Definição do Clock Principal
# Cria um clock chamado 'clk' com período de 10.0 ns (100 MHz)
# e o associa à porta física 'clk' do seu módulo.
create_clock -name clk -period 10 [get_ports clk]

# 2. Incerteza do Clock (Jitter/Skew)
# Adiciona uma margem de segurança realista para a variação do sinal de clock.
set_clock_uncertainty 0.2 [get_clocks clk]

# 3. Atrasos de Entrada e Saída (I/O Delays)
# Simula o tempo que os sinais levam para chegar até os pinos do chip 
# e o tempo necessário para o próximo circuito ler a saída.
# Aplicamos 2.0ns de atraso em todas as entradas (exceto o próprio clock).
set_input_delay 2 -clock clk [all_inputs]

# Aplicamos 2.0ns de atraso para todas as saídas.
set_output_delay 2 -clock clk [all_outputs]

# 4. Restrição de Área
# Força a ferramenta de síntese a otimizar a área do circuito ao máximo.
set_max_area 0.0

# 5. Transição Máxima
# Garante que os sinais não demorem muito para ir de 0 a 1 (evita curtos-circuitos internos).
set_max_transition 1.5 [current_design]


# Aplica uma carga de 10 fF (femtofarads) em todas as saídas
#set_load 0.010 [all_outputs]