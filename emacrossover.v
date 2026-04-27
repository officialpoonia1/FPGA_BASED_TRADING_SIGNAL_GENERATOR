module ema_cross (
    input  wire        clk, rst,
    input  wire [31:0] ema_fast,
    input  wire [31:0] ema_slow,
    input  wire        valid_in,
    output reg         cross_up,
    output reg         cross_down,
    output reg         valid_out
);
    reg [31:0] prev_fast, prev_slow;
    reg        first_tick;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cross_up <= 0; cross_down <= 0;
            prev_fast <= 0; prev_slow <= 0;
            first_tick <= 1; valid_out <= 0;
        end else if (valid_in) begin
            if (first_tick) begin
                cross_up <= 0; cross_down <= 0;
                first_tick <= 0;
            end else begin
                cross_up   <= (prev_fast <= prev_slow) && (ema_fast > ema_slow);
                cross_down <= (prev_fast >= prev_slow) && (ema_fast < ema_slow);
            end
            prev_fast <= ema_fast;
            prev_slow <= ema_slow;
            valid_out <= 1;
        end else begin
            cross_up <= 0; cross_down <= 0;
            valid_out <= 0;
        end
    end
endmodule