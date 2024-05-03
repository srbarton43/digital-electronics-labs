## This file is a general .xdc for the Basys3 rev B board for ENGS31/CoSc56
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project
## - these names should match the external ports (_ext_port) in the entity declaration of your shell/top level

##====================================================================
## External_Clock_Port
##====================================================================
## This is a 100 MHz external clock
set_property PACKAGE_PIN W5 [get_ports clk_ext_port]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk_ext_port]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk_ext_port]

##====================================================================
## Switch_ports
##====================================================================
## SWITCH 0 (RIGHT MOST SWITCH)
set_property PACKAGE_PIN V17 [get_ports right_ext_port]					
	set_property IOSTANDARD LVCMOS33 [get_ports right_ext_port]
set_property PACKAGE_PIN R2 [get_ports left_ext_port]					
	set_property IOSTANDARD LVCMOS33 [get_ports left_ext_port]
 
##====================================================================
## LED_ports
##====================================================================
## LED 0 (RIGHT MOST LED)
set_property PACKAGE_PIN U16 [get_ports RC_ext_port]					
	set_property IOSTANDARD LVCMOS33 [get_ports RC_ext_port]
## LED 1
set_property PACKAGE_PIN E19 [get_ports RB_ext_port]					
  set_property IOSTANDARD LVCMOS33 [get_ports RB_ext_port]
## LED 2
set_property PACKAGE_PIN U19 [get_ports RA_ext_port]					
	set_property IOSTANDARD LVCMOS33 [get_ports RA_ext_port]
## LED 13
set_property PACKAGE_PIN N3 [get_ports LA_ext_port]					
	set_property IOSTANDARD LVCMOS33 [get_ports LA_ext_port]
## LED 14
set_property PACKAGE_PIN P1 [get_ports LB_ext_port]					
	set_property IOSTANDARD LVCMOS33 [get_ports LB_ext_port]
## LED 15 (LEFT MOST LED)
set_property PACKAGE_PIN L1 [get_ports LC_ext_port]					
	set_property IOSTANDARD LVCMOS33 [get_ports LC_ext_port]

##====================================================================
## Implementation Assist
##====================================================================	
## These additional constraints are recommended by Digilent, DO NOT REMOVE!
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
