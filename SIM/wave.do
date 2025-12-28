onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /axi_top/axi_lite_inst/ACLKn
add wave -noupdate /axi_top/axi_lite_inst/ARESETn
add wave -noupdate -expand -group AW_Channel -radix unsigned /axi_top/axi_lite_inst/AWADDR
add wave -noupdate -expand -group AW_Channel /axi_top/axi_lite_inst/AWREADY
add wave -noupdate -expand -group AW_Channel /axi_top/axi_lite_inst/AWVALID
add wave -noupdate -expand -group AW_Channel -radix unsigned /axi_top/axi_lite_inst/latched_aw_addr
add wave -noupdate -expand -group AW_Channel /axi_top/axi_lite_inst/aw_hs
add wave -noupdate -expand -group W_Channel -radix unsigned /axi_top/axi_lite_inst/WSTRB
add wave -noupdate -expand -group W_Channel /axi_top/axi_lite_inst/WREADY
add wave -noupdate -expand -group W_Channel /axi_top/axi_lite_inst/WVALID
add wave -noupdate -expand -group W_Channel -radix unsigned /axi_top/axi_lite_inst/WDATA
add wave -noupdate -expand -group W_Channel -radix unsigned /axi_top/axi_lite_inst/latched_w_strb
add wave -noupdate -expand -group W_Channel -radix unsigned /axi_top/axi_lite_inst/latched_w_data
add wave -noupdate -expand -group W_Channel /axi_top/axi_lite_inst/w_hs
add wave -noupdate /axi_top/axi_lite_inst/w_state
add wave -noupdate /axi_top/axi_lite_inst/w_next_state
add wave -noupdate -expand -group B_Channel /axi_top/axi_lite_inst/BREADY
add wave -noupdate -expand -group B_Channel /axi_top/axi_lite_inst/BRESP
add wave -noupdate -expand -group B_Channel /axi_top/axi_lite_inst/BVALID
add wave -noupdate -expand -group AR_Channel -radix unsigned /axi_top/axi_lite_inst/ARADDR
add wave -noupdate -expand -group AR_Channel /axi_top/axi_lite_inst/ARREADY
add wave -noupdate -expand -group AR_Channel /axi_top/axi_lite_inst/ARVALID
add wave -noupdate -expand -group R_Channel /axi_top/axi_lite_inst/RRESP
add wave -noupdate -expand -group R_Channel -radix unsigned /axi_top/axi_lite_inst/RDATA
add wave -noupdate -expand -group R_Channel /axi_top/axi_lite_inst/RREADY
add wave -noupdate -expand -group R_Channel /axi_top/axi_lite_inst/RVALID
add wave -noupdate -expand -group R_Channel -radix unsigned /axi_top/axi_lite_inst/latched_r_addr
add wave -noupdate -expand -group R_Channel /axi_top/axi_lite_inst/ar_hs
add wave -noupdate -expand -group R_Channel /axi_top/axi_lite_inst/mem
add wave -noupdate /axi_top/axi_tb_inst/test.env.scrbd.ref_mem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3052 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {405 ns} {637 ns}
