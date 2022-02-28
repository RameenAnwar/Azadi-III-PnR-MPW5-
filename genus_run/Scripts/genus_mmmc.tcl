create_library_set -name set_slow -timing { 
/merledu1/pdks-mpw3/pdk-new/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ss_100C_1v40.lib /merledu1/pdks-8July/sky130A/libs.ref/sky130_sram_macros/lib/sky130_sram_1kbyte_1rw1r_32x256_8_TT_1p8V_25C.lib}
#/home/sahmad/azadi_II_physical_design/sram_1024x32x4/sram_sp_hdc_svt_rvt_hvt_nldm_ss_0p90v_0p90v_125c_syn.lib
create_library_set -name set_fast -timing { 
/merledu1/pdks-mpw3/pdk-new/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ff_100C_1v95.lib /merledu1/pdks-8July/sky130A/libs.ref/sky130_sram_macros/lib/sky130_sram_1kbyte_1rw1r_32x256_8_TT_1p8V_25C.lib}
#/home/sahmad/azadi_II_physical_design/sram_1024x32x4/sram_sp_hdc_svt_rvt_hvt_nldm_ff_1p10v_1p10v_0c_syn.lib
#/home/sahmad/azadi_II_physical_design/sram_1024x32x4/sram_sp_hdc_svt_rvt_hvt_nldm_ff_1p10v_1p10v_125c_syn.lib
create_library_set -name set_typical -timing { 
/merledu1/pdks-mpw3/pdk-new/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib /merledu1/pdks-8July/sky130A/libs.ref/sky130_sram_macros/lib/sky130_sram_1kbyte_1rw1r_32x256_8_TT_1p8V_25C.lib
}
#/home/sahmad/azadi_II_physical_design/sram_1024x32x4/sram_sp_hdc_svt_rvt_hvt_nldm_tt_1p00v_1p00v_25c_syn.lib

create_opcond -name op_cond_slow    -process 1 -voltage 1.4 -temperature 100
create_opcond -name op_cond_fast    -process 1 -voltage 1.95 -temperature 100 
create_opcond -name op_cond_typical -process 1 -voltage 1.8 -temperature 25

create_timing_condition -name timing_cond_slow    -opcond op_cond_slow    -library_sets { set_slow }
create_timing_condition -name timing_cond_fast    -opcond op_cond_fast    -library_sets { set_fast }
create_timing_condition -name timing_cond_typical -opcond op_cond_typical -library_sets { set_typical }


#create_rc_corner -name rc_corner -cap_table /home/arm-pdk/ip/arm/tsmc/cln65gp/arm_tech/r4p0/cadence_captable/9M_6X2Z_rcworst.captbl

#create_rc_corner -name rc_corner -qrc_tech /home/arm-pdk/ip/arm/tsmc/cln65gplus/sc12_base_rvt/r3p0-00eac0/voltagestorm/CN65S_9M_6X2Z/CN65S_9M_6X2Z_tt_typical_max_1p00v_25c.cl/qrcTechFile_RCgen 

create_delay_corner -name delay_corner_slow -early_timing_condition timing_cond_slow \
                    -late_timing_condition timing_cond_slow 
                    #-early_rc_corner rc_corner \
                    #-late_rc_corner rc_corner

create_delay_corner -name delay_corner_fast -early_timing_condition timing_cond_fast \
                    -late_timing_condition timing_cond_fast 
                    #-early_rc_corner rc_corner \
                    #-late_rc_corner rc_corner

create_delay_corner -name delay_corner_typical -early_timing_condition timing_cond_typical \
                    -late_timing_condition timing_cond_typical 
                    #-early_rc_corner rc_corner \
                    #-late_rc_corner rc_corner

create_constraint_mode -name functional_slow -sdc_files { \
/home/ranwar/genus_runs/MPW5/azadi/constraints/constraints_fast.sdc
}

create_constraint_mode -name functional_fast -sdc_files { \
/home/ranwar/genus_runs/MPW5/azadi/constraints/constraints_slow.sdc
}

create_constraint_mode -name functional_typical -sdc_files { \
 /home/ranwar/genus_runs/MPW5/azadi/constraints/constraints_typical.sdc
}

create_analysis_view -name view_slow -constraint_mode functional_slow -delay_corner delay_corner_slow
create_analysis_view -name view_fast -constraint_mode functional_fast -delay_corner delay_corner_fast
create_analysis_view -name view_typical -constraint_mode functional_typical -delay_corner delay_corner_typical

set_analysis_view -setup {view_slow view_typical} -hold {view_typical view_fast}
