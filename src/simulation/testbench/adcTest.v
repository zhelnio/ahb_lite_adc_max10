
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

    initial begin
        begin

            RESETn = 0;
            @(posedge ADC_CLK);
            @(posedge ADC_CLK);
            RESETn = 1;
            adc_clk_locked = 1'b0;



            @(posedge ADC_CLK);
            @(posedge ADC_CLK);
        end

        $stop;
        $finish;
    end




/*
    `include "ahb_lite.vh"
    `include "uart.vh"
    `include "uart_defines.v"

    assign UART_SRX = UART_STX;

    ahb_lite_uart16550 uart
    (
        .HCLK       (   HCLK        ),
        .HRESETn    (   HRESETn     ),
        .HADDR      (   HADDR       ),
        .HBURST     (   HBURST      ),
        .HSEL       (   HSEL        ),
        .HSIZE      (   HSIZE       ),
        .HTRANS     (   HTRANS      ),
        .HWDATA     (   HWDATA      ),
        .HWRITE     (   HWRITE      ),
        .HRDATA     (   HRDATA      ),
        .HREADY     (   HREADY      ),
        .HRESP      (   HRESP       ),

        .UART_SRX   (   UART_SRX    ),  // UART serial input signal
        .UART_STX   (   UART_STX    ),  // UART serial output signal
        .UART_RTS   (   UART_RTS    ),  // UART MODEM Request To Send
        .UART_CTS   (   UART_CTS    ),  // UART MODEM Clear To Send
        .UART_DTR   (   UART_DTR    ),  // UART MODEM Data Terminal Ready
        .UART_DSR   (   UART_DSR    ),  // UART MODEM Data Set Ready
        .UART_RI    (   UART_RI     ),  // UART MODEM Ring Indicator
        .UART_DCD   (   UART_DCD    ),  // UART MODEM Data Carrier Detect

        //UART internal
        .UART_BAUD  (   UART_BAUD   ),  // UART baudrate output
        .UART_INT   (   UART_INT    )   // UART interrupt
    );

    parameter Tclk = 20;
    always #(Tclk/2) HCLK = ~HCLK;

    initial begin
        begin

            HRESETn = 0;
            @(posedge HCLK);
            @(posedge HCLK);
            HRESETn = 1;

            @(posedge HCLK);
            //uart init & transmit 1 byte 0xF1

            // 1 working
            // ahbPhaseFst((`UART_REG_LC   << 2),   1, St_x);

            ahbPhaseFst((`UART_REG_LC   << 2),   1, St_x);
            ahbPhase   ((`UART_REG_MC   << 2),   1, 8'b11);     //8n1
            ahbPhase   ((`UART_REG_LC   << 2),   1, 8'b11);     //DTR + RTS
            
            // ahbPhase   ((`UART_REG_IE   << 2),   1, 8'b11);     //8n1
            // ahbPhase   ((`UART_REG_FC   << 2),   1, 8'b0);      //no interrupt
            // ahbPhase   ((`UART_REG_MC   << 2),   1, 8'b0);      //no fifo
            // ahbPhase   ((`UART_REG_LC   << 2),   0, 8'b11);     //DTR + RTS
            

            ahbPhase    ((`UART_REG_DL1  << 2),  1, 8'b11 | (1 << 7));
            ahbPhase    ((`UART_REG_DL2  << 2),  1, 8'd2);
            ahbPhase    ((`UART_REG_LC   << 2),   1, 8'b0);
            ahbPhase    ((`UART_REG_TR   << 2),   1, 8'b11);
            ahbPhase    ((`UART_REG_LS   << 2),   0, 8'h22);
            ahbPhase    ((`UART_REG_LS   << 2),   0, St_x);
            
            //waiting for transmit finish
            repeat(400)
                ahbPhase((`UART_REG_LS  << 2), 0, St_x);
            
            //reading input
            ahbPhase    ((`UART_REG_RB   << 2), 0, St_x);
            ahbPhase    ((`UART_REG_RB   << 2), 0, St_x);

            ahbPhaseLst ((`UART_REG_RB   << 2), 0, St_x);

            @(posedge HCLK);
            @(posedge HCLK);
        end
        $stop;
        $finish;
    end
*/
endmodule