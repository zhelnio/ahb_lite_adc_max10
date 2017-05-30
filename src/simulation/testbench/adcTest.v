
// Testbench for AHB-Lite master emulator
`timescale 1ns / 100ps

`include "mfp_adc_max10_core.vh"

module test_adcTest;

    reg     CLK;
    reg     RESETn;
    reg     ADC_CLK;

    reg  [ `ADC_ADDR_WIDTH - 1 : 0  ]  read_addr;
    wire [                  31 : 0  ]  read_data;
    reg  [ `ADC_ADDR_WIDTH - 1 : 0  ]  write_addr;
    reg  [                  31 : 0  ]  write_data;
    reg                                write_enable;

    wire          ADC_C_Valid;
    wire [  4:0 ] ADC_C_Channel;
    wire          ADC_C_SOP;
    wire          ADC_C_EOP;
    wire          ADC_C_Ready;
    wire          ADC_R_Valid;
    wire [  4:0 ] ADC_R_Channel;
    wire [ 11:0 ] ADC_R_Data;
    wire          ADC_R_SOP;
    wire          ADC_R_EOP;

    reg           ADC_Trigger;
    wire          ADC_Interrupt;
    
    reg           adc_clk_locked;

    adc_core adc
    (
        .adc_pll_clock_clk      ( ADC_CLK           ),
        .adc_pll_locked_export  ( adc_clk_locked    ),
        .clock_clk              ( CLK               ),
        .command_valid          ( ADC_C_Valid       ),
        .command_channel        ( ADC_C_Channel     ),
        .command_startofpacket  ( ADC_C_SOP         ),
        .command_endofpacket    ( ADC_C_EOP         ),
        .command_ready          ( ADC_C_Ready       ),
        .reset_sink_reset_n     ( RESETn            ),
        .response_valid         ( ADC_R_Valid       ),
        .response_channel       ( ADC_R_Channel     ),
        .response_data          ( ADC_R_Data        ),
        .response_startofpacket ( ADC_R_SOP         ),
        .response_endofpacket   ( ADC_R_EOP         )
    );

    mfp_adc_max10_core mfp_adc_core
    (
        .CLK            ( CLK           ),
        .RESETn         ( RESETn        ),

        .read_addr      ( read_addr     ),
        .read_data      ( read_data     ),
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

    parameter Tclk = 20;
    always #(Tclk/2) CLK = ~CLK;

    parameter Tadc = 100;
    always #(Tadc/2) ADC_CLK = ~ADC_CLK;

    initial begin
        CLK        = 1'b0;
        RESETn     = 1'b1;
        ADC_CLK    = 1'b0;
        adc_clk_locked = 1'b1;
    end

    task write;
        input [ `ADC_ADDR_WIDTH - 1 : 0  ]  i_write_addr;
        input [                  31 : 0  ]  i_write_data;

        begin
            write_addr      = i_write_addr;
            write_data      = i_write_data;
            write_enable    = 1'b1;
            @(posedge CLK);
            $display("%t WRITEN ADDR=%h DATA=%h",$time, i_write_addr, i_write_data);
            write_enable    = 1'b0;
        end
    endtask

    task read;
        input [ `ADC_ADDR_WIDTH - 1 : 0  ]  i_read_addr;

        begin
            read_addr = i_read_addr;
            @(posedge CLK);
            $display("%t READEN ADDR=%h DATA=%h",$time, i_read_addr, read_data);
        end
    endtask

    initial begin
        begin

            RESETn = 0;
            @(posedge ADC_CLK);
            @(posedge ADC_CLK);
            RESETn = 1;
            adc_clk_locked = 1'b0;

            //all channels enable
            write ( `ADC_REG_ADMSK,   (1'b1 << `ADC_CH_1) );
            read  ( `ADC_REG_ADMSK );

            //all options enable
            write ( `ADC_REG_ADCS,    (1'b1 << `ADC_FIELD_ADCS_EN) | (1'b1 << `ADC_FIELD_ADCS_SC) 
                                    | (1'b1 << `ADC_FIELD_ADCS_TE) | (1'b1 << `ADC_FIELD_ADCS_IE) );
            read  ( `ADC_REG_ADCS );

            repeat(3000) begin
                @(posedge ADC_CLK);
                read  ( `ADC_REG_ADCS );
            end

            @(posedge ADC_CLK);
            @(posedge ADC_CLK);
        end

        $stop;
        $finish;
    end

endmodule