create_project systolic_mult ./systolic_mult -part xc7z020clg400-1
set_property board_part www.digilentinc.com:pynq-z1:part0:1.0 [current_project]
read_verilog counter.v
read_verilog pe.v
read_verilog systolic.sv
read_xdc systolic.xdc
synth_design -top systolic -mode out_of_context;
opt_design; place_design; route_design; report_utilization; report_timing;
report_utilization -file utilization.txt
report_timing -file timing.txt