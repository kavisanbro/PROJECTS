`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/18/2026 04:56:43 PM
// Design Name: 
// Module Name: axi4_lite_slave
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//==============================================================================
`timescale 1ns / 1ps

module axi4_lite_slave (
    input  wire        ACLK,
    input  wire        ARESETn,

    input  wire [31:0] AWADDR,
    input  wire        AWVALID,
    output reg         AWREADY,

    input  wire [31:0] WDATA,
    input  wire [3:0]  WSTRB,
    input  wire        WVALID,
    output reg         WREADY,

    output reg  [1:0]  BRESP,
    output reg         BVALID,
    input  wire        BREADY,

    input  wire [31:0] ARADDR,
    input  wire        ARVALID,
    output reg         ARREADY,

    output reg  [31:0] RDATA,
    output reg  [1:0]  RRESP,
    output reg         RVALID,
    input  wire        RREADY,

    output reg         reg_enable,
    output reg         reg_start,
    output reg         reg_cpol,
    output reg         reg_cpha,
    output reg  [7:0]  reg_txdata,
    output reg  [7:0]  reg_clkdiv,
    input  wire        spi_busy,
    input  wire        spi_done,
    input  wire [7:0]  spi_rxdata
);

    localparam RESP_OKAY   = 2'b00;
    localparam RESP_SLVERR = 2'b10;

    localparam ADDR_CTRL   = 4'h0;
    localparam ADDR_STATUS = 4'h1;
    localparam ADDR_TXDATA = 4'h2;
    localparam ADDR_RXDATA = 4'h3;
    localparam ADDR_CLKDIV = 4'h4;

    wire [3:0] aw_word = AWADDR[5:2];
    wire [3:0] ar_word = ARADDR[5:2];

    //--------------------------------------------------------------------------
    // Write channel
    //--------------------------------------------------------------------------
    reg        aw_seen;
    reg        w_seen;
    reg [3:0]  aw_word_r;
    reg [31:0] wdata_r;
    reg [3:0]  wstrb_r;

    // Latched write request for register file (one-cycle pulse)
    reg        wr_en;
    reg [3:0]  wr_addr;
    reg [31:0] wr_data;
    reg [3:0]  wr_strb;

    wire aw_fire = AWVALID & AWREADY;
    wire w_fire  = WVALID  & WREADY;
    wire b_fire  = BVALID  & BREADY;

    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            AWREADY  <= 1'b1;
            WREADY   <= 1'b1;
            BVALID   <= 1'b0;
            BRESP    <= RESP_OKAY;
            aw_seen  <= 1'b0;
            w_seen   <= 1'b0;
            aw_word_r<= 4'h0;
            wdata_r  <= 32'h0;
            wstrb_r  <= 4'h0;
            wr_en    <= 1'b0;
            wr_addr  <= 4'h0;
            wr_data  <= 32'h0;
            wr_strb  <= 4'h0;
        end else begin
            wr_en <= 1'b0;

            if (aw_fire) begin
                aw_seen   <= 1'b1;
                aw_word_r <= aw_word;
                AWREADY   <= 1'b0;
            end

            if (w_fire) begin
                w_seen  <= 1'b1;
                wdata_r <= WDATA;
                wstrb_r <= WSTRB;
                WREADY  <= 1'b0;
            end

            // Commit when both phases seen (including same-cycle fires)
            if (!BVALID && (aw_seen || aw_fire) && (w_seen || w_fire)) begin
                aw_seen <= 1'b0;
                w_seen  <= 1'b0;
                AWREADY <= 1'b0;
                WREADY  <= 1'b0;
                BVALID  <= 1'b1;

                wr_en   <= 1'b1;
                wr_addr <= aw_fire ? aw_word : aw_word_r;
                wr_data <= w_fire  ? WDATA  : wdata_r;
                wr_strb <= w_fire  ? WSTRB  : wstrb_r;

                case (aw_fire ? aw_word : aw_word_r)
                    ADDR_CTRL, ADDR_TXDATA, ADDR_CLKDIV:
                        BRESP <= RESP_OKAY;
                    default:
                        BRESP <= RESP_SLVERR;
                endcase
            end

            if (b_fire) begin
                BVALID  <= 1'b0;
                AWREADY <= 1'b1;
                WREADY  <= 1'b1;
            end
        end
    end

    // Register file
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            reg_enable <= 1'b0;
            reg_start  <= 1'b0;
            reg_cpol   <= 1'b0;
            reg_cpha   <= 1'b0;
            reg_txdata <= 8'h00;
            reg_clkdiv <= 8'd3;
        end else begin
            if (spi_busy)
                reg_start <= 1'b0;

            if (wr_en) begin
                case (wr_addr)
                    ADDR_CTRL: begin
                        if (wr_strb[0]) begin
                            reg_enable <= wr_data[0];
                            if (wr_data[1])
                                reg_start <= 1'b1;
                            reg_cpol <= wr_data[2];
                            reg_cpha <= wr_data[3];
                        end
                    end
                    ADDR_TXDATA: begin
                        if (wr_strb[0])
                            reg_txdata <= wr_data[7:0];
                    end
                    ADDR_CLKDIV: begin
                        if (wr_strb[0])
                            reg_clkdiv <= wr_data[7:0];
                    end
                    default: ;
                endcase
            end
        end
    end

    //--------------------------------------------------------------------------
    // Read channel
    //--------------------------------------------------------------------------
    wire ar_fire = ARVALID & ARREADY;
    wire r_fire  = RVALID  & RREADY;

    wire [31:0] status_word = {29'd0, (~spi_busy & reg_enable), spi_done, spi_busy};

    reg [31:0] rdata_mux;
    always @(*) begin
        case (ar_word)
            ADDR_CTRL:   rdata_mux = {28'd0, reg_cpha, reg_cpol, reg_start, reg_enable};
            ADDR_STATUS: rdata_mux = status_word;
            ADDR_TXDATA: rdata_mux = {24'd0, reg_txdata};
            ADDR_RXDATA: rdata_mux = {24'd0, spi_rxdata};
            ADDR_CLKDIV: rdata_mux = {24'd0, reg_clkdiv};
            default:     rdata_mux = 32'hDEAD_BEEF;
        endcase
    end

    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            ARREADY <= 1'b1;
            RVALID  <= 1'b0;
            RDATA   <= 32'h0;
            RRESP   <= RESP_OKAY;
        end else begin
            if (ar_fire) begin
                ARREADY <= 1'b0;
                RVALID  <= 1'b1;
                RDATA   <= rdata_mux;
                case (ar_word)
                    ADDR_CTRL, ADDR_STATUS, ADDR_TXDATA, ADDR_RXDATA, ADDR_CLKDIV:
                        RRESP <= RESP_OKAY;
                    default:
                        RRESP <= RESP_SLVERR;
                endcase
            end

            if (r_fire) begin
                RVALID  <= 1'b0;
                ARREADY <= 1'b1;
            end
        end
    end

endmodule
