set RTL_PATH		"../rtl/"
set LIB_PATH 		"../lib/"
set LEF_PATH		"../lef/scaled/"
set TLEF_PATH		"../techlef/"
set QRC_PATH 		"../qrc/"
set DESIGN 		"sha256"

set LIB_LIST {  asap7sc7p5t_AO_LVT_TT_nldm_211120.lib   asap7sc7p5t_INVBUF_LVT_TT_nldm_220122.lib   asap7sc7p5t_OA_LVT_TT_nldm_211120.lib   asap7sc7p5t_SEQ_LVT_TT_nldm_220123.lib   asap7sc7p5t_SIMPLE_LVT_TT_nldm_211120.lib }

set LEF_LIST { asap7_tech_4x_201209.lef asap7sc7p5t_28_L_4x_220121a.lef asap7sc7p5t_28_R_4x_220121a.lef asap7sc7p5t_28_SL_4x_220121a.lef}

set QRC_FILE "qrcTechFile_typ03_scaled4xV06"

set RTL_LIST {sha256_pipe.v sha256_core.v sha256_k_constants.v sha256_w_mem.v}

set_db init_lib_search_path "$LIB_PATH $LEF_PATH $TLEF_PATH"
set_db init_hdl_search_path $RTL_PATH 
set_db / .library "$LIB_LIST"
set_db lef_library "$LEF_LIST"
set_db qrc_tech_file "$QRC_PATH/$QRC_FILE"

set_db syn_generic_effort high
set_db syn_map_effort     high
set_db syn_opt_effort	  extreme

set_db lp_power_analysis_effort high
set_db power_optimization_effort high
set_db design_power_effort high

suppress_messages {LBR-30 LBR-31 LBR-40 LBR-41 LBR-72 LBR-77 LBR-162}

set_db lp_insert_clock_gating true 


set_dont_use AOI22xp33_ASAP7_75t_L true
set_dont_use AOI22xp33_ASAP7_75t_SL true
set_dont_use AOI22xp33_ASAP7_75t_R true


read_hdl ${RTL_LIST}
elaborate $DESIGN

set_db design:sha256 .retime true

#create_clock -name "clk" -period 706 [get_ports clk]

create_clock -name "clk" -period 686 [get_ports clk]


set_input_delay -clock clk 300 [all_inputs]
set_output_delay -clock clk 300 [all_outputs]

syn_generic
syn_map
syn_opt

syn_opt -incremental

write_hdl > $DESIGN.netlist.v

report clocks > ./$DESIGN.clocks.rep
report timing > ./$DESIGN.timing.rep
report area   > ./$DESIGN.area.rep
report gates  > ./$DESIGN.gates.rep
report power  > ./$DESIGN.power.rep


