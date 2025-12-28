
`include "axi_test.sv"

module axi_tb(axi_if vif);
	
	basetest test;
	
	initial begin
		test = new(vif);
		test.run();
	end
	
endmodule