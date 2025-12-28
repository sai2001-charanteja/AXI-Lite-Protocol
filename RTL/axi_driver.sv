import axi_pkg::*;
class axi_driver;

	virtual axi_if vif;
	mailbox#(axi_packet) mbx;
	
	axi_packet pkt;
	
	bit [31:0] no_of_stimulus_pkts_recvd;
	
	function new(mailbox#(axi_packet) mbx,virtual axi_if.drvr_mp vif);
		this.mbx = mbx;
		this.vif = vif;
	endfunction

	task run();
		$display("[DRIVER] Run started");
		
		while(1) begin
			
			mbx.get(pkt);
			if(pkt.kind == STIMULUS) begin
				no_of_stimulus_pkts_recvd++;
				$display("[%0t][Driver] %0s axi_packet %0d recieived",$time,pkt.kind.name(),no_of_stimulus_pkts_recvd);
				
			end else
				$display("[%0t][Driver] %0s recieived",$time,pkt.kind.name());
				
			drive(pkt);
			
			if(pkt.kind == STIMULUS)
				$display("[%0t][Driver] Driving of %0s axi_packet %0d completed",$time,pkt.kind.name(),no_of_stimulus_pkts_recvd);
			else
				$display("[%0t][Driver] %0s Finished",$time,pkt.kind.name());
		end
		//$display("[DRIVER] Run finished"); // It never be executed
	endtask
	
	task drive(input axi_packet pkt);
		case(pkt.kind)
			RESET:
				drive_reset(pkt);
			STIMULUS:
				drive_stimulus(pkt);
		endcase
	endtask
	
	
	task drive_reset(input axi_packet pkt);
		
		$display("[%0t][Driver] Applying Reset on AXI",$time);
		vif.ARESETn <= 1'b0;
		
		vif.cb.AWVALID <= 1'b0;
		vif.cb.AWADDR <= 'b0;;
		vif.cb.WVALID <= 1'b0;
		vif.cb.WDATA <= 'b0;
		vif.cb.WSTRB <= 'b0; 
		vif.cb.BREADY <= 1'b0;
		vif.cb.ARVALID <= 1'b0;
		vif.cb.ARADDR <= 'b0;
		vif.cb.RREADY <= 1'b0;
		repeat(pkt.reset_cycles) @(vif.cb);
		
		vif.ARESETn <= 1'b1;
		
		$display("[%0t][Driver] Reset completed on AXI",$time);
		
	endtask
	
	/**************************************************
	* Driving the AW Chanel signals
	**************************************************/
	task automatic aw_signals(input logic [ADDRESS_WIDTH-1:0] addr=0);
		// Start valid signals
		vif.cb.AWADDR  <= addr; // Driving the AWADDR
		vif.cb.AWVALID <= 1;	// Driving the AWVALID and its is assserted
	endtask

	/**************************************************
	* Driving the W channel Signals
	**************************************************/
	task automatic w_signals(
	input logic [DATA_WIDTH-1:0]    data=0,
    input logic [STRB_WIDTH-1:0]    strb = {STRB_WIDTH{1'b1}}
	);
		// Start valid signals
		vif.cb.WDATA   <= data; // Driving the WDATA by the random stimulus packet
		vif.cb.WSTRB   <= strb; // Driving the WSTRB (from the Packet)
		vif.cb.WVALID  <= 1;  // Driving the AWVALID and its is assserted
	endtask
	
	/**************************************************
	* B(Response) channel waiting for the slave response
	and completing the write handshake.
	**************************************************/
	task automatic axi_drive_response_Channel();
		begin
			// Write response (B channel)
			vif.cb.BREADY <= 1;
			
			while (!vif.cb.BVALID) @(vif.cb);
			
			vif.cb.BREADY <= 0;
		end
	endtask
	
	/**************************************************
	* AW channel Hand shake Logic
	**************************************************/
	task automatic axi_AW_hs();
		begin
			// AW handshake
			while (!vif.cb.AWREADY) @(vif.cb);
			
			vif.cb.AWVALID <= 0;   // data accepted
		end
	endtask

	/**************************************************
	* W channel Hand shake Logic
	**************************************************/
	task automatic axi_W_hs();
		begin
			// W handshake
			while (!vif.cb.WREADY) @(vif.cb);
			
			vif.cb.WVALID <= 0;   // data accepted
		end
	endtask
	
	task automatic axi_write(
    input logic [ADDRESS_WIDTH-1:0] addr,
    input logic [DATA_WIDTH-1:0]    data,
    input logic [STRB_WIDTH-1:0]    strb = {STRB_WIDTH{1'b1}}
	);
		begin
			case(pkt.wr_operation)
				AW_W:
					axi_AW_W(addr,data,strb); // First Driving AW follwed by delay and then W Channel signals
				W_AW:
					axi_W_AW(addr,data,strb); // First Driving W follwed by delay and then AW Channel signals
			endcase
		end
	endtask
	
	/**************************************************
	* Driving AW channel followed by driving W channel
	**************************************************/
	task automatic axi_AW_W(
    input logic [ADDRESS_WIDTH-1:0] addr,
    input logic [DATA_WIDTH-1:0]    data,
    input logic [STRB_WIDTH-1:0]    strb = {STRB_WIDTH{1'b1}}
	);
		begin
			$display("[%0t][Driver] AW_W operation started ",$time);
			repeat(pkt.aw_del) @(vif.cb);
			
			aw_signals(addr);
			
			repeat(pkt.w_del) @(vif.cb);
			
			w_signals(data,strb);
			
			@(vif.cb);
			
			fork
				axi_AW_hs(); // Waiting for the W handsake
			
				axi_W_hs(); // Waiting for the AW handsake
			join
			
			axi_drive_response_Channel(); // Waiting for the Response
			
			$display("[%0t][Driver] AW_W operation finished ",$time);
		end
	endtask

	/**************************************************
	* Driving W channel followed by driving AW channel
	**************************************************/
	task automatic axi_W_AW(
    input logic [ADDRESS_WIDTH-1:0] addr,
    input logic [DATA_WIDTH-1:0]    data,
    input logic [STRB_WIDTH-1:0]    strb = {STRB_WIDTH{1'b1}}
	);
		begin
			$display("[%0t][Driver] W_AW operation started ",$time);
			
			repeat(pkt.w_del) @(vif.cb); // Initial delay before driving the transaction
			
			w_signals(data,strb);

			repeat(pkt.aw_del) @(vif.cb); // Initial delay for AW  transaction
			
			aw_signals(addr);

			@(vif.cb);
			
			fork
				axi_AW_hs(); // Waiting for the W handsake
			
				axi_W_hs(); // Waiting for the AW handsake
			join
			
			axi_drive_response_Channel(); // Waiting for the Response
			
			$display("[%0t][Driver] W_AW operation finished ",$time);
		end
	endtask
	
	
	
	task automatic axi_read(
		input logic [DELAY_WIDTH-1:0]r_del,
		input logic [ADDRESS_WIDTH-1:0] addr
	);
		begin
			repeat(r_del) @(vif.cb);
			
			$display("[%0t][Driver] Driving of %0d in AR Channel started.",$time,no_of_stimulus_pkts_recvd);
			
			// Start AR
			vif.cb.ARADDR  <= addr;
			vif.cb.ARVALID <= 1;

			// AR handshake
			// @(vif.cb);
			
			while (!vif.cb.ARREADY) @(vif.cb);
			
			vif.cb.ARVALID <= 0;
			
			// R channel
			vif.cb.RREADY <= 1;
			
			while (!vif.cb.RVALID) @(vif.cb);
			
			@(vif.cb);
			
			vif.cb.RREADY <= 0;
			
			$display("[%0t][Driver] Driving of %0d in AR Channel finished.",$time,no_of_stimulus_pkts_recvd);
		end
	endtask
	
	
	task drive_stimulus(input axi_packet pkt);
	
		$display("[%0t][Driver] Driving of packet %0d started",$time,no_of_stimulus_pkts_recvd);
		case(pkt.operation)
			OP_IDLE: @(vif.cb); // No Transaction
				
			OP_RD: begin
				axi_read(pkt.initial_r_del,pkt.ar_addr); // Driving the Read Transaction
			end
			OP_WR: axi_write(pkt.aw_addr,pkt.w_data,pkt.w_strb); // Driving the Write Transaction
			
			OP_RW : begin // Read and Write Transaction Simultaneously
				fork
					axi_read(pkt.initial_r_del,pkt.ar_addr); // Driving the Read Transaction
					axi_write(pkt.aw_addr,pkt.w_data,pkt.w_strb);// Driving the Write Transaction
				join
			end
			
		endcase
		
		$display("[%0t][Driver] Driving of packet %0d finished",$time,no_of_stimulus_pkts_recvd);
	endtask
	
endclass