# settings begin here
# defines tech node as 7nm
if {$VERSION <= 19} {
	setDesignMode -process 7 
} else {
	setDesignMode -process 7 -node N7
}

# let's limit to 8 CPU cores
setMultiCpuUsage -localCpu 8

if {$VERSION <= 20} {
	setNanoRouteMode -routeBottomRoutingLayer 2
	setNanoRouteMode -routeTopRoutingLayer 7
} else {
	setDesignMode -bottomRoutingLayer 2
	setDesignMode -topRoutingLayer 7
}

#this is the VDD for the std cells
globalNetConnect VDD -type pgpin -pin VDD -inst * 

# and the VSS
globalNetConnect VSS -type pgpin -pin VSS -inst * 

set FP_RING_OFFSET 0.384
set FP_RING_WIDTH 2.176
set FP_RING_SPACE 0.384
set FP_RING_SIZE [expr {$FP_RING_SPACE + 2*$FP_RING_WIDTH + $FP_RING_OFFSET + 1.1}]
set FP_TARGET 177
set FP_MUL 5
# important: these numbers cannot be chosen arbitrarily, otherwise all VDD/VSS stripes are offgrid or there are no valid vias that can drop on them 
# FP_TARGET is the only variable you can freely modify. this one determines the number of standard cell rows in your design
# FP_MUL controls the aspect ratio. FP_MUL = 5 gives you a perfectly square design
# the additional 1.1 is to account for situations where innovus snaps the fplan and the space becomes too narrow to fit the rings

set cellheight [expr 0.270 * 4]
set cellhgrid  0.216

set fpxdim [expr $cellhgrid * $FP_TARGET * $FP_MUL]
set fpydim [expr $cellheight * $FP_TARGET]

# this will set the floorplan according to the settings defined above. you can play with the FP_TARGET variable and get different results
# also try floorplan -help for more details about the command
floorPlan -site asap7sc7p5t -s $fpxdim $fpydim $FP_RING_SIZE $FP_RING_SIZE $FP_RING_SIZE $FP_RING_SIZE -noSnap

