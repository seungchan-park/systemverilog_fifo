`include "transaction.sv"
`include "interface.sv"

class driver;
    transaction trans;
    mailbox #(transaction) gen2drv_mbox;
    virtual fifo_interface fifo_if;

    function new(virtual fifo_interface fifo_if,
                 mailbox#(transaction) gen2drv_mbox);
        this.fifo_if = fifo_if;
        this.gen2drv_mbox = gen2drv_mbox;
    endfunction  //new()

    task reset();
        fifo_if.reset <= 1'b1;
        fifo_if.wr_en <= 1'b0;
        fifo_if.wdata <= 0;
        fifo_if.rd_en <= 1'b0;
        repeat (5) @(posedge fifo_if.clk);
        fifo_if.reset <= 1'b0;
    endtask

    task run();
        forever begin
            gen2drv_mbox.get(trans);
            trans.display("DRV");
            fifo_if.wr_en <= trans.wr_en;
            fifo_if.wdata <= trans.wdata;
            fifo_if.rd_en <= trans.rd_en;
            @(posedge fifo_if.clk);
        end

    endtask
endclass  //driver
