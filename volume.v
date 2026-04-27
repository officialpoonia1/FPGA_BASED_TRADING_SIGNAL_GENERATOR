module volume_filter #(
    parameter PERIOD    = 20,
    parameter WIDTH     = 32,
    // threshold = 1.5 in Q16.16
    parameter THRESHOLD = 32'd98304  // 1.5 × 65536
)(
    input  wire             clk, rst,
    input  wire [WIDTH-1:0] volume_in,
    input  wire             valid_in,
    output reg              high_volume,  // 1 = volume confirmed
    output reg              valid_out
);
    // Instantiate SMA for volume
    wire [WIDTH-1:0] vol_sma;
    wire             sma_valid;

    sma #(.PERIOD(PERIOD), .WIDTH(WIDTH)) vol_sma_inst (
        .clk(clk), .rst(rst),
        .price_in(volume_in), .valid_in(valid_in),
        .sma_out(vol_sma), .valid_out(sma_valid)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin high_volume <= 0; valid_out <= 0; end
        else if (sma_valid) begin
            // current volume > 1.5 × average volume?
            high_volume <= ((volume_in << 16) > (THRESHOLD * vol_sma) >> 16);
            valid_out   <= 1;
        end else valid_out <= 0;
    end
endmodule