module rsi #(
    parameter PERIOD = 14,
    parameter WIDTH  = 32
)(
    input  wire             clk, rst,
    input  wire [WIDTH-1:0] price_in,
    input  wire             valid_in,
    output reg  [6:0]       rsi_out,
    output reg              valid_out
);
    reg [WIDTH-1:0] prev_price;
    reg [63:0]      avg_gain;
    reg [63:0]      avg_loss;
    reg [4:0]       count;
    reg [63:0]      rs;
    reg [63:0]      g, l;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            prev_price <= 0; avg_gain <= 0; avg_loss <= 0;
            count <= 0; rsi_out <= 50; valid_out <= 0;
        end else if (valid_in) begin
            g = (price_in > prev_price) ? (price_in - prev_price) : 0;
            l = (price_in < prev_price) ? (prev_price - price_in) : 0;

            if (count < PERIOD) begin
                avg_gain <= avg_gain + g;
                avg_loss <= avg_loss + l;
                count    <= count + 1;
                if (count == PERIOD - 1) begin
                    avg_gain  <= (avg_gain + g) / PERIOD;
                    avg_loss  <= (avg_loss + l) / PERIOD;
                    valid_out <= 1;
                    rsi_out   <= 50;
                end else valid_out <= 0;
            end else begin
                avg_gain <= ((avg_gain * (PERIOD-1)) + g) / PERIOD;
                avg_loss <= ((avg_loss * (PERIOD-1)) + l) / PERIOD;
                if (avg_loss == 0) begin
                    rsi_out <= 100;
                end else begin
                    rs = ((avg_gain * 65536) / avg_loss);
                    rsi_out <= 100 - (6553600 / (65536 + rs));
                end
                valid_out <= 1;
            end
            prev_price <= price_in;
        end else valid_out <= 0;
    end
endmodule