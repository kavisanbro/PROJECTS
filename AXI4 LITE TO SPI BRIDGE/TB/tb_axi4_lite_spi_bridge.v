
`timescale 1ns / 1ps

module tb_axi4_lite_spi_bridge;

    //--------------------------------------------------------------------------
    // Clock / reset
    //--------------------------------------------------------------------------
    reg         ACLK;
    reg         ARESETn;

    // AXI4-Lite
    reg  [31:0] AWADDR;
    reg         AWVALID;
    wire        AWREADY;
    reg  [31:0] WDATA;
    reg  [3:0]  WSTRB;
    reg         WVALID;
    wire        WREADY;
    wire [1:0]  BRESP;
    wire        BVALID;
    reg         BREADY;
    reg  [31:0] ARADDR;
    reg         ARVALID;
    wire        ARREADY;
    wire [31:0] RDATA;
    wire [1:0]  RRESP;
    wire        RVALID;
    reg         RREADY;

    // SPI
    wire        SCLK;
    wire        MOSI;
    wire        MISO;
    wire        CS_N;

    // Register offsets
    localparam ADDR_CTRL   = 32'h00;
    localparam ADDR_STATUS = 32'h04;
    localparam ADDR_TXDATA = 32'h08;
    localparam ADDR_RXDATA = 32'h0C;
    localparam ADDR_CLKDIV = 32'h10;

    // CTRL bits
    localparam CTRL_ENABLE = 32'h01;
    localparam CTRL_START  = 32'h02;
    localparam CTRL_CPOL   = 32'h04;
    localparam CTRL_CPHA   = 32'h08;

    integer errors;
    integer passes;
    reg [31:0] rd_data;

    //--------------------------------------------------------------------------
    // DUT
    //--------------------------------------------------------------------------
    axi4_lite_spi_bridge dut (
        .ACLK    (ACLK),
        .ARESETn (ARESETn),
        .AWADDR  (AWADDR),
        .AWVALID (AWVALID),
        .AWREADY (AWREADY),
        .WDATA   (WDATA),
        .WSTRB   (WSTRB),
        .WVALID  (WVALID),
        .WREADY  (WREADY),
        .BRESP   (BRESP),
        .BVALID  (BVALID),
        .BREADY  (BREADY),
        .ARADDR  (ARADDR),
        .ARVALID (ARVALID),
        .ARREADY (ARREADY),
        .RDATA   (RDATA),
        .RRESP   (RRESP),
        .RVALID  (RVALID),
        .RREADY  (RREADY),
        .SCLK    (SCLK),
        .MOSI    (MOSI),
        .MISO    (MISO),
        .CS_N    (CS_N)
    );

    //--------------------------------------------------------------------------
    // Simple SPI slave model - mode 0-3, MSB first, loopback XOR transform
    // Returns (received_byte ^ 8'hA5) so RX != TX for a clear check
    //--------------------------------------------------------------------------
    reg [7:0] slave_tx;
    reg [7:0] slave_rx;
    reg [2:0] slave_bit;
    reg       slave_active;
    reg       miso_drv;
    reg       cpol_s;
    reg       cpha_s;

    assign MISO = miso_drv;

    // Sample CPOL/CPHA from DUT CTRL via hierarchical peek for slave config
    // (testbench programs same mode before transfer)
    initial begin
        miso_drv     = 1'b0;
        slave_active = 1'b0;
        slave_tx     = 8'h00;
        slave_rx     = 8'h00;
        slave_bit    = 3'd0;
        cpol_s       = 1'b0;
        cpha_s       = 1'b0;
    end

    task set_slave_mode;
        input cpol_i;
        input cpha_i;
        begin
            cpol_s = cpol_i;
            cpha_s = cpha_i;
        end
    endtask

    // Leading / trailing edge detection relative to idle (CPOL)
    wire sclk_leading  = cpol_s ? (SCLK === 1'b0) : (SCLK === 1'b1);
    // After a change: if now at ~CPOL it's leading; if at CPOL it's trailing

    always @(negedge CS_N) begin
        slave_active = 1'b1;
        slave_rx     = 8'h00;
        slave_bit    = 3'd7;
        // Preload response: will XOR after full RX known - use fixed pattern first,
        // then update after we see MOSI bytes. For loopback-style: shift out
        // predetermined byte, then check master got it; master TX checked via MOSI.
        slave_tx     = 8'h5C;  // known slave → master data
        if (!cpha_s)
            miso_drv = slave_tx[7];
        else
            miso_drv = 1'b0;
    end

    always @(posedge CS_N) begin
        slave_active = 1'b0;
        miso_drv     = 1'b0;
    end

    always @(SCLK) begin
        if (slave_active && CS_N === 1'b0) begin
            if (cpha_s == 1'b0) begin
                // Mode 0/2: sample MOSI on leading, change MISO on trailing
                if (SCLK !== cpol_s) begin
                    // leading
                    slave_rx[slave_bit] = MOSI;
                    if (slave_bit == 3'd0) begin
                        // full byte received - optional: could set next TX
                    end
                end else begin
                    // trailing
                    if (slave_bit != 3'd0) begin
                        slave_bit = slave_bit - 3'd1;
                        miso_drv  = slave_tx[slave_bit];
                    end
                end
            end else begin
                // Mode 1/3: change MISO on leading, sample MOSI on trailing
                if (SCLK !== cpol_s) begin
                    // leading - drive next bit (first leading drives MSB)
                    miso_drv = slave_tx[slave_bit];
                end else begin
                    // trailing - sample
                    slave_rx[slave_bit] = MOSI;
                    if (slave_bit != 3'd0)
                        slave_bit = slave_bit - 3'd1;
                end
            end
        end
    end

    //--------------------------------------------------------------------------
    // Clock gen
    //--------------------------------------------------------------------------
    initial ACLK = 1'b0;
    always #5 ACLK = ~ACLK;  // 100 MHz

    //--------------------------------------------------------------------------
    // AXI tasks
    //--------------------------------------------------------------------------
    task axi_write;
        input [31:0] addr;
        input [31:0] data;
        begin
            @(posedge ACLK);
            AWADDR  <= addr;
            AWVALID <= 1'b1;
            WDATA   <= data;
            WSTRB   <= 4'hF;
            WVALID  <= 1'b1;
            BREADY  <= 1'b1;

            // Wait until both AW and W accepted
            fork
                begin : aw_wait
                    while (!(AWVALID && AWREADY)) @(posedge ACLK);
                    @(posedge ACLK);
                    AWVALID <= 1'b0;
                end
                begin : w_wait
                    while (!(WVALID && WREADY)) @(posedge ACLK);
                    @(posedge ACLK);
                    WVALID <= 1'b0;
                end
            join

            while (!(BVALID && BREADY)) @(posedge ACLK);
            @(posedge ACLK);
            BREADY <= 1'b0;

            if (BRESP != 2'b00) begin
                $display("[%0t] ERROR: AXI write SLVERR addr=0x%08h", $time, addr);
                errors = errors + 1;
            end
        end
    endtask

    task axi_read;
        input  [31:0] addr;
        output [31:0] data;
        begin
            @(posedge ACLK);
            ARADDR  <= addr;
            ARVALID <= 1'b1;
            RREADY  <= 1'b1;

            while (!(ARVALID && ARREADY)) @(posedge ACLK);
            @(posedge ACLK);
            ARVALID <= 1'b0;

            while (!(RVALID && RREADY)) @(posedge ACLK);
            data = RDATA;
            if (RRESP != 2'b00) begin
                $display("[%0t] ERROR: AXI read SLVERR addr=0x%08h", $time, addr);
                errors = errors + 1;
            end
            @(posedge ACLK);
            RREADY <= 1'b0;
        end
    endtask

    task check_eq;
        input [1023:0] name;
        input [31:0]   got;
        input [31:0]   exp;
        begin
            if (got !== exp) begin
                $display("[%0t] FAIL: %0s got=0x%08h exp=0x%08h", $time, name, got, exp);
                errors = errors + 1;
            end else begin
                $display("[%0t] PASS: %0s = 0x%08h", $time, name, got);
                passes = passes + 1;
            end
        end
    endtask

    task wait_spi_done;
        integer timeout;
        begin
            timeout = 0;
            axi_read(ADDR_STATUS, rd_data);
            while (rd_data[0] == 1'b1 && timeout < 100000) begin
                @(posedge ACLK);
                axi_read(ADDR_STATUS, rd_data);
                timeout = timeout + 1;
            end
            if (timeout >= 100000) begin
                $display("[%0t] ERROR: SPI busy timeout", $time);
                errors = errors + 1;
            end
        end
    endtask

    task do_spi_xfer;
        input [7:0] tx;
        input       cpol_i;
        input       cpha_i;
        begin
            set_slave_mode(cpol_i, cpha_i);
            axi_write(ADDR_TXDATA, {24'd0, tx});
            axi_write(ADDR_CTRL, CTRL_ENABLE | CTRL_START |
                      (cpol_i ? CTRL_CPOL : 32'h0) |
                      (cpha_i ? CTRL_CPHA : 32'h0));
            wait_spi_done();
        end
    endtask

    //--------------------------------------------------------------------------
    // Main test
    //--------------------------------------------------------------------------
    initial begin
        $dumpfile("axi4_lite_spi_bridge.vcd");
        $dumpvars(0, tb_axi4_lite_spi_bridge);

        errors  = 0;
        passes  = 0;
        ARESETn = 1'b0;
        AWADDR  = 0;
        AWVALID = 0;
        WDATA   = 0;
        WSTRB   = 0;
        WVALID  = 0;
        BREADY  = 0;
        ARADDR  = 0;
        ARVALID = 0;
        RREADY  = 0;

        repeat (10) @(posedge ACLK);
        ARESETn = 1'b1;
        repeat (5) @(posedge ACLK);

        $display("========================================");
        $display(" AXI4-Lite SPI Bridge Testbench");
        $display("========================================");

        // ---- Reset defaults ----
        axi_read(ADDR_CTRL, rd_data);
        check_eq("CTRL after reset", rd_data, 32'h0);

        axi_read(ADDR_STATUS, rd_data);
        check_eq("STATUS after reset (not busy)", rd_data[0], 1'b0);

        // ---- Register R/W ----
        axi_write(ADDR_CLKDIV, 32'h0000_0002);
        axi_read(ADDR_CLKDIV, rd_data);
        check_eq("CLKDIV write/read", rd_data, 32'h0000_0002);

        axi_write(ADDR_TXDATA, 32'h0000_00A5);
        axi_read(ADDR_TXDATA, rd_data);
        check_eq("TXDATA write/read", rd_data, 32'h0000_00A5);

        axi_write(ADDR_CTRL, CTRL_ENABLE); // enable, mode 0
        axi_read(ADDR_CTRL, rd_data);
        check_eq("CTRL enable", rd_data[0], 1'b1);

        axi_read(ADDR_STATUS, rd_data);
        check_eq("STATUS READY when enabled idle", rd_data[2], 1'b1);

        // ---- SPI Mode 0 transfer ----
        $display("--- SPI Mode 0 transfer (TX=0xA5, expect RX=0x5C) ---");
        do_spi_xfer(8'hA5, 1'b0, 1'b0);

        axi_read(ADDR_STATUS, rd_data);
        check_eq("STATUS DONE after xfer", rd_data[1], 1'b1);
        check_eq("STATUS not BUSY", rd_data[0], 1'b0);

        axi_read(ADDR_RXDATA, rd_data);
        check_eq("RXDATA mode0", rd_data[7:0], 8'h5C);

        // Slave should have seen 0xA5 on MOSI
        check_eq("SPI slave RX (MOSI)", {24'd0, slave_rx}, 32'h0000_00A5);

        // ---- SPI Mode 3 transfer ----
        $display("--- SPI Mode 3 transfer (TX=0x3C, expect RX=0x5C) ---");
        axi_write(ADDR_CLKDIV, 32'h0000_0001);
        do_spi_xfer(8'h3C, 1'b1, 1'b1);

        axi_read(ADDR_RXDATA, rd_data);
        check_eq("RXDATA mode3", rd_data[7:0], 8'h5C);
        check_eq("SPI slave RX mode3", {24'd0, slave_rx}, 32'h0000_003C);

        // ---- Busy during transfer ----
        $display("--- Busy flag during transfer ---");
        set_slave_mode(1'b0, 1'b0);
        axi_write(ADDR_CLKDIV, 32'h0000_0004);
        axi_write(ADDR_TXDATA, 32'h0000_0055);
        axi_write(ADDR_CTRL, CTRL_ENABLE | CTRL_START);

        // Poll until busy or done briefly
        repeat (3) @(posedge ACLK);
        axi_read(ADDR_STATUS, rd_data);
        if (rd_data[0] != 1'b1 && rd_data[1] != 1'b1) begin
            $display("[%0t] FAIL: expected BUSY or quick DONE, status=0x%08h", $time, rd_data);
            errors = errors + 1;
        end else begin
            $display("[%0t] PASS: BUSY/DONE observed status=0x%08h", $time, rd_data);
            passes = passes + 1;
        end
        wait_spi_done();

        // ---- Summary ----
        $display("========================================");
        if (errors == 0) begin
            $display(" TEST RESULT: PASS  (%0d checks)", passes);
        end else begin
            $display(" TEST RESULT: FAIL  (%0d errors, %0d passes)", errors, passes);
        end
        $display("========================================");
        $finish;
    end

    // Safety timeout
    initial begin
        #5_000_000;
        $display("ERROR: global timeout");
        $finish;
    end

endmodule