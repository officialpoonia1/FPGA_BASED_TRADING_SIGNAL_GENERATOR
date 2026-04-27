module sma #(
    parameter PERIOD = 9,
    parameter WIDTH  = 32
)(
    input  wire             clk, rst,
    input  wire [WIDTH-1:0] price_in,
    input  wire             valid_in,
    output reg  [WIDTH-1:0] sma_out,
    output reg              valid_out
);
    reg [WIDTH-1:0] window [0:PERIOD-1];
    reg [63:0]      acc;
    reg [4:0]       count;
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i=0; i<PERIOD; i=i+1) window[i] <= 0;
            acc <= 0; count <= 0;
            sma_out <= 0; valid_out <= 0;
        end else if (valid_in) begin
            acc <= acc - window[PERIOD-1] + price_in;
            for (i=PERIOD-1; i>0; i=i-1) window[i] <= window[i-1];
            window[0] <= price_in;
            if (count < PERIOD) count <= count + 1;
            if (count == PERIOD - 1) begin
                sma_out   <= (acc - window[PERIOD-1] + price_in) / PERIOD;
                valid_out <= 1;
            end else if (count >= PERIOD) begin
                sma_out   <= (acc - window[PERIOD-1] + price_in) / PERIOD;
                valid_out <= 1;
            end else valid_out <= 0;
        end else valid_out <= 0;
    end
endmodule