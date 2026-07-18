`timescale 1ns / 1ps

module spi_master (
    input  wire       aclk,
    input  wire       aresetn,

    input  wire       enable,
    input  wire       start,
    input  wire       cpol,
    input  wire       cpha,
    input  wire [7:0] clk_div,
    input  wire [7:0] tx_data,

    output reg        busy,
    output reg        done,
    output reg  [7:0] rx_data,

    output reg        sclk,
    output reg        mosi,
    input  wire       miso,
    output reg        cs_n
);

    localparam ST_IDLE = 2'd0;
    localparam ST_XFER = 2'd1;
    localparam ST_END  = 2'd2;

    reg [1:0] state;
    reg [3:0] bits_left;     // edges remaining / bit tracking
    reg [7:0] sh_tx;
    reg [7:0] sh_rx;
    reg [7:0] div_cnt;
    reg       sample_next;   // 1 = next edge is a sample edge
    reg       start_d;

    wire start_pulse = start & ~start_d;
    wire div_tick    = (div_cnt == 8'd0);

    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn)
            start_d <= 1'b0;
        else
            start_d <= start;
    end

    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            state       <= ST_IDLE;
            busy        <= 1'b0;
            done        <= 1'b0;
            rx_data     <= 8'h00;
            sclk        <= 1'b0;
            mosi        <= 1'b0;
            cs_n        <= 1'b1;
            bits_left   <= 4'd0;
            sh_tx       <= 8'h00;
            sh_rx       <= 8'h00;
            div_cnt     <= 8'd0;
            sample_next <= 1'b0;
        end else if (!enable) begin
            state       <= ST_IDLE;
            busy        <= 1'b0;
            sclk        <= cpol;
            mosi        <= 1'b0;
            cs_n        <= 1'b1;
            div_cnt     <= 8'd0;
        end else begin
            case (state)
                ST_IDLE: begin
                    sclk <= cpol;
                    cs_n <= 1'b1;
                    busy <= 1'b0;
                    if (start_pulse) begin
                        done        <= 1'b0;
                        busy        <= 1'b1;
                        cs_n        <= 1'b0;
                        sh_tx       <= tx_data;
                        sh_rx       <= 8'h00;
                        mosi        <= tx_data[7];
                        div_cnt     <= clk_div;
                        // 8 bits × 2 edges = 16 edges; CPHA=1 needs +1 leading setup edge
                        // We count sample edges remaining (8).
                        bits_left   <= 4'd8;
                        sample_next <= ~cpha; // CPHA0: first edge samples; CPHA1: first does not
                        state       <= ST_XFER;
                    end
                end

                ST_XFER: begin
                    if (!div_tick)
                        div_cnt <= div_cnt - 8'd1;
                    else begin
                        div_cnt <= clk_div;
                        sclk    <= ~sclk;

                        if (sample_next) begin
                            // Sample MISO on this edge
                            sh_rx <= {sh_rx[6:0], miso};
                            if (bits_left == 4'd1) begin
                                // Last sample done
                                if (cpha) begin
                                    // Need one more edge to restore idle polarity? 
                                    // After trailing sample, SCLK is already at idle for CPHA1:
                                    // CPHA1 CPOL0: edges L H L H ... sample on H; after 8th H, SCLK=1, idle=0
                                    // so need final toggle - handled in ST_END
                                    state <= ST_END;
                                end else begin
                                    // CPHA0: after leading sample of last bit, still need trailing
                                    // edge to complete the bit cell, then idle is correct.
                                    // bits_left==1 and we just sampled → one trailing left
                                    bits_left   <= 4'd0;
                                    sample_next <= 1'b0;
                                end
                            end else begin
                                bits_left   <= bits_left - 4'd1;
                                sample_next <= 1'b0;
                            end
                        end else begin
                            // Shift/change edge (or CPHA1 leading setup)
                            if (cpha) begin
                                // On leading edges after the first sample pair, output next bit.
                                // First edge (bits_left still 8): MOSI already has MSB - don't shift.
                                // After a sample, bits_left was decremented; this leading shifts.
                                if (bits_left != 4'd8) begin
                                    sh_tx <= {sh_tx[6:0], 1'b0};
                                    mosi  <= sh_tx[6];
                                end
                                sample_next <= 1'b1;
                            end else begin
                                // CPHA0 trailing: advance TX for next bit (unless finishing)
                                if (bits_left == 4'd0) begin
                                    state <= ST_END;
                                end else begin
                                    sh_tx       <= {sh_tx[6:0], 1'b0};
                                    mosi        <= sh_tx[6];
                                    sample_next <= 1'b1;
                                end
                            end
                        end
                    end
                end

                ST_END: begin
                    if (!div_tick)
                        div_cnt <= div_cnt - 8'd1;
                    else begin
                        // Ensure SCLK at idle (CPOL); may need one toggle for CPHA1
                        if (sclk != cpol) begin
                            sclk    <= cpol;
                            div_cnt <= clk_div;
                        end else begin
                            cs_n    <= 1'b1;
                            busy    <= 1'b0;
                            done    <= 1'b1;
                            rx_data <= sh_rx;
                            state   <= ST_IDLE;
                        end
                    end
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

endmodule