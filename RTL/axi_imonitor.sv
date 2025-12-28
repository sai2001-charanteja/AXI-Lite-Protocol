
import axi_pkg::*;
class axi_imonitor;

    virtual axi_if vif;
    mailbox #(axi_packet) rdmbx,wrmbx;

    int pktno;

    function new(mailbox #(axi_packet) rdmbx,wrmbx,virtual axi_if vif);
        this.rdmbx = rdmbx;
        this.wrmbx = wrmbx;
        this.vif = vif;
    endfunction

    task run();
        /*
        forever begin
            pkt = null;
            collect_data(pkt);
            if(pkt != null) begin
                mbx.put(pkt);
                $display("[%0t][AXI_IMONITOR] sending packet to Scoreboard",$time);
                pkt.print();
                //$finish;
            end
        end
        */
        collect_data();
    endtask

    /* Collects the data */
    task  automatic collect_data();
		/*
            Write Packet
            AW Channel
            W Channel
            B Channel

            Read Packet
            AR Channel
            R Channel
        */

        fork
            collect_WritePacket();
            collect_ReadPacket();
        join
      

	endtask

    task automatic collect_WritePacket();
        /*AW or W phase can monitor simulatneously*/
        axi_packet pkt;
        axi_packet temp;

        forever begin
            @(vif.cb_mon);
            if(vif.cb_mon.AWVALID === 1'b1 && vif.cb_mon.AWREADY === 1'b1) begin
                if(pkt == null) pkt = new();
                pkt.aw_addr = vif.cb_mon.AWADDR;
            end

            if(vif.cb_mon.WVALID === 1'b1 && vif.cb_mon.WREADY === 1'b1) begin
                if(pkt == null) pkt = new();
                pkt.w_data = vif.cb_mon.WDATA;
                pkt.w_strb = vif.cb_mon.WSTRB;
            end

            if(vif.cb_mon.BVALID === 1'b1 && vif.cb_mon.BREADY === 1'b1) begin
                pkt.operation = OP_WR;
                $display("[%0t][IMonitor] Sending Write packet to Scoreboard",$time);
                wrmbx.put(pkt);

                pkt = null;
            end
        end
    endtask
    
    task automatic collect_ReadPacket();

        axi_packet pkt;
        axi_packet temp;

        forever begin
            @(vif.cb_mon);
            if(vif.cb_mon.ARVALID === 1'b1 && vif.cb_mon.ARREADY === 1'b1) begin
                if(pkt == null) pkt = new();
                pkt.ar_addr = vif.cb_mon.ARADDR;

                do @(vif.cb_mon);
                while(!(vif.cb_mon.RVALID === 1'b1 && vif.cb_mon.RREADY === 1'b1));  
                pkt.operation = OP_RD;
                $display("[%0t][IMonitor] Sending Read packet to Scoreboard",$time);
                rdmbx.put(pkt);

               // #0 while(mbx.num >= 1) void'(mbx.try_get(temp));
                
                pkt = null;
            end
        end

    endtask

endclass