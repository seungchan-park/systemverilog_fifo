`include "interface.sv"
`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"

class environment;
    generator              gen;
    driver                 drv;
    monitor                mon;
    scoreboard             scb;

    event                  gen_next_event;

    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) mon2scb_mbox;

    function new(virtual fifo_interface fifo_if);
        gen2drv_mbox = new();
        mon2scb_mbox = new();

        gen = new(gen2drv_mbox, gen_next_event);
        drv = new(fifo_if, gen2drv_mbox);
        mon = new(fifo_if, mon2scb_mbox);
        scb = new(mon2scb_mbox, gen_next_event);
    endfunction  //new()

    task report();
        $display("==================================");
        $display("==         Final Report         ==");
        $display("==================================");
        $display("Total Test :     %d", scb.total_cnt);
        $display("Read Pass Test : %d", scb.read_pass_cnt);
        $display("Read Fail Test : %d", scb.read_fail_cnt);
        $display("Empty Test :     %d", scb.empty_cnt);
        $display("WRITE Test :     %d", scb.write_cnt);
        $display("Full Test :      %d", scb.write_fail_cnt);
        $display("==================================");
        $display("==    testbench is finished!    ==");
        $display("==================================");
    endtask

    task pre_run();
        drv.reset();
    endtask

    task run(int count);
        fork
            gen.run(count);
            drv.run();
            mon.run();
            scb.run();
        join_any
        report();
        #10 $finish;
    endtask

    task run_test(int count);
        pre_run();
        run(count);
    endtask
endclass  //environment