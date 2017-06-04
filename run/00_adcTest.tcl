
# Please set your path to Quartus dir before script running
set QUARTUS_INSTALL_DIR "D:/altera_lite/16.1/quartus/"

if ![file isdirectory $QUARTUS_INSTALL_DIR] {   
    echo "Quartus not found! Check run settings in .tcl script"
}

vlib work

# Quartus files that are used for ADC simulation
vlog     "$QUARTUS_INSTALL_DIR/eda/sim_lib//altera_mf.v"
vlog     "$QUARTUS_INSTALL_DIR/eda/sim_lib/fiftyfivenm_atoms.v"
vlog     "$QUARTUS_INSTALL_DIR/eda/sim_lib/mentor/fiftyfivenm_atoms_ncrypt.v"

# These files can be generated from QSYS interface of ADC core module 
# in "board/de10_lite/project/de10_lite_adc" project
# Run "board/de10_lite/make_project.bat" to create this project
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



