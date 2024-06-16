`ifndef __INTERFACE__SV_ // define 안되면 실행하고, 이미 됐으면 실행안함
`define __INTERFACE__SV_

interface fifo_interface;
    logic       clk;
    logic       reset;
    logic       wr_en;
    logic       full;
    logic [7:0] wdata;
    logic       rd_en;
    logic       empty;
    logic [7:0] rdata;

endinterface  //fifo_interface

`endif
