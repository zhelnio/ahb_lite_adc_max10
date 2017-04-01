



module mfp_ahb_lite_adc_max10
(
    //ABB-Lite side
    input                              HCLK,
    input                              HRESETn,
    input      [ 31 : 0 ]              HADDR,
    input      [  2 : 0 ]              HBURST,
    input                              HMASTLOCK,  // ignored
    input      [  3 : 0 ]              HPROT,      // ignored
    input                              HSEL,
    input      [  2 : 0 ]              HSIZE,
    input      [  1 : 0 ]              HTRANS,
    input      [ 31 : 0 ]              HWDATA,
    input                              HWRITE,
    output reg [ 31 : 0 ]              HRDATA,
    output                             HREADY,
    output                             HRESP,
    input                              SI_Endian,  // ignored

    //ADC side
    output          ADC_C_Valid,    //        command.valid
    output [4:0]    ADC_C_Channel,  //               .channel
    output          ADC_C_SOP,      //               .startofpacket
    output          ADC_C_EOP,      //               .endofpacket
    input           ADC_C_Ready,    //               .ready
    input           ADC_R_Valid,    //       response.valid
    input  [4:0]    ADC_R_Channel,  //               .channel
    input  [11:0]   ADC_R_Data,     //               .data
    input           ADC_R_SOP,      //               .startofpacket
    input           ADC_R_EOP,      //               .endofpacket

    // trigger and interrupt side
    input           ADC_Trigger,
    output          ADC_Interrupt
);





endmodule


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

`define ADC_CH_1            5'd1;
`define ADC_CH_2            5'd2;
`define ADC_CH_3            5'd3;
`define ADC_CH_4            5'd4;
`define ADC_CH_5            5'd5;
`define ADC_CH_6            5'd6;
`define ADC_CH_T            5'd17;
`define ADC_CH_NONE         5'h1f;

`define ADC_CELL_1          3'h0;
`define ADC_CELL_2          3'h1;
`define ADC_CELL_3          3'h2;
`define ADC_CELL_4          3'h3;
`define ADC_CELL_5          3'h4;
`define ADC_CELL_6          3'h5;
`define ADC_CELL_T          3'h6;


module mfp_adc_max10_core
(
    // register access
    input      [ `ADC_ADDR_WIDTH - 1 : 0  ]  read_addr,
    output reg [                  31 : 0  ]  read_data,
    input      [ `ADC_ADDR_WIDTH - 1 : 0  ]  write_addr,
    input      [                  31 : 0  ]  write_data,
    input                                    write_enable,

    // Altera MAX10 ADC side
    output          ADC_C_Valid,
    output [4:0]    ADC_C_Channel,
    output          ADC_C_SOP,
    output          ADC_C_EOP,
    input           ADC_C_Ready,
    input           ADC_R_Valid,
    input  [4:0]    ADC_R_Channel,
    input  [11:0]   ADC_R_Data,
    input           ADC_R_SOP,
    input           ADC_R_EOP,

    // trigger and interrupt side
    input           ADC_Trigger,
    output          ADC_Interrupt
);

    //registers interface part
    wire    [ 31 : 0 ]  ADC [ `ADC_CH_COUNT - 1 : 0 ];  // ADC conversion results
    wire    [ 31 : 0 ]  ADMSK;                          // ADC channel mask
    wire    [ 31 : 0 ]  ADCS;                           // ADC control and status

    //register involved part
    reg     [ `ADC_DATA_WIDTH - 1 : 0 ] ADC_inv [ `ADC_CH_COUNT - 1 : 0 ];
    reg     [ `ADC_CH_COUNT   - 1 : 0 ] ADMSK_inv;

    reg     ADCS_EN;    // ADC enable
    reg     ADCS_SC;    // ADC start conversion
    reg     ADCS_TE;    // ADC auto trigger enable
    reg     ADCS_IE;    // ADC interrupt enable
    reg     ADCS_IF;    // ADC interrupt flag

    wire    ADCS_IF_new, ADCS_IE_new, ADCS_TE_new, ADCS_SC_new, ADCS_EN_new;

    //register align and combination
    assign  ADC_Interrupt = ADCS_IF;

    wire    ADMSK    = {{ 32 - `ADC_CH_COUNT   {1'b0}}, ADMSK_inv };
    wire    ADCS     = {{ 32 - 5 {1'b0}}, ADCS_IF, ADCS_IE, ADCS_TE, ADCS_SC, ADCS_EN };

    wire    ADCS_new = { ADCS_IF_new, ADCS_IE_new, ADCS_TE_new, ADCS_SC_new, ADCS_EN_new };

    generate
        genvar i;
        for(i = 0; i < `ADC_CH_COUNT; i = i + 1)
            assign ADC[i] = {{ 32 - `ADC_DATA_WIDTH {1'b0}}, ADC_inv };
    endgenerate

    wire ADMSK_new [ `ADC_CH_COUNT - 1 : 0] = write_data [ `ADC_CH_COUNT - 1 : 0];


    //register read operations
    always @ (*)
        case(read_addr)
             default        :   read_data = 32'b0;
            `ADC_REG_ADCS   :   read_data = ADCS;
            `ADC_REG_ADMSK  :   read_data = ADMSK;
            `ADC_REG_ADC1   :   read_data = ADC[`ADC_CELL_1];
            `ADC_REG_ADC2   :   read_data = ADC[`ADC_CELL_2];
            `ADC_REG_ADC3   :   read_data = ADC[`ADC_CELL_3];
            `ADC_REG_ADC4   :   read_data = ADC[`ADC_CELL_4];
            `ADC_REG_ADC5   :   read_data = ADC[`ADC_CELL_5];
            `ADC_REG_ADC6   :   read_data = ADC[`ADC_CELL_6];
            `ADC_REG_ADCT   :   read_data = ADC[`ADC_CELL_T];
        endcase

    //register write operations
    wire  [ `ADC_ADDR_WIDTH - 1 : 0 ]  __write_addr = write_enable ? write_addr : `ADC_REG_NONE;

    always @ (posedge CLK) begin
        if(~RESETn) begin
                { ADCS_IF, ADCS_IE, ADCS_TE, ADCS_SC, ADCS_EN } <= { 5 {1'd0}};
                ADMSK_inv  <= { `ADC_CH_COUNT   { 1'b0 } };
            end
        else begin
            //write command
            case(__write_addr)
                default         :   ;
                `ADC_REG_ADCS   :   ;
                `ADC_REG_ADMSK  :   ADMSK_inv <= ADMSK_new;
            endcase


            if(ADC_R_EOP & ADCS_IE)
                ADCS_IF <= 1'b1;
        end
    end

    // ADC responce data
    always @ (posedge CLK) begin
        if(~RESETn) begin
            ADC_inv[`ADC_CELL_1] <= { `ADC_DATA_WIDTH { 1'b0 } };
            ADC_inv[`ADC_CELL_2] <= { `ADC_DATA_WIDTH { 1'b0 } };
            ADC_inv[`ADC_CELL_3] <= { `ADC_DATA_WIDTH { 1'b0 } };
            ADC_inv[`ADC_CELL_4] <= { `ADC_DATA_WIDTH { 1'b0 } };
            ADC_inv[`ADC_CELL_5] <= { `ADC_DATA_WIDTH { 1'b0 } };
            ADC_inv[`ADC_CELL_6] <= { `ADC_DATA_WIDTH { 1'b0 } };
            ADC_inv[`ADC_CELL_T] <= { `ADC_DATA_WIDTH { 1'b0 } };
            end
        else
            if(ADC_R_Valid)
                case(ADC_R_Channel)
                    default   : ;
                    `ADC_CH_1 : ADC_inv[`ADC_CELL_1] <= ADC_R_Data;
                    `ADC_CH_2 : ADC_inv[`ADC_CELL_2] <= ADC_R_Data;
                    `ADC_CH_3 : ADC_inv[`ADC_CELL_3] <= ADC_R_Data;
                    `ADC_CH_4 : ADC_inv[`ADC_CELL_4] <= ADC_R_Data;
                    `ADC_CH_5 : ADC_inv[`ADC_CELL_5] <= ADC_R_Data;
                    `ADC_CH_6 : ADC_inv[`ADC_CELL_6] <= ADC_R_Data;
                    `ADC_CH_T : ADC_inv[`ADC_CELL_T] <= ADC_R_Data;
                endcase
    end

    
    //command fsm
    reg     [ 1 : 0 ]   State, Next;

    parameter   S_IDLE  = 2'b00,
                S_FIRST = 2'b01,
                S_NEXT  = 2'b10,
                S_LAST  = 2'b11;

    always @ (posedge CLK)
        if(~RESETn)
            State <= S_IDLE;
        else
            State <= Next;

    always @ (*)
        case(State)
            S_IDLE  :   Next = ADCS_EN & (ADCS_SC || (ADCS_TE & ADC_Trigger)) ? S_FIRST : S_IDLE;
            S_FIRST :   
            S_NEXT  :   
            S_LAST  :   
        endcase



endmodule


/*
module priority_mask
(
    input  [ `ADC_CH_COUNT - 1 : 0 ] mask;
    input  [                 4 : 0 ] currBit;
    output [                 4 : 0 ] nextBit;
);



endmodule
*/

