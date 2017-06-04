
`include "mfp_adc_max10_core.vh"

module de10_lite_adc(

	//////////// CLOCK //////////
	input 		          		ADC_CLK_10,
	input 		          		MAX10_CLK1_50,
	input 		          		MAX10_CLK2_50,

	//////////// SDRAM //////////
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N,

	//////////// SEG7 //////////
	output		     [7:0]		HEX0,
	output		     [7:0]		HEX1,
	output		     [7:0]		HEX2,
	output		     [7:0]		HEX3,
	output		     [7:0]		HEX4,
	output		     [7:0]		HEX5,

	//////////// KEY //////////
	input 		     [1:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// VGA //////////
	output		     [3:0]		VGA_B,
	output		     [3:0]		VGA_G,
	output		          		VGA_HS,
	output		     [3:0]		VGA_R,
	output		          		VGA_VS,

	//////////// Accelerometer //////////
	output		          		GSENSOR_CS_N,
	input 		     [2:1]		GSENSOR_INT,
	output		          		GSENSOR_SCLK,
	inout 		          		GSENSOR_SDI,
	inout 		          		GSENSOR_SDO,

	//////////// Arduino //////////
	inout 		    [15:0]		ARDUINO_IO,
	inout 		          		ARDUINO_RESET_N,

	//////////// GPIO, GPIO connect to GPIO Default //////////
	inout 		    [35:0]		GPIO
);

//=======================================================
//  REG/WIRE declarations
//=======================================================

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

   wire [ 31:0 ] RDATA;
   wire [ `ADC_ADDR_WIDTH - 1 : 0 ] RADDR;

   wire          RESETn;
   wire          ADC_CLK;
   wire          CLK;
   wire          ADC_CLK_Lock;

//=======================================================
//  Structural coding
//=======================================================

   pll pll (MAX10_CLK1_50, ADC_CLK, CLK, ADC_CLK_Lock);

   adc_standalone adc_control
   (
      .CLK           ( CLK           ),
      .RESETn        ( RESETn        ),

      // Altera MAX10 ADC side
      .ADC_C_Valid   ( ADC_C_Valid   ),
      .ADC_C_Channel ( ADC_C_Channel ),
      .ADC_C_SOP     ( ADC_C_SOP     ),
      .ADC_C_EOP     ( ADC_C_EOP     ),
      .ADC_C_Ready   ( ADC_C_Ready   ),
      .ADC_R_Valid   ( ADC_R_Valid   ),
      .ADC_R_Channel ( ADC_R_Channel ),
      .ADC_R_Data    ( ADC_R_Data    ),
      .ADC_R_SOP     ( ADC_R_SOP     ),
      .ADC_R_EOP     ( ADC_R_EOP     ),

      .RADDR         ( RADDR         ),
      .RDATA         ( RDATA         )
   );

   adc adc
   (
      .adc_pll_clock_clk      ( ADC_CLK       ),
      .adc_pll_locked_export  ( ADC_CLK_Lock  ),
      .clock_clk              ( CLK           ),
      .command_valid          ( ADC_C_Valid   ),
      .command_channel        ( ADC_C_Channel ),
      .command_startofpacket  ( ADC_C_SOP     ),
      .command_endofpacket    ( ADC_C_EOP     ),
      .command_ready          ( ADC_C_Ready   ),
      .reset_sink_reset_n     ( RESETn        ),
      .response_valid         ( ADC_R_Valid   ),
      .response_channel       ( ADC_R_Channel ),
      .response_data          ( ADC_R_Data    ),
      .response_startofpacket ( ADC_R_SOP     ),
      .response_endofpacket   ( ADC_R_EOP     ) 
   );

   assign RESETn = KEY [ 0 ];

   assign RADDR  = SW [ `ADC_ADDR_WIDTH - 1 : 0 ];

   assign HEX0 [ 7] = 1'b1;
   assign HEX1 [ 7] = 1'b1;
   assign HEX2 [ 7] = 1'b1;
   assign HEX3 [ 7] = 1'b1;
   assign HEX4 [ 7] = 1'b1;
   assign HEX5 [ 7] = 1'b1;

   wire [23:0] IO_7_SegmentHEX = RDATA [23:0];

   mfp_single_digit_seven_segment_display digit_5 ( IO_7_SegmentHEX [23:20] , HEX5 [6:0] );
   mfp_single_digit_seven_segment_display digit_4 ( IO_7_SegmentHEX [19:16] , HEX4 [6:0] );
   mfp_single_digit_seven_segment_display digit_3 ( IO_7_SegmentHEX [15:12] , HEX3 [6:0] );
   mfp_single_digit_seven_segment_display digit_2 ( IO_7_SegmentHEX [11: 8] , HEX2 [6:0] );
   mfp_single_digit_seven_segment_display digit_1 ( IO_7_SegmentHEX [ 7: 4] , HEX1 [6:0] );
   mfp_single_digit_seven_segment_display digit_0 ( IO_7_SegmentHEX [ 3: 0] , HEX0 [6:0] );

endmodule
