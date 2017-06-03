
`include "mfp_adc_max10_core.vh"

module mfp_adc_max10_core
(
    input                                    CLK,
    input                                    RESETn,

    // register access
    input      [ `ADC_ADDR_WIDTH - 1 : 0  ]  read_addr,
    output reg [                  31 : 0  ]  read_data,
    input      [ `ADC_ADDR_WIDTH - 1 : 0  ]  write_addr,
    input      [                  31 : 0  ]  write_data,
    input                                    write_enable,

    // Altera MAX10 ADC side
    output              ADC_C_Valid,
    output reg [  4:0 ] ADC_C_Channel,
    output              ADC_C_SOP,
    output              ADC_C_EOP,
    input               ADC_C_Ready,
    input               ADC_R_Valid,
    input      [  4:0 ] ADC_R_Channel,
    input      [ 11:0 ] ADC_R_Data,
    input               ADC_R_SOP,
    input               ADC_R_EOP,

    // trigger and interrupt side
    input           ADC_Trigger,
    output          ADC_Interrupt
);

    // ADC conversion data
    wire [ `ADC_CH_COUNT   - 1 : 0 ] ADC_wr;
    wire [ `ADC_DATA_WIDTH - 1 : 0 ] ADC [ `ADC_CH_COUNT - 1 : 0 ];

    assign ADC_wr[`ADC_CELL_1] = ADC_R_Valid && ADC_R_Channel == `ADC_CH_1;
    assign ADC_wr[`ADC_CELL_2] = ADC_R_Valid && ADC_R_Channel == `ADC_CH_2;
    assign ADC_wr[`ADC_CELL_3] = ADC_R_Valid && ADC_R_Channel == `ADC_CH_3;
    assign ADC_wr[`ADC_CELL_4] = ADC_R_Valid && ADC_R_Channel == `ADC_CH_4;
    assign ADC_wr[`ADC_CELL_5] = ADC_R_Valid && ADC_R_Channel == `ADC_CH_5;
    assign ADC_wr[`ADC_CELL_6] = ADC_R_Valid && ADC_R_Channel == `ADC_CH_6;
    assign ADC_wr[`ADC_CELL_T] = ADC_R_Valid && ADC_R_Channel == `ADC_CH_T;

    adc_reg #(.WIDTH(`ADC_DATA_WIDTH)) r_ADC1 (CLK, RESETn, ADC_R_Data, ADC_wr[`ADC_CELL_1], ADC[`ADC_CELL_1] );
    adc_reg #(.WIDTH(`ADC_DATA_WIDTH)) r_ADC2 (CLK, RESETn, ADC_R_Data, ADC_wr[`ADC_CELL_2], ADC[`ADC_CELL_2] );
    adc_reg #(.WIDTH(`ADC_DATA_WIDTH)) r_ADC3 (CLK, RESETn, ADC_R_Data, ADC_wr[`ADC_CELL_3], ADC[`ADC_CELL_3] );
    adc_reg #(.WIDTH(`ADC_DATA_WIDTH)) r_ADC4 (CLK, RESETn, ADC_R_Data, ADC_wr[`ADC_CELL_4], ADC[`ADC_CELL_4] );
    adc_reg #(.WIDTH(`ADC_DATA_WIDTH)) r_ADC5 (CLK, RESETn, ADC_R_Data, ADC_wr[`ADC_CELL_5], ADC[`ADC_CELL_5] );
    adc_reg #(.WIDTH(`ADC_DATA_WIDTH)) r_ADC6 (CLK, RESETn, ADC_R_Data, ADC_wr[`ADC_CELL_6], ADC[`ADC_CELL_6] );
    adc_reg #(.WIDTH(`ADC_DATA_WIDTH)) r_ADCT (CLK, RESETn, ADC_R_Data, ADC_wr[`ADC_CELL_T], ADC[`ADC_CELL_T] );

    // ADC mask
    wire [`ADC_CELL_CNT - 1 : 0] ADMSK;
    wire                         ADMSK_wr = write_enable && write_addr == `ADC_REG_ADMSK;
    adc_reg #(.WIDTH(`ADC_CELL_CNT))  r_ADMSK (CLK, RESETn, write_data[`ADC_CELL_CNT - 1 : 0], ADMSK_wr, ADMSK );

    // ADCS flags
    wire    ADCS_EN;    // ADC enable
    wire    ADCS_SC;    // ADC start conversion
    wire    ADCS_TE;    // ADC trigger enable
    wire    ADCS_IE;    // ADC interrupt enable
    wire    ADCS_wr     = write_enable && write_addr == `ADC_REG_ADCS;

    adc_reg #(.WIDTH(1)) r_ADCS_EN (CLK, RESETn, write_data[`ADC_FIELD_ADCS_EN], ADCS_wr, ADCS_EN );
    adc_reg #(.WIDTH(1)) r_ADCS_SC (CLK, RESETn, write_data[`ADC_FIELD_ADCS_SC], ADCS_wr, ADCS_SC );
    adc_reg #(.WIDTH(1)) r_ADCS_TE (CLK, RESETn, write_data[`ADC_FIELD_ADCS_TE], ADCS_wr, ADCS_TE );
    adc_reg #(.WIDTH(1)) r_ADCS_IE (CLK, RESETn, write_data[`ADC_FIELD_ADCS_IE], ADCS_wr, ADCS_IE );
    

    wire    ADCS_IF;    // ADC interrupt flag
    // set ADCS.IF when conversion ends and ADCS.IE anabled
    // and reset ADCS.IF when it was writen to 1 by CPU
    wire    ADCS_IF_wr    = (ADC_R_EOP & ADCS_IE) | (ADCS_wr & write_data[`ADC_FIELD_ADCS_IF]);
    wire    ADCS_IF_new   = (ADC_R_EOP & ADCS_IE) ? 1'b1 : 1'b0;
    assign  ADC_Interrupt = ADCS_IF;

    adc_reg #(.WIDTH(1)) r_ADCS_IF (CLK, RESETn, ADCS_IF_new, ADCS_IF_wr, ADCS_IF );


    //register read operations
    wire [ 31:0 ] ADCS = 32'b0 | (ADCS_IF << `ADC_FIELD_ADCS_IF)
                               | (ADCS_IE << `ADC_FIELD_ADCS_IE)
                               | (ADCS_TE << `ADC_FIELD_ADCS_TE)
                               | (ADCS_SC << `ADC_FIELD_ADCS_SC)
                               | (ADCS_EN << `ADC_FIELD_ADCS_EN);

    always @ (*)
        case(read_addr)
             default        :   read_data = 32'b0;
            `ADC_REG_ADCS   :   read_data = ADCS;
            `ADC_REG_ADMSK  :   read_data = {{ 32 - `ADC_CH_COUNT   {1'b0}}, ADMSK };
            `ADC_REG_ADC1   :   read_data = {{ 32 - `ADC_DATA_WIDTH {1'b0}}, ADC[`ADC_CELL_1] };
            `ADC_REG_ADC2   :   read_data = {{ 32 - `ADC_DATA_WIDTH {1'b0}}, ADC[`ADC_CELL_2] };
            `ADC_REG_ADC3   :   read_data = {{ 32 - `ADC_DATA_WIDTH {1'b0}}, ADC[`ADC_CELL_3] };
            `ADC_REG_ADC4   :   read_data = {{ 32 - `ADC_DATA_WIDTH {1'b0}}, ADC[`ADC_CELL_4] };
            `ADC_REG_ADC5   :   read_data = {{ 32 - `ADC_DATA_WIDTH {1'b0}}, ADC[`ADC_CELL_5] };
            `ADC_REG_ADC6   :   read_data = {{ 32 - `ADC_DATA_WIDTH {1'b0}}, ADC[`ADC_CELL_6] };
            `ADC_REG_ADCT   :   read_data = {{ 32 - `ADC_DATA_WIDTH {1'b0}}, ADC[`ADC_CELL_T] };
        endcase


    //command fsm
    reg     [ 2 : 0 ]   State, Next;
    parameter   S_IDLE   = 3'b000,
                S_FIRST  = 3'b001,
                S_NEXT   = 3'b010,
                S_LAST   = 3'b011,
                S_SINGLE = 3'b100;

    always @ (posedge CLK)
        if(~RESETn)
            State <= S_IDLE;
        else
            State <= Next;

    reg     [ 2 : 0 ] ActiveCell;
    wire    [ 2 : 0 ] NextCell;

    wire    [`ADC_CELL_CNT - 1 : 0] ActiveFilter = (State == S_IDLE)
                                                 ? { `ADC_CELL_CNT { 1'b1 }}
                                                 : { `ADC_CELL_CNT { 1'b1 }} << ActiveCell + 1;

    wire    [`ADC_CELL_CNT - 1 : 0] NextFilter = { `ADC_CELL_CNT { 1'b1 }} << NextCell + 1;

    wire    NeedAction;
    wire    NeedStart    = NeedAction & ADCS_EN & (ADCS_SC | (ADCS_TE & ADC_Trigger));
    wire    NeedSequence = NeedStart && (NextFilter & ADMSK);

    always @ (*)
        case(State)
            S_IDLE   : Next = ~NeedStart   ? S_IDLE   : (
                              NeedSequence ? S_FIRST  : S_SINGLE);
            S_FIRST  : Next = ~ADC_C_Ready ? S_FIRST  : (
                               NeedAction  ? S_NEXT   : S_LAST );
            S_NEXT   : Next =  NeedAction  ? S_NEXT   : S_LAST;
            S_LAST   : Next = ~ADC_C_Ready ? S_LAST   : S_IDLE;
            S_SINGLE : Next = ~ADC_C_Ready ? S_SINGLE : S_IDLE;
        endcase

    always @ (posedge CLK) begin
        case(State)
            S_IDLE  : ActiveCell <= NextCell;
            S_FIRST,
            S_NEXT  : if(ADC_C_Ready) ActiveCell <= NextCell;
            default : ;
        endcase
    end

    wire [`ADC_CELL_CNT - 1 : 0] ADMSK_Filtered;
    assign ADMSK_Filtered = {{8 - `ADC_CELL_CNT { 1'b0 }}, ADMSK & ActiveFilter };

    priority_encoder8 mask_en
    (
        .in     ( ADMSK_Filtered ),
        .detect ( NeedAction     ),
        .out    ( NextCell       )
    );

    //command output
    reg    [ 2 : 0 ] out;
    assign { ADC_C_Valid, ADC_C_SOP, ADC_C_EOP } = out;

    always @ (*) begin
        case(State)
            S_IDLE   : out = 3'b000;
            S_FIRST  : out = 3'b110;
            S_NEXT   : out = 3'b100;
            S_LAST   : out = 3'b101;
            S_SINGLE : out = 3'b111;
        endcase

        case(ActiveCell)
            default     : ADC_C_Channel = `ADC_CH_NONE;
            `ADC_CELL_1 : ADC_C_Channel = `ADC_CH_1;
            `ADC_CELL_2 : ADC_C_Channel = `ADC_CH_2;
            `ADC_CELL_3 : ADC_C_Channel = `ADC_CH_3;
            `ADC_CELL_4 : ADC_C_Channel = `ADC_CH_4;
            `ADC_CELL_5 : ADC_C_Channel = `ADC_CH_5;
            `ADC_CELL_6 : ADC_C_Channel = `ADC_CH_6;
            `ADC_CELL_T : ADC_C_Channel = `ADC_CH_T;
        endcase
    end

endmodule

module adc_reg
#(
    parameter WIDTH = 32
)
(
    input                        clk,
    input                        rst,
    input      [ WIDTH - 1 : 0 ] in,
    input                        wr,
    output reg [ WIDTH - 1 : 0 ] out
);
    always @ (posedge clk)
        if(~rst)
            out <= { WIDTH { 1'b0 } };
        else
            if(wr) out <= in;
endmodule

module priority_encoder8
(
    input       [ 7 : 0 ] in,
    output reg            detect,
    output reg  [ 2 : 0 ] out
);
    always @ (*)
        casez(in)
            default     : {detect, out} = 4'b0000;
            8'b00000001 : {detect, out} = 4'b1000;
            8'b0000001? : {detect, out} = 4'b1001;
            8'b000001?? : {detect, out} = 4'b1010;
            8'b00001??? : {detect, out} = 4'b1011;
            8'b0001???? : {detect, out} = 4'b1100;
            8'b001????? : {detect, out} = 4'b1101;
            8'b01?????? : {detect, out} = 4'b1110;
            8'b1??????? : {detect, out} = 4'b1111;
        endcase
endmodule
