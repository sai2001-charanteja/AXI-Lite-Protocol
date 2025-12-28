import axi_pkg::*;

interface axi_if(input clk);
  	//AW Channel: Write Address
 	//Direction: Manager → Subordinate
	
	logic ARESETn ;
	
	logic AWVALID ; // Address is valid
	logic AWREADY ; // Subordinate is ready to accept address
  	logic [ADDRESS_WIDTH-1:0]AWADDR ; // The write address (typically 32-bit)
  
  	//W Channel: Write Data
	//Direction: Manager → Subordinate
  
	logic WVALID; // Data is valid
	logic WREADY; // Subordinate is ready to accept data
	logic [DATA_WIDTH-1:0]WDATA ; // The write data (typically 32-bit)
  	logic [STRB_WIDTH-1:0]WSTRB ; // Write strobes (which bytes are valid)
  
  	//B Channel: Write Response
	//The Subordinate sends a response confirming the write operation completed.
	//Direction: Subordinate → Manager
	logic BVALID; // - Response is valid
	logic BREADY; // - Manager is ready to accept response
	respCode BRESP ; // - Response code (OKAY, EXOKAY, SLVERR, DECERR)
  		
  	//AR Channel: Read Address
	//The Manager sends the address from which data should be read.
	//Direction: Manager → Subordinate
	logic ARVALID ; // - Address is valid
	logic ARREADY ; // - Subordinate is ready to accept address
  	logic [ADDRESS_WIDTH-1:0] ARADDR; //- The read address (typically 32-bit)
  
  	//R Channel: Read Data
	//The Subordinate sends the requested data along with a response code.
	//Direction: Subordinate → Manager
	logic RVALID ; //- Data is valid
	logic RREADY ; //- Manager is ready to accept data
	logic [DATA_WIDTH-1:0]RDATA  ; //- The read data (typically 32-bit)
	respCode RRESP  ; //- Response code (OKAY, EXOKAY, SLVERR, DECERR)
  
	
	clocking cb @(posedge clk);
		output AWVALID, AWADDR, WVALID, WDATA, WSTRB, BREADY, ARVALID, ARADDR,RREADY ; 
		input AWREADY,WREADY,BVALID, BRESP, ARREADY,RVALID,RDATA,RRESP;
	endclocking
  
	clocking cb_mon @(posedge clk);
		input AWVALID, AWADDR, WVALID, WDATA, WSTRB, BREADY, ARVALID, ARADDR,RREADY ; 
		input AWREADY,WREADY,BVALID, BRESP, ARREADY,RVALID,RDATA,RRESP;
	endclocking
	
	modport mon_mp(clocking cb_mon);
	
	modport drvr_mp(clocking cb, output ARESETn);

	
	
  
endinterface
