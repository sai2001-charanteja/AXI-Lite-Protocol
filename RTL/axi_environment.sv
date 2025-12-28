//`include "axi_packet.sv"
import axi_pkg::*;
`include "axi_generator.sv"
`include "axi_driver.sv"
`include "axi_imonitor.sv"
`include "axi_omonitor.sv"
`include "axi_scoreboard.sv"

class axi_environment;

	virtual axi_if.drvr_mp vif;
	virtual axi_if.mon_mp imon_vif;
	virtual axi_if.mon_mp omon_vif;
	
	mailbox#(axi_packet) mbx; //Communication between the Generator and Driver
	mailbox #(axi_packet) irmbx,iwmbx;
	mailbox #(axi_packet) ombx;

	axi_generator gen;
	axi_driver drvr;
	axi_imonitor imon;
	axi_omonitor omon;
	axi_scoreboard scrbd;
	bit [31:0]no_of_pkts;
	
	function new(virtual axi_if.drvr_mp vif,virtual axi_if.mon_mp ivif, virtual axi_if.mon_mp ovif,bit [31:0]no_of_pkts);
		this.vif = vif;
		this.imon_vif = ivif;
		this.omon_vif = ovif;
		this.no_of_pkts = no_of_pkts;
	endfunction
	
	function void build();
		$display("[%0t][ENVIRONMENT-Build] Started",$time);
		mbx = new(1);
		irmbx = new(1);
		iwmbx = new(1);
		ombx = new(1);

		gen = new(mbx,no_of_pkts);
		drvr = new(mbx,vif);
		imon = new(irmbx,iwmbx,imon_vif);
		omon = new(ombx,omon_vif);
		scrbd = new(irmbx,iwmbx,ombx);
		$display("[%0t][ENVIRONMENT-Build] Finished",$time);
	endfunction
	
	task  run();
		build();
		$display("[%0t][Environment] Run started",$time);
		
		fork
			gen.run();
			drvr.run();
			imon.run();
			omon.run();
			scrbd.run();
		join_any

		#100;
		scrbd.printResults();
		$finish;
		$display("[%0t][Environment] Run finished",$time);
	endtask

endclass