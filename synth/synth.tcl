# ============================================================
# Script de Síntese - SAED32_EDK
# Suporte a SystemVerilog (.sv)
# ============================================================

# 1. CARREGAR CONFIGURAÇÃO
source ./scripts/.synopsys_dc.setup

# 2. LEAR O ARQUIVO RTL (SYSTEMVERILOG)
analyze -format verilog ./rtl/porta_and.sv

# 3. ELABORAR O DESIGN
elaborate porta_and

# 4. LINKAR O DESIGN
link

# 5. Gerar o arquivo de netlist não mapeado (SALVANDO NA PASTA NETLIST)
write_file -format verilog -hier -out ./netlist/porta_and_nao_mapeada.sv

# 6. CARREGAR CONSTRAINTS
read_sdc scripts/constraints.sdc

# 7. SÍNTESE
puts "\n============================================================"
puts "INICIANDO SÍNTESE (SystemVerilog)..."
puts "============================================================"
compile_ultra

# 8. RELATÓRIOS PÓS-SÍNTESE (SALVANDO NA PASTA REPORTS)
puts "\n============================================================"
puts "RELATÓRIOS PÓS-SÍNTESE"
puts "============================================================"

report_area -hierarchy > ./reports/area_pos.rpt
puts "\n[Área] Relatório salvo em: ./reports/area_pos.rpt"

report_timing > ./reports/timing_relatorio.rpt
puts "[Timing] Relatório salvo em: ./reports/timing_relatorio.rpt"

report_power > ./reports/power.rpt
puts "[Power] Relatório salvo em: ./reports/power.rpt"

report_constraint -all_violators -check_type setup > ./reports/setup_violations.rpt
puts "[Setup Violations] Relatório salvo em: ./reports/setup_violations.rpt"

report_constraint -all_violators -check_type hold > ./reports/hold_violations.rpt
puts "[Hold Violations] Relatório salvo em: ./reports/hold_violations.rpt"

# 9. EXPORTAR NETLIST (SALVANDO NA PASTA NETLIST)
write -format verilog -hierarchy -output ./netlist/porta_and_mapeada.sv
puts "\n[Netlist] SystemVerilog salvo em: ./netlist/porta_and_mapeada.sv"

write -format ddc -hierarchy -output ./netlist/porta_and_mapeada.ddc
puts "[Netlist] DDC salvo em: ./netlist/porta_and_mapeada.ddc"

# 10. SALVAR DESIGN EM MEMORY
save_design -force ./netlist/porta_and.db
puts "[Design] Salvo em: ./netlist/porta_and.db"

# 11. FINALIZAR
puts "\n============================================================"
puts "SÍNTESE CONCLUÍDA COM SUCESSO (SystemVerilog)!"
puts "============================================================"