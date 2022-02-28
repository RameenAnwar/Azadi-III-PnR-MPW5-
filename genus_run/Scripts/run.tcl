


if {[file exists /proc/cpuinfo]} {
  sh grep "model name" /proc/cpuinfo
  sh grep "cpu MHz"    /proc/cpuinfo
}

puts "Hostname : [info hostname]"

set DESIGN azadi_soc_top_caravel
set SYN_EFF high 
set MAP_EFF high
set OPT_EFF high

set RELEASE [lindex [get_db program_version] end]
set _OUTPUTS_PATH OUTPUT/outputs_${RELEASE}
set _REPORTS_PATH OUTPUT/reports_${RELEASE}

if {![file exists ${_OUTPUTS_PATH}]} {
  file mkdir ${_OUTPUTS_PATH}
  puts "Creating directory ${_OUTPUTS_PATH}"
}

if {![file exists ${_REPORTS_PATH}]} {
  file mkdir ${_REPORTS_PATH}
  puts "Creating directory ${_REPORTS_PATH}"
}


#set rtlDir ../rtl 

#set_db init_lib_search_path {. ../} 
set_db script_search_path { . } 
set_db init_hdl_search_path {/home/ranwar/Videos/Azadi_II_sky130/rtl_v0.0.0} 
#set_db init_lib_search_path {/merledu1/pdks-15June/sky130A/libs.ref/sky130_sram_macros/lib/}
#read_libs {sky130_sram_1kbyte_1rw1r_32x256_8_TT_1p8V_25C.lib}
set_db max_cpus_per_server 8 
set_db design_process_node 130
set_db use_tiehilo_for_const unique


set_db syn_generic_effort $SYN_EFF 
set_db syn_map_effort $MAP_EFF 
set_db syn_opt_effort $OPT_EFF 

set_db information_level 9 
set_db pbs_mmmc_flow true

#set_db tns_opto true 
#set_db lp_insert_clock_gating false 

## Reading in MMMC defination file and lef files
read_mmmc ../scripts/genus_mmmc.tcl

#read_physical -lef { \
# ../../lef/sky130_fd_sc_hd.tlef \
#../../lef/sky130_fd_sc_hd.lef \
#../../lef/sky130_sram_1kbyte_1rw1r_32x256_8.lef
#}


puts "Now load RTL"
set rtlList " \
tl_main_pkg.sv\
prim_util_pkg.sv\
fpnew_pkg.sv\
brq_pkg.sv\
registers.svh\
spi_defines.v\
gpio_reg_pkg.sv\
cf_math_pkg.sv\
rv_plic_reg_pkg.sv\
tlul_pkg.sv\
rv_timer_reg_pkg.sv\
defs_div_sqrt_mvp.sv\
brq_cs_registers.sv\

azadi_soc_top_caravel.sv\
fpnew_opgroup_multifmt_slice.sv\
prim_subreg.sv\
spi_shift.v\
azadi_soc_top.sv\
brq_register_file_ff.sv\
spi_top.sv\
brq_core.sv\
brq_wbu.sv\
fpnew_rounding.sv\
timer_core.sv\
brq_core_top.sv\
buffer_array.sv\
fpnew_top.sv\
pwm_top.sv\
brq_counter.sv\
buffer_control.sv\
pwm.v\
tlul_adapter_reg.sv\
gpio_reg_top.sv\
tlul_err_resp.sv\
brq_csr.sv\
control_mvp.sv\
gpio.sv\
rr_arb_tree.sv\
tlul_err.sv\
brq_exu_alu.sv\
data_mem_top.sv\
iccm_controller.v\
rstmgr.sv\
tlul_fifo_sync.sv\
brq_exu_multdiv_fast.sv\
instr_mem_top.sv\
rv_plic_gateway.sv\
tlul_host_adapter.sv\
brq_exu_multdiv_slow.sv\
div_sqrt_top_mvp.sv\
iteration_div_sqrt_mvp.sv\
brq_exu.sv\
fifo_async.sv\
lzc.sv\
rv_plic_reg_top.sv\
tlul_socket_1n.sv\
brq_fp_register_file_ff.sv\
fifo_sync.sv\
norm_div_sqrt_mvp.sv\
rv_plic.sv\
tlul_sram_adapter.sv\
brq_idu_controller.sv\
fpnew_cast_multi.sv\
nrbd_nrsc_mvp.sv\
rv_plic_target.sv\
tl_xbar_main.sv\
brq_idu_decoder.sv\
fpnew_classifier.sv\
preprocess_mvp.sv\
uart_core.sv\
brq_idu.sv\
fpnew_divsqrt_multi.sv\
prim_filter_ctr.sv\
rv_timer_reg_top.sv\
uart_rx_prog.v\
brq_ifu_compressed_decoder.sv\
fpnew_fma_multi.sv\
prim_clock_gating.sv\
rv_timer.sv\
uart_rx.v\
brq_ifu_fifo.sv\
fpnew_fma.sv\
prim_intr_hw.sv\
rx_timer.sv\
uart_top.sv\
brq_ifu_prefetch_buffer.sv\
fpnew_noncomp.sv\
spi_clgen.v\
uart_tx.v\
brq_ifu.sv\
fpnew_opgroup_block.sv\
prim_subreg_arb.sv\
spi_core.sv\
brq_lsu.sv\
fpnew_opgroup_fmt_slice.sv\
prim_subreg_ext.sv\
sram_32x1024.sv\
generic_fifo.sv
"

# Reading hdl files, initialize the database and elaborating them
read_hdl -language sv $rtlList
elaborate $DESIGN
#read_def ../DEF/dtmf.def

init_design
time_info init_design
check_design -unresolved
##suspend

####################################################################################################
## Optimization settings
####################################################################################################

set_db [get_db lib_cells */sky130_fd_sc_hd__a2111oi_*] .dont_use true
set_db [get_db lib_cells */sky130_fd_sc_hd__buf_16*] .dont_use true
set_db [get_db lib_cells */sky130_fd_sc_hd__probe*] .dont_use true


####################################################################################################
## Cost and path groups
####################################################################################################

 # define_cost_group -name I2C -design $DESIGN
 # define_cost_group -name C2O -design $DESIGN
 # define_cost_group -name C2C -design $DESIGN
 # path_group -view view_fast -from [all_registers] -to [all_registers] -group C2C -name C2C
 # path_group -view view_typical -from [all_registers] -to [all_outputs] -group C2O -name C2O
 # path_group -view view_slow -from [all_inputs]  -to [all_registers] -group I2C -name I2C

##suspend

push_snapshot_stack
####################################################################################################
## Synthesizing the design
####################################################################################################

syn_generic

write_snapshot -outdir $_OUTPUTS_PATH -tag syn_generic 
summary_table -directory $_REPORTS_PATH
puts "Runtime & Memory after 'syn_generic'"
time_info GENERIC

pop_snapshot_stack

create_snapshot -name syngen
#suspend

push_snapshot_stack

syn_map

write_snapshot -outdir $_OUTPUTS_PATH -tag syn_map 
summary_table -directory $_REPORTS_PATH
puts "Runtime & Memory after 'syn_map'"
time_info MAPPED

pop_snapshot_stack
create_snapshot -name synmap
#suspend

push_snapshot_stack

syn_opt

## generate reports to save the Innovus stats
write_snapshot -innovus -outdir $_OUTPUTS_PATH -tag syn_opt
summary_table -directory $_REPORTS_PATH
puts "Runtime & Memory after syn_opt"
write_netlist > azadi.v
time_info OPT

report_area > area.rpt
report_timing > timing.rpt

pop_snapshot_stack
create_snapshot -name synopt
#suspend

## write out the final database
write_db -to_file ${DESIGN}.db

puts "Final Runtime & Memory."
time_info FINAL
puts "============================"
puts "Synthesis Finished ........."
puts "============================"

report_metric -id "results" -format vivid -file synthesis.html 

#quit
