



`define ADC_ADDR_WIDTH  4
`define ADC_CH_COUNT    7
`define ADC_DATA_WIDTH  12
`define ADC_CHAN_WIDTH  5

`define ADC_REG_NONE        0   // no register selected
`define ADC_REG_ADCS        1   // ADC control and status
`define ADC_REG_ADMSK       2   // ADC channel mask
`define ADC_REG_ADC1        3   // ADC channel 1 conversion results
`define ADC_REG_ADC2        4   // ADC channel 2 conversion results
`define ADC_REG_ADC3        5   // ADC channel 3 conversion results
`define ADC_REG_ADC4        6   // ADC channel 4 conversion results
`define ADC_REG_ADC5        7   // ADC channel 5 conversion results
`define ADC_REG_ADC6        8   // ADC channel 6 conversion results
`define ADC_REG_ADCT        9   // ADC temperature channel conversion results

`define ADC_CH_1            5'd1
`define ADC_CH_2            5'd2
`define ADC_CH_3            5'd3
`define ADC_CH_4            5'd4
`define ADC_CH_5            5'd5
`define ADC_CH_6            5'd6
`define ADC_CH_T            5'd17
`define ADC_CH_NONE         5'd18

`define ADC_CELL_CNT        3'h7

`define ADC_CELL_1          3'h0
`define ADC_CELL_2          3'h1
`define ADC_CELL_3          3'h2
`define ADC_CELL_4          3'h3
`define ADC_CELL_5          3'h4
`define ADC_CELL_6          3'h5
`define ADC_CELL_T          3'h6

// ADCS register bit nums
`define ADC_FIELD_ADCS_EN   0
`define ADC_FIELD_ADCS_SC   1
`define ADC_FIELD_ADCS_TE   2
`define ADC_FIELD_ADCS_IE   3
`define ADC_FIELD_ADCS_IF   4