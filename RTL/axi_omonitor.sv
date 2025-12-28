class axi_omonitor;

    virtual interface axi_if vif;
    mailbox#(axi_packet) mbx;
    axi_packet pkt;
    function new(mailbox#(axi_packet) mbx,virtual axi_if vif);
        this.mbx = mbx;
        this.vif = vif;
    endfunction

    task run();

        collect_outputs();

    endtask

    task collect_outputs();

        forever begin

            @(vif.cb_mon);

            if(vif.cb_mon.RVALID === 1'b1 && vif.cb_mon.RREADY === 1'b1) begin
                pkt = new();
                pkt.operation = OP_RD;
                pkt.r_data = vif.cb_mon.RDATA;
                do @(vif.cb_mon);
                while(!(vif.cb_mon.RVALID === 1'b0));
                $display("[%0t][OMonitor] Sending Read packet to Scoreboard",$time);

                mbx.put(pkt);
                pkt = null;
            end
        end
        

    endtask
endclass