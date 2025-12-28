`include "axi_environment.sv"
class basetest;
	
	axi_environment env;
	virtual axi_if vif;
	
	bit [31:0] no_of_pkts;
	
	function new(virtual axi_if vif);
		this.vif = vif;
	endfunction
	
	task build();
		$display("[%0t][Test] Build started",$time);
		no_of_pkts = 1000;
		env = new(vif,vif,vif,no_of_pkts);
		$display("[%0t][Test] Build finished",$time);
	endtask
	
	task  run();
		build();
		$display("[%0t] [TEST] Run started",$time);
		env.run();
		$display("[%0t] [TEST] Run finished",$time);
	endtask
	

endclass