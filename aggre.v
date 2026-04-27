module signal_aggregator (
    input  wire        clk, rst,
    input  wire [6:0]  rsi,
    input  wire        cross_up, cross_down,
    input  wire        high_volume,
    input  wire [31:0] price, sma_fast, sma_slow,
    input  wire        indicators_ready,
    output reg         sig_buy,
    output reg         sig_sell,
    output reg         sig_hold,
    output reg  [3:0]  confidence
);
    // Use integer to avoid all signed/unsigned issues
    integer score;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sig_buy    <= 0;
            sig_sell   <= 0;
            sig_hold   <= 0;
            confidence <= 0;
        end else if (indicators_ready) begin
            score = 0;

            if (rsi < 7'd50 && rsi > 7'd0) score = score + 2;
            if (rsi < 7'd35)               score = score + 2;
            if (rsi > 7'd55)               score = score - 2;
            if (rsi > 7'd70)               score = score - 2;
            if (cross_up)                  score = score + 3;
            if (cross_down)                score = score - 3;
            if (price > sma_slow)          score = score + 1;
            if (price < sma_slow)          score = score - 1;
            if (high_volume && score > 0)  score = score + 1;
            if (high_volume && score < 0)  score = score - 1;

            if (score >= 3) begin
                sig_buy    <= 1;
                sig_sell   <= 0;
                sig_hold   <= 0;
                if (score > 6)
                    confidence <= 4'd15;
                else
                    confidence <= score * 2;
            end else if (score <= -3) begin
                sig_buy    <= 0;
                sig_sell   <= 1;
                sig_hold   <= 0;
                if (score < -6)
                    confidence <= 4'd15;
                else
                    confidence <= (-score) * 2;
            end else begin
                sig_buy    <= 0;
                sig_sell   <= 0;
                sig_hold   <= 1;
                confidence <= 4'd0;
            end
        end
    end
endmodule