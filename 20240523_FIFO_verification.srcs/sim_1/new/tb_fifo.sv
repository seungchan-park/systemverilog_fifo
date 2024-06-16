`timescale 1ns / 1ps

`include "environment.sv"

module tb_fifo ();
    environment env;
    fifo_interface fifo_if ();

    fifo #(
        .ADDR_WIDTH(3),
        .DATA_WIDTH(8)
    ) dut (
        .clk  (fifo_if.clk),
        .reset(fifo_if.reset),
        .wr_en(fifo_if.wr_en),
        .full (fifo_if.full),
        .wdata(fifo_if.wdata),
        .rd_en(fifo_if.rd_en),
        .empty(fifo_if.empty),
        .rdata(fifo_if.rdata)
    );

    always #5 fifo_if.clk = ~fifo_if.clk;

    initial begin
        fifo_if.clk = 0;
    end

    initial begin
        env = new(fifo_if);
        env.run_test(100);
    end
endmodule
