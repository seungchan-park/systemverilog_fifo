`include "transaction.sv"
`include "interface.sv"

class monitor;
    virtual fifo_interface fifo_if;
    mailbox #(transaction) mon2scb_mbox;
    transaction trans;

    function new(virtual fifo_interface fifo_if,
                 mailbox#(transaction) mon2scb_mbox);
        this.fifo_if = fifo_if;
        this.mon2scb_mbox = mon2scb_mbox;
    endfunction  //new()

    task run();
        forever begin
            trans       = new();
            #1;
            trans.wr_en = fifo_if.wr_en;
            trans.wdata = fifo_if.wdata;
            trans.rd_en = fifo_if.rd_en;
            trans.rdata = fifo_if.rdata;
            @(posedge fifo_if.clk);
            trans.full  = fifo_if.full;
            trans.empty = fifo_if.empty;
            mon2scb_mbox.put(trans);
            trans.display("MON");
        end
    endtask
endclass  //monitor
