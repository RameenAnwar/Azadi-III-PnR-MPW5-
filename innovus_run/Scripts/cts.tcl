##Configure your CCopt run by providing the correct constraints.

#set_ccopt_property primary_delay_corner <primary_delay_corner>
#set_ccopt_property -target_max_trans 1ns

#set_db target_max_trans 1ns
#set_ccopt_property -target_skew 2ns

#set_db target_skew 2ns
#set_ccopt_property route_type_autotrim false

#set_db route_type_autotrim false
#setAnalysisMode -analysisType onChipVariation

#set_analysis_mode -analysis_type on_chip_variation
#Setting stop pins
#### You can add shielding to the nets using the "-shield_net <netName>" option and can also specify the shielding side as "-shield_side one_side". These are optional.
#
create_route_type -name TOP -top_preferred_layer 3 -bottom_preferred_layer 1  -preferred_routing_layer_effort high
create_route_type -name TRUNK  -top_preferred_layer 3 -bottom_preferred_layer 1 -preferred_routing_layer_effort high  
create_route_type -name LEAF -top_preferred_layer 3 -bottom_preferred_layer 1 -preferred_routing_layer_effort high
#
#set_ccopt_property route_type TOP -net_type top
#set_db cts_route_type_leaf LEAF
#set_ccopt_property route_type TRUNK -net_type trunk
#set_db cts_route_type_trunk TRUNK
#set_ccopt_property route_type LEAF -net_type leaf
#   
#   #Creating clock tree spec. 
#
   create_clock_tree_spec -out_file ccopt.spec
   source ccopt.spec
#
#   #Creating Flexible HTree Network.
#   ##You can tune the switches present in create_ccopt_flexible_htree based on your requirement.
#
  # create_ccopt_flexible_htree -name flex_HTREE -trunk_cell sky130_fd_sc_hd__clkbuf_16 -final_cell sky130_fd_sc_hd__clkbuf_4 -no_symmetry_buffers -sink_instance_prefix HJ -pin wb_clk_i -sink_grid {4 4}
  # synthesize_ccopt_flexible_htrees
  # set_ccopt_property extract_balance_multi_source_clocks true
#
#   NOTE: The command option -no_symmetry_buffers has been changed to -omit_symmetry in Innovus 20.1. The option being used works with present version of Innovus and will be obsoleted in a future release.
#
#   #Setting up the cell list for the connection from the tap point to all sinks.
#   ##MS CTS FLOW
#
   set_db cts_buffer_cells {sky130_fd_sc_hd__clkbuf_16 sky130_fd_sc_hd__clkbuf_8 sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_2 sky130_fd_sc_hd__clkbuf_1}
  # set_ccopt_property buffer_cells {sky130_fd_sc_hd__clkbuf_16 sky130_fd_sc_hd__clkbuf_8 sky130_fd_sc_hd__clkbuf_4}
  # set_ccopt_property leaf_buffer_cells {sky130_fd_sc_hd__clkbuf_8 sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_2 sky130_fd_sc_hd__clkbuf_1}
#
   set_db cts_inverter_cells {sky130_fd_sc_hd__clkinv_16 sky130_fd_sc_hd__clkinv_8 sky130_fd_sc_hd__clkinv_4 sky130_fd_sc_hd__clkinv_2 sky130_fd_sc_hd__clkinv_1}
  # set_ccopt_property inverter_cells {sky130_fd_sc_hd__clkinv_16 sky130_fd_sc_hd__clkinv_8 sky130_fd_sc_hd__clkinv_4}
 #  set_ccopt_property leaf_inverter_cells {sky130_fd_sc_hd__clkinv_8 sky130_fd_sc_hd__clkinv_4 sky130_fd_sc_hd__clkinv_2 sky130_fd_sc_hd__clkinv_1}
#
   set_db cts_clock_gating_cells {sky130_fd_sc_hd__dlclkp_4 sky130_fd_sc_hd__dlclkp_2 sky130_fd_sc_hd__dlclkp_1}
#   set_ccopt_property clock_logic_cells {CKMUX4 CKMUX8 CKANDX4 CKANDX8 CKNANDX4 CKNANDX8 CKNORX4 CKNORX8 CKORX4 CKORX8 CKXORX4 CKXORX8 OAI221X8 OAI221X4 AOI22VYX1 OAI31X8}
#
#   #Setting dont touch as false on all the clock gates so that the root allocation [assignment of the sink with respect to each tap point] is proper.
#
  # foreach i [get_ccopt_clock_tree_cells -node_types clock_gate] {
  #    set_db inst:$i .dont_touch false
  #    }
#
#      #Use the following two commands if you want to enable cloning in your runs. The default behavior is "False".
#
 #     set_db clone_clock_gates true
  #    set_db clone_clock_logic true
#
    #  set_ccopt_property route_type TOP -net_type top
    #  set_ccopt_property route_type TRUNK -net_type trunk
    #  set_ccopt_property route_type LEAF -net_type leaf
#
      set_db cts_clock_gate_movement_limit 100000
      ccopt_design
#       
#       saveDesign <FileName>
