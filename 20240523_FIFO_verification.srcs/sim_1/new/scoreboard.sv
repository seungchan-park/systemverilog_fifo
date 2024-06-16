`include "transaction.sv"

class scoreboard;
    transaction trans;
    mailbox #(transaction) mon2scb_mbox;
    event gen_next_event;

    int total_cnt, read_pass_cnt, read_fail_cnt, write_cnt, write_fail_cnt, empty_cnt;
    reg [7:0] scb_fifo[$:8];  // '$' is queue(fifo), ':8'이 없으면 무한대 값, golden reference
    reg [7:0] scb_fifo_data;

    function new(mailbox#(transaction) mon2scb_mbox, event gen_next_event);
        this.mon2scb_mbox   = mon2scb_mbox;
        this.gen_next_event = gen_next_event;

        total_cnt           = 0;
        read_pass_cnt            = 0;
        read_fail_cnt            = 0;
        write_cnt           = 0;
        write_fail_cnt      = 0;
        empty_cnt = 0;
    endfunction  //new()

    task run();
        forever begin
            mon2scb_mbox.get(trans);
            trans.display("SCB");
            if (trans.wr_en) begin
                if(!trans.full) begin
                    scb_fifo.push_back(trans.wdata);  // 뒤에서 입력
                    $display(" --> WRITE! fifo_data: %x, queue size: %d",
                             trans.wdata, scb_fifo.size());
                    write_cnt++;
                end else begin
                    $display(" --> WRITE_FAIL! fifo_data: %x, queue size: %d",
                             trans.wdata, scb_fifo.size());
                    write_fail_cnt++;
                end
            end else if (trans.rd_en) begin
                if(!trans.empty) begin
                    scb_fifo_data = scb_fifo.pop_front(); // 앞에서 출력하여 저장
                    if (scb_fifo_data == trans.rdata) begin
                        $display(
                            " --> PASS! fifo_data %x == rdata %x, que size: %d",
                            scb_fifo_data, trans.rdata, scb_fifo.size());
                        read_pass_cnt++;
                    end else begin
                        $display(
                            " --> FAIL! fifo_data %x != rdata %x, que size: %d",
                            scb_fifo_data, trans.rdata, scb_fifo.size());
                        read_fail_cnt++;
                    end
                end else begin
                    $display(
                            " --> EMPTY! fifo_data %x , rdata %x, que size: %d",
                            scb_fifo_data, trans.rdata, scb_fifo.size());
                    empty_cnt++;
                end
            end
            total_cnt++;
            ->gen_next_event;
        end
    endtask
endclass  //scoreboard
