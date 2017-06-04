

`include "mfp_adc_max10_core.vh"

module adc_standalone
(
    input               CLK,
    input               RESETn,

    // Altera MAX10 ADC side
    output              ADC_C_Valid,
    output     [  4:0 ] ADC_C_Channel,
    output              ADC_C_SOP,
    output              ADC_C_EOP,
    input               ADC_C_Ready,
    input               ADC_R_Valid,
    input      [  4:0 ] ADC_R_Channel,
    input      [ 11:0 ] ADC_R_Data,
    input               ADC_R_SOP,
    input               ADC_R_EOP,

    input  [ `ADC_ADDR_WIDTH - 1 : 0 ] RADDR,
    output [                  31 : 0 ] RDATA
);

    reg    [ `ADC_ADDR_WIDTH - 1 : 0 ] write_addr;
    reg    [                  31 : 0 ] write_data;
    reg                                write_enable;

    parameter   S_INIT      = 0,
                S_INIT_MASK = 1,
                S_INIT_MODE = 2,
                S_IDLE      = 3;

    wire [ 2 : 0 ] State;
    reg  [ 2 : 0 ] Next;
    mfp_register_r #(.WIDTH(3), .RESET(S_INIT)) r_FSM_State (CLK, RESETn, Next, 1'b1, State );

    always @(*) begin
        case (State) 
            S_INIT      : Next = S_INIT_MASK;
            S_INIT_MASK : Next = S_INIT_MODE;
            S_INIT_MODE : Next = S_IDLE;
            S_IDLE      : Next = S_IDLE;
        endcase
    end

    parameter   ADC_MASK  = 32'b0 |
                            ( (1'b1 << `ADC_CELL_1) | (1'b1 << `ADC_CELL_2) 
                            | (1'b1 << `ADC_CELL_3) | (1'b1 << `ADC_CELL_4) 
                            | (1'b1 << `ADC_CELL_5) | (1'b1 << `ADC_CELL_6) 
                            | (1'b1 << `ADC_CELL_T) );

    parameter   ADC_MODE  = 32'b0 |
                            ( (1'b1 << `ADC_FIELD_ADCS_EN)      // ADC enable
                            | (1'b1 << `ADC_FIELD_ADCS_SC)      // start conversion
                            | (1'b1 << `ADC_FIELD_ADCS_FR) );   // free runing mode

    always @(*) begin
        case (State) 
            S_INIT_MASK : begin write_addr = `ADC_REG_ADMSK; write_data = ADC_MASK; write_enable = 1'b1; end
            S_INIT_MODE : begin write_addr = `ADC_REG_ADCS;  write_data = ADC_MODE; write_enable = 1'b1; end
            default     : begin write_addr = 4'b0; write_data = 32'b0; write_enable = 1'b0; end
        endcase
    end

    mfp_adc_max10_core adc_core
    (
        .CLK            ( CLK           ),
        .RESETn         ( RESETn        ),
        .read_addr      ( RADDR         ),
        .read_data      ( RDATA         ),
        .write_addr     ( write_addr    ),
        .write_data     ( write_data    ),
        .write_enable   ( write_enable  ),
        .ADC_C_Valid    ( ADC_C_Valid   ),
        .ADC_C_Channel  ( ADC_C_Channel ),
        .ADC_C_SOP      ( ADC_C_SOP     ),
        .ADC_C_EOP      ( ADC_C_EOP     ),
        .ADC_C_Ready    ( ADC_C_Ready   ),
        .ADC_R_Valid    ( ADC_R_Valid   ),
        .ADC_R_Channel  ( ADC_R_Channel ),
        .ADC_R_Data     ( ADC_R_Data    ),
        .ADC_R_SOP      ( ADC_R_SOP     ),
        .ADC_R_EOP      ( ADC_R_EOP     ),
        .ADC_Trigger    ( ADC_Trigger   ),
        .ADC_Interrupt  ( ADC_Interrupt )
    );

endmodule