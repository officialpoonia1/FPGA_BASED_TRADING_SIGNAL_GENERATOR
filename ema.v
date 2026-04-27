module ema #(
    parameter PERIOD = 9,
    parameter WIDTH  = 32
)(
    input  wire             clk, rst,
    input  wire [WIDTH-1:0] price_in,
    input  wire             valid_in,
    output reg  [WIDTH-1:0] ema_out,
    output reg              valid_out
);
    localparam [31:0] ALPHA     = (2 * 65536) / (PERIOD + 1);
    localparam [31:0] ONE_MINUS = 65536 - ALPHA;
    reg initialized;
    reg [63:0] calc;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ema_out <= 0; initialized <= 0; valid_out <= 0;
        end else if (valid_in) begin
            if (!initialized) begin
                ema_out     <= price_in;
                initialized <= 1;
            end else begin
                calc    = (ALPHA * price_in) + (ONE_MINUS * ema_out);
                ema_out <= calc >> 16;
            end
            valid_out <= 1;
        end else valid_out <= 0;
    end
endmodule