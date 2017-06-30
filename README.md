# ahb_lite_adc_max10
**AHB-Lite controller for Altera MAX10 ADC**

- Small. The module core have about 250 lines of Verilog code);
- Simple. Module register interface (architecture) is very similar to Atmel ATmega88 devices ADC block;
- Supports up to 10 input pins (1 dedicated, 8 dual purpose analog input pins, 1 device temperature sensor);
- Supports ADC conversion speed up to 1 MSPS (in Free Running mode) and up to 0.33 MSPS when conversion starts by external trigger input;
- ADC Conversion End interrupt signal support;
- Checked on Terasic DE10-Lite board (Altera MAX10 10M50DAF484C7G FPGA device);
- Merged to [MIPSfpga-plus](https://github.com/MIPSfpga/mipsfpga-plus) project
