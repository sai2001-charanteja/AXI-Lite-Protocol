import axi_pkg::*;
class axi_scoreboard;

    mailbox #(axi_packet) irmbx,iwmbx,ombx;

    bit [DATA_WIDTH-1:0] ref_mem[ADDRESS_WIDTH-1:0];

    int matched;
    int missmatched;
    int invalid;

    axi_packet iwpkt,irpkt;
    axi_packet opkt;
    function new(mailbox #(axi_packet) irmbx,iwmbx,mailbox#(axi_packet) ombx);
        this.irmbx = irmbx;
        this.iwmbx = iwmbx;
        this.ombx = ombx;
    endfunction

    task run();
        /*First capture the input packet and then goes the output packet*/
        
        fork

            begin
                forever begin
                    irmbx.get(irpkt);
                    if(irpkt.operation == OP_RD) begin
                        ombx.get(opkt);
                        compareResults(irpkt,opkt);
                    end
                end
            end

            begin
                forever begin
                    iwmbx.get(iwpkt);
                    if(iwpkt.operation == OP_WR) begin
                        processWritepkt(iwpkt);
                    end
                end
            end 
        join


    endtask

    function void processWritepkt(input axi_packet pkt);
        if(pkt.aw_addr < ADDRESS_WIDTH && pkt.aw_addr>=0) begin
            //$display("[%0t][ScoreBoard] Processing write packet,strb = %0b",$time,pkt.w_strb);
            for(int idx=0;idx<STRB_WIDTH;idx++) begin
                if(pkt.w_strb[idx]) begin
                    ref_mem[pkt.aw_addr][idx*8+:8] = pkt.w_data[idx*8+:8];
                    //$display("STRB[%0d]=%0b,Ref[%0d][%0d:%0d]",idx,pkt.w_strb[idx],pkt.aw_addr,idx*8+7,idx*8,ref_mem[pkt.aw_addr][idx*8+:8]);
                end
            end
            //$display("[ScoreBoard]Reference memory[%0d] = %0d",pkt.aw_addr,ref_mem[pkt.aw_addr]);
        end else begin
            invalid++;
        end
    endfunction

    function void compareResults(input axi_packet ipkt,opkt);
        if(ipkt.ar_addr < ADDRESS_WIDTH && ipkt.ar_addr>=0) begin
            if(ref_mem[ipkt.ar_addr] == opkt.r_data) matched++;
            else begin
                   // $display("[%0t]ref_mem[%0d] = (%0d) != %0d",$time,ipkt.ar_addr,ref_mem[ipkt.ar_addr],opkt.r_data);
                    missmatched++;
            end
        end else begin
            invalid++;
        end

    endfunction


    function void printResults();
        
        if(missmatched == 0) begin
            $display("****************************************************");
            $display("*********************TEST PASSSED*******************");
            $display("[ScoreBoard] Matched = %0d, MissMatched = %0d , Invalid = %0d",matched,missmatched,invalid);
            $display("****************************************************");
        end else begin
            $display("****************************************************");
            $display("*********************TEST FAILED*******************");
            $display("[ScoreBoard] Matched = %0d, MissMatched = %0d , Invalid = %0d",matched,missmatched,invalid);
            $display("****************************************************");
        end
    endfunction
endclass