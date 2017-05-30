



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





