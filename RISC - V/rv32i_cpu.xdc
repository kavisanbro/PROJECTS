## Basys 3 (Artix-7 XC7A35T) - pipelined RV32I + UART

## Clock 100 MHz
set_property PACKAGE_PIN W5 [get_ports clk_100mhz]
set_property IOSTANDARD LVCMOS33 [get_ports clk_100mhz]
create_clock -period 10.000 -name sys_clk -waveform {0.000 5.000} [get_ports clk_100mhz]

## Reset button (center)
set_property PACKAGE_PIN U18 [get_ports rst_btn]
set_property IOSTANDARD LVCMOS33 [get_ports rst_btn]

## UART - USB-UART bridge (JA or built-in, Basys3 TX = JA3 / pin D4)
set_property PACKAGE_PIN A16 [get_ports uart_txd]
set_property IOSTANDARD LVCMOS33 [get_ports uart_txd]

## LEDs
set_property PACKAGE_PIN U16 [get_ports {led[0]}]
set_property PACKAGE_PIN E19 [get_ports {led[1]}]
set_property PACKAGE_PIN U19 [get_ports {led[2]}]
set_property PACKAGE_PIN V19 [get_ports {led[3]}]
set_property PACKAGE_PIN W18 [get_ports {led[4]}]
set_property PACKAGE_PIN U15 [get_ports {led[5]}]
set_property PACKAGE_PIN U14 [get_ports {led[6]}]
set_property PACKAGE_PIN V14 [get_ports {led[7]}]
set_property PACKAGE_PIN V13 [get_ports {led[8]}]
set_property PACKAGE_PIN V3  [get_ports {led[9]}]
set_property PACKAGE_PIN W3  [get_ports {led[10]}]
set_property PACKAGE_PIN U3  [get_ports {led[11]}]
set_property PACKAGE_PIN P3  [get_ports {led[12]}]
set_property PACKAGE_PIN N3  [get_ports {led[13]}]
set_property PACKAGE_PIN P1  [get_ports {led[14]}]
set_property PACKAGE_PIN L1  [get_ports {led[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

## 7-segment (disabled in design - constrain to avoid DRC)
set_property PACKAGE_PIN W7  [get_ports {seg[0]}]
set_property PACKAGE_PIN W6  [get_ports {seg[1]}]
set_property PACKAGE_PIN U8  [get_ports {seg[2]}]
set_property PACKAGE_PIN V8  [get_ports {seg[3]}]
set_property PACKAGE_PIN U5  [get_ports {seg[4]}]
set_property PACKAGE_PIN V5  [get_ports {seg[5]}]
set_property PACKAGE_PIN U7  [get_ports {seg[6]}]
set_property PACKAGE_PIN V7  [get_ports {seg[7]}]
set_property PACKAGE_PIN U2  [get_ports {an}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports an]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
