
// define none or one of:
`ifdef BOARD_ULX3S_V20
`define i2c_bridge_v20
`endif
`ifdef BOARD_ULX3S_V314
`define i2c_bridge_v316
`endif
`ifdef BOARD_ULX3S_V317
`define i2c_bridge_v316
`endif

`default_nettype none

module top
(
	// Clock
	input  wire clk_25mhz,

	// LEDs
	output wire [3:0] led,

	// Buttons
	input  wire [6:0] btn,
	
	// Debug or esp32 passthru UART
	input  wire ftdi_txd,
	output wire ftdi_rxd,

	// SPI Flash
	inout  wire flash_mosi,
	inout  wire flash_miso,
	inout  wire flash_wpn,
	inout  wire flash_holdn,
	inout  wire flash_csn,

	// Boot
	inout  wire user_programn
);

	wire [7:0] led8; // only lower 4 LEDs
	//assign led = led8[3:0];
	//assign led = {wifi_gpio15, wifi_gpio14, wifi_gpio13, wifi_gpio12}; // debug SD card
	wire ftdi_ndtr = 1'b1, ftdi_nrts = 1'b1, sd_wp; // not used

	// ecp5wp.py needs this
	// for some boards with IS25LP128	
	assign flash_csn   = 1;
	assign flash_holdn = 1;

endmodule // top
