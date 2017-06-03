
# vlib work
# 
# set p0 -vlog01compat
# set p1 +define+SIMULATION
# 
# set i0 +incdir+../../src/uart16550
# set i1 +incdir+../../src/testbench
# set i2 +incdir+../../src/
# 
# set s0 ../../src/uart16550/*.v
# set s1 ../../src/testbench/*.v
# set s2 ../../src/*.v
# 
# vlog $p0 $p1  $i0 $i1 $i2  $s0 $s1 $s2
# 
# vsim work.test_uart_transmit
# add wave -radix hex sim:/test_uart_transmit/uart/*
# run -all
# wave zoom full

vlib work

vlog     ../../src/simulation/quartus_sim_lib/altera_mf.v
vlog     ../../src/simulation/quartus_sim_lib/fiftyfivenm_atoms.v
vlog     ../../src/simulation/quartus_sim_lib/fiftyfivenm_atoms_ncrypt.v

vlog     ../../src/simulation/qsys_submodules/altera_modular_adc_control.v
vlog     ../../src/simulation/qsys_submodules/altera_modular_adc_control_avrg_fifo.v
vlog     ../../src/simulation/qsys_submodules/altera_modular_adc_control_fsm.v
vlog     ../../src/simulation/qsys_submodules/chsel_code_converter_sw_to_hw.v
vlog     ../../src/simulation/qsys_submodules/fiftyfivenm_adcblock_primitive_wrapper.v
vlog     ../../src/simulation/qsys_submodules/fiftyfivenm_adcblock_top_wrapper.v
vlog     ../../src/simulation/qsys_submodules/adc_core_modular_adc_0.v
vlog     ../../src/simulation/adc_core.v

set p0 +define+SIMULATION

set i0 +incdir+../../src/

set s0 ../../src/*.v
set s1 ../../src/simulation/testbench/*.v

vlog $p0   $i0   $s0 $s1

vsim work.test_adcTest
add wave -radix hex sim:/test_adcTest/*
add wave -radix hex sim:/test_adcTest/mfp_adc_core/*

run -all
wave zoom full



