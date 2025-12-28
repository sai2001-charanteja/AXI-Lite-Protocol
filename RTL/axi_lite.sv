import axi_pkg::*;

module axi_lite #(
  parameter integer ADDRESS_WIDTH = 16,   
  parameter integer DATA_WIDTH = 32,   
  parameter integer STRB_WIDTH   = 4
  
)(
	input logic ACLKn,
	input logic ARESETn,
	
	input logic AWVALID, 
	output logic AWREADY, 
  	input logic [ADDRESS_WIDTH-1:0]AWADDR, 

	input logic WVALID, 
	output logic WREADY, 
	input logic [DATA_WIDTH-1:0]WDATA,
  	input logic [STRB_WIDTH-1:0]WSTRB, 
	
	output logic BVALID, 
	input logic BREADY,
	output respCode BRESP, 
	
	input logic ARVALID, 
	output logic ARREADY, 
  	input logic [ADDRESS_WIDTH-1:0] ARADDR,
	
	output logic RVALID, 
	input logic RREADY, 
	output logic [DATA_WIDTH-1:0]RDATA, 
	output respCode RRESP
);

	logic [DATA_WIDTH-1:0]mem[ADDRESS_WIDTH-1:0]; // Memory /Register
	
	
	logic [ADDRESS_WIDTH-1:0] latched_aw_addr; // Latching the AWADDR
	
	logic aw_hs; // Used for AW handshake
  	logic [DATA_WIDTH-1:0] latched_w_data; // Used for latching WDATA
	logic [STRB_WIDTH-1:0] latched_w_strb; // Used for latching WSTRB
	logic w_hs; // Used for W handshake
  
	
  
  	/*********************************************************
	* Maintain FSM of AW and W channel Transaction
	*********************************************************/
  
	typedef enum {NONE, GOT_AW, GOT_W,GOT_BOTH} state; // Used for the maintaing the status of transaction
	// Here W_state_next is combinational signal, and w_state is a register
	state w_state,w_next_state;
	
	always @(posedge ACLKn, negedge ARESETn) begin
		if(!ARESETn) begin
			w_state <= NONE;
		end else begin 
			w_state <= w_next_state; 
		end
	end
	
	always_comb begin
		w_next_state = w_state;
		case(w_state)
		NONE:
			if(aw_hs && !w_hs) w_next_state = GOT_AW; // When only AW handshake we move our state to GOT_AW
			else if(!aw_hs && w_hs) w_next_state = GOT_W; // When only W handshake we move our state to GOT_W
			else if(aw_hs && w_hs) w_next_state = GOT_BOTH; // When both AW & W handshake we move our state to GOT_BOTH
			else w_next_state = NONE; // If no handshake is done we move to NONE state
		GOT_AW: w_next_state = w_hs?GOT_BOTH:GOT_AW; // wait for AW channel
		GOT_W: 	w_next_state = aw_hs?GOT_BOTH:GOT_W; // wait for W channel
		GOT_BOTH: w_next_state = BREADY ? NONE: GOT_BOTH; // we need to hold it until the write operation is done.
		endcase
	end
	
  	assign aw_hs = AWREADY && AWVALID;  // It is asserted only when AWREADY is asserted and AWVALID is asserted
  	assign  w_hs = WREADY && WVALID; // It is asserted only when WREADY is asserted and WVALID is asserted
  
  
	/**********************************************************
		AW Channel:
		Signals : 
			Inputs : AWVALID, AWADDR 
			Outputs: AWREADY
	**********************************************************/
	
	always @(posedge ACLKn, negedge ARESETn) begin
		if(!ARESETn) begin // On Reset
			AWREADY <= 1'b0;  // Initialize to 0
			latched_aw_addr <= '0; // Initialize to 0
 		end else begin 
			if(!AWREADY && AWVALID) begin // This is for not latching the data, when ever it is already latched
				latched_aw_addr <= AWADDR; // Latching the AWADDR
				AWREADY <= 1'b1; // Asserting the AWREADY
			end else if(AWREADY) begin // Performing change from AWVALID To AWREADY
				// latched_aw_addr <= '0;
				AWREADY <= 1'b0; // De-asserting the READY signal as it is latche the address by de-asseting the AWVALID 
			end
			
		end
	end
	
	
	/*
		W Channel :
		Signals :
			Inputs : WVALID, WDATA, WSTRB
			Ouputs : WREADY
	*/
	
	always @(posedge ACLKn, negedge ARESETn) begin
		if(!ARESETn) begin // On Reset
			WREADY <= 1'b0;  // Initialize to 0
			latched_w_data <= '0; // Initialize to 0
			latched_w_strb <= '0; // Initialize to 0
		end else begin 
			if(!WREADY && WVALID) begin // Latch data and strobe
				latched_w_data <= WDATA; // Latching the AWADDR
				latched_w_strb <= WSTRB; // Latching the AWADDR
				WREADY <= 1'b1;          // Asserting the WREADY
			end else if(WREADY && !WVALID) begin
				WREADY <= 1'b0;			// De-Asserting the WREADY
			end
			
			
		end
	end
	
	
	/**********************************************************
		B Channel:
		Signals: 
			Inputs : BREADY
			Outputs: BVALID , BRESP
	**********************************************************/
	
	always @(posedge ACLKn, negedge ARESETn) begin
		if(!ARESETn) begin
			BVALID <= 1'b0;
			BRESP <= OKAY;
		end else begin 
			if(w_next_state == GOT_BOTH && w_state != GOT_BOTH) begin // Based on the w_state and w_state_next we are asserting the valid an response as OKAY
				BVALID <= 1'b1;
				BRESP <= OKAY;
			end else if(BVALID && BREADY) begin
				BVALID <= 1'b0;
			end
		end
	end
	
	integer idx;
	/**********************************************************
		Memory Operation
	**********************************************************/
	always @(posedge ACLKn, negedge ARESETn) begin
		if(!ARESETn) begin // On reset
			for(idx = 0;idx < ADDRESS_WIDTH; idx++) begin
				mem[idx] <= '0; // Reseting the memory values to 0
			end
		end else begin
			if(w_state == GOT_BOTH) begin // Operation is done only w_state == GOT_BOTH
              if(latched_aw_addr < ADDRESS_WIDTH) begin
					for(idx =0;idx < STRB_WIDTH;idx++) begin
						if(latched_w_strb[idx]) begin // Based on the strobe we are writing the data
                          mem[latched_aw_addr][idx*8+:8] <= latched_w_data[idx*8+:8];
						end
					end
				end 
			end
		end
	end
	
	/*
		AR - Channel
		Signals: 
			Inputs : ARVALID, ARADDR
			Outputs: ARREADY
	*/
	
	logic [ADDRESS_WIDTH-1:0] latched_r_addr; // Latching the RADDR
	logic ar_hs ; // Used for AR handshake
	
	assign ar_hs = ARREADY && ARVALID; 
	
	always @(posedge ACLKn, negedge ARESETn) begin
		if(!ARESETn) begin
			ARREADY <= 1'b0;
			latched_r_addr <= '0; 
		end else begin 
			if(!ARREADY && ARVALID) begin
				latched_r_addr <= ARADDR; // Latching the RADDR
				ARREADY <= 1'b1;
			end else if(ARREADY) begin
				ARREADY <= 1'b0;
			end
			
		end
	end
	
	/*
		R Channel
		Signals : 
			Inputs : RREADY
			Outputs: RVALID, RDATA , RRESP
		
	*/
	int ridx;
	always @(posedge ACLKn, negedge ARESETn) begin
		if(!ARESETn) begin
			RVALID <= 1'b0;
			RDATA <= '0;
			RRESP <= OKAY;
		end else begin 
			if(ar_hs) begin
				RVALID <= 1'b1;
				if(latched_r_addr < ADDRESS_WIDTH) begin
					/* Read After Write Operation is doing. 
						When both read and transaction is happing on the same time  on same address
						we are assiging the read data with the new write data and old data base on the strobe
					*/
					if ((w_next_state == GOT_BOTH || w_state==GOT_BOTH) && latched_aw_addr == latched_r_addr) begin
						for(ridx =0;ridx < STRB_WIDTH;ridx++) begin
							if(latched_w_strb[ridx]) begin
							  RDATA[ridx*8+:8] <= latched_w_data[ridx*8+:8];
							end else begin
							  RDATA[ridx*8+:8] <= mem[latched_aw_addr][ridx*8+:8];
							end
						end
					end else begin
						RDATA <= mem[latched_r_addr];
					end
					RRESP <= OKAY;
				end else begin
					RDATA <= '0; //If latched address is inavalid
					RRESP <= SLVERR;
				end
			end else if(RVALID && RREADY) begin
				RVALID <= 1'b0;
				RDATA <= '0;
				RRESP <= OKAY;
			end
		end
	end
	

endmodule