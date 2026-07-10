# ==========================================
# Diretórios
# ==========================================
RTL_DIR = rtl
TB_DIR  = sim
REPORTS_DIR = reports
NETLIST_DIR = netlist

# ==========================================
# Arquivos
# ==========================================
RTL_FILES = $(RTL_DIR)/*.sv
TB_FILES  = $(TB_DIR)/tb_vending.sv
PKG_FILES = $(RTL_DIR)/pkg/vending_pkg.sv
# Aponta para o arquivo mapeado (sintetizado)
NETLIST_FILES = $(NETLIST_DIR)/porta_and_mapeada.sv

# Top do testbench
TOP = tb_vending

# ==========================================
# 1. Verificação de sintaxe (RTL)
# ==========================================
syntax:
	vlogan -full64 -sverilog -kdb +lint=all -timescale=1ns/1ps $(PKG_FILES) $(RTL_FILES) $(TB_FILES)

# ==========================================
# 2. Compilação / Elaboração (RTL)
# ==========================================
compile: syntax
	vcs -full64 -debug_access+all -kdb -timescale=1ns/1ps $(TOP)
    
# ==========================================
# 3. Rodar simulação (RTL)
# ==========================================
run: compile
	./simv

# ==========================================
# 4. Rodar Síntese (Nova Tarefa)
# Cria as pastas organizadas e roda o script
# ==========================================
synth:
	mkdir -p $(REPORTS_DIR) $(NETLIST_DIR)
	dc_shell -f scripts/synth.tcl | tee $(REPORTS_DIR)/synthesis.log

# ==========================================
# 5. Simulação Pós-Síntese (Nova Tarefa)
# ==========================================
# Obs: Dependendo da biblioteca, pode ser necessário incluir o arquivo Verilog das células padrão aqui no vlogan

compile_post_synth:
	vlogan -full64 -sverilog -kdb +lint=all -timescale=1ns/1ps $(NETLIST_FILES) $(TB_FILES)
	vcs -full64 -debug_access+all -kdb $(TOP)

post_synth_sim: compile_post_synth
	./simv

# ==========================================
# Abrir waveform no Verdi
# ==========================================
wave:
	verdi -ssf waves.fsdb &

# ==========================================
# Limpeza
# ==========================================
clean:
	rm -rf \
		csrc \
		simv* \
		*.daidir \
		novas* \
		AN.DB \
		ucli.key \
		verdi* \
		DVEfiles \
		.vlogan* \
		*.fsdb \
		*.log \
		*.svf \
		alib-52 \
		command.log \
		default.svf \
		$(REPORTS_DIR) \
		$(NETLIST_DIR)