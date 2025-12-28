vlib work
vdel -all
vlib work

vlog -sv -f $1.list +acc

vsim axi_top -l Transcript.log
#add wave -r *
do wave.do
run -all