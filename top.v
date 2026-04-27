module top (
    input  wire        clk, rst,
    input  wire [31:0] price_in,
    input  wire [31:0] volume_in,
    input  wire        valid_in,
    output wire        sig_buy,
    output wire        sig_sell,
    output wire        sig_hold,
    output wire [3:0]  confidence
);
    wire [31:0] sma_fast_out, sma_slow_out;
    wire        sma_fast_vld, sma_slow_vld;
    wire [31:0] ema_fast_out, ema_slow_out;
    wire        ema_fast_vld, ema_slow_vld;
    wire [6:0]  rsi_out;
    wire        rsi_vld;
    wire        high_volume, vol_vld;
    wire        cross_up, cross_down, cross_vld;

    // Sticky ready flags
    reg sma_fast_rdy, sma_slow_rdy, ema_fast_rdy;
    reg ema_slow_rdy, rsi_rdy, vol_rdy, cross_rdy;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sma_fast_rdy<=0; sma_slow_rdy<=0;
            ema_fast_rdy<=0; ema_slow_rdy<=0;
            rsi_rdy<=0; vol_rdy<=0; cross_rdy<=0;
        end else begin
            if (sma_fast_vld) sma_fast_rdy <= 1;
            if (sma_slow_vld) sma_slow_rdy <= 1;
            if (ema_fast_vld) ema_fast_rdy <= 1;
            if (ema_slow_vld) ema_slow_rdy <= 1;
            if (rsi_vld)      rsi_rdy      <= 1;
            if (vol_vld)      vol_rdy      <= 1;
            if (cross_vld)    cross_rdy    <= 1;
        end
    end

    wire indicators_ready = sma_fast_rdy & sma_slow_rdy
                          & ema_fast_rdy & ema_slow_rdy
                          & rsi_rdy & vol_rdy & cross_rdy
                          & valid_in;

    sma #(.PERIOD(9),  .WIDTH(32)) u_sma_fast (.clk(clk),.rst(rst),.price_in(price_in),.valid_in(valid_in),.sma_out(sma_fast_out),.valid_out(sma_fast_vld));
    sma #(.PERIOD(21), .WIDTH(32)) u_sma_slow (.clk(clk),.rst(rst),.price_in(price_in),.valid_in(valid_in),.sma_out(sma_slow_out),.valid_out(sma_slow_vld));
    ema #(.PERIOD(9),  .WIDTH(32)) u_ema_fast (.clk(clk),.rst(rst),.price_in(price_in),.valid_in(valid_in),.ema_out(ema_fast_out),.valid_out(ema_fast_vld));
    ema #(.PERIOD(21), .WIDTH(32)) u_ema_slow (.clk(clk),.rst(rst),.price_in(price_in),.valid_in(valid_in),.ema_out(ema_slow_out),.valid_out(ema_slow_vld));
    rsi #(.PERIOD(14), .WIDTH(32)) u_rsi      (.clk(clk),.rst(rst),.price_in(price_in),.valid_in(valid_in),.rsi_out(rsi_out),.valid_out(rsi_vld));

    volume_filter #(.PERIOD(20),.WIDTH(32)) u_vol (
        .clk(clk),.rst(rst),.volume_in(volume_in),
        .valid_in(valid_in),.high_volume(high_volume),.valid_out(vol_vld));

    ema_cross u_cross (
        .clk(clk),.rst(rst),
        .ema_fast(ema_fast_out),.ema_slow(ema_slow_out),
        .valid_in(ema_fast_vld & ema_slow_vld),
        .cross_up(cross_up),.cross_down(cross_down),.valid_out(cross_vld));

    signal_aggregator u_agg (
        .clk(clk),.rst(rst),
        .rsi(rsi_out),.cross_up(cross_up),.cross_down(cross_down),
        .high_volume(high_volume),.price(price_in),
        .sma_fast(sma_fast_out),.sma_slow(sma_slow_out),
        .indicators_ready(indicators_ready),
        .sig_buy(sig_buy),.sig_sell(sig_sell),
        .sig_hold(sig_hold),.confidence(confidence));
endmodule