import axi_pkg::*;

module axi_top;
	logic ACLKn;
	
	axi_if vif(ACLKn);

	always #5 ACLKn = !ACLKn;


	axi_lite axi_lite_inst
	(
	  .ACLKn(ACLKn),
	  .ARESETn(vif.ARESETn),
	  .AWVALID(vif.AWVALID), 
	  .AWREADY(vif.AWREADY), 
	  .AWADDR(vif.AWADDR), 
	  .WVALID(vif.WVALID), 
	  .WREADY(vif.WREADY), 
	  .WDATA(vif.WDATA),
	  .WSTRB(vif.WSTRB), 
	  .BVALID(vif.BVALID), 
	  .BREADY(vif.BREADY),
	  .BRESP(vif.BRESP), 
	  .ARVALID(vif.ARVALID), 
	  .ARREADY(vif.ARREADY), 
	  .ARADDR(vif.ARADDR),
	  .RVALID(vif.RVALID), 
	  .RREADY(vif.RREADY), 
	  .RDATA(vif.RDATA), 
	  .RRESP(vif.RRESP)
	);
		

	axi_tb axi_tb_inst(vif); 

  	initial begin
		ACLKn = 0;
    end
  
	
	
	initial begin
		$dumpfile("axi.vcd");
		$dumpvars();
	end
  
endmodule