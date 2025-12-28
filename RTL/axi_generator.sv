import axi_pkg::*;
class axi_generator;
	
	mailbox#(axi_packet) mbx;	
	int no_of_pkts;
	bit [31:0] pkt_count;
	axi_packet pkt;
	axi_packet rand_obj;
	
	function new(mailbox #(axi_packet) mbx,bit [31:0] gen_pkts_no = 1);
		$display("I am Generator");
		if(mbx==null) $display("mbx is null");
		this.mbx = mbx;
		$display("%0d",mbx.num());
		this.no_of_pkts = gen_pkts_no;
		rand_obj = new();
	endfunction
	
	task run();
		$display("[%0t][Generator] Run started",$time);
		//if(pkt == null) $fatal("PKT is null");
		pkt = new();
		if(pkt == null) $display("PKT is null");
		pkt.kind = RESET;
		pkt.reset_cycles = 2;
		$display("[%0t][Generator] Sending %0s axi_packet to driver",$time,pkt.kind.name());
		mbx.put(pkt);
				
		repeat(no_of_pkts) begin
			pkt = new();
			void'(rand_obj.randomize());
			pkt.copy(rand_obj);
			pkt.kind = STIMULUS;
			mbx.put(pkt);
			pkt_count++;
			$display("[%0t][Generator] Sending %0s axi_packet %0d to driver",$time,pkt.kind.name(),pkt_count);
		end
		
		$display("[%0t][Generator] Run finished",$time);
		
	endtask
	
endclass