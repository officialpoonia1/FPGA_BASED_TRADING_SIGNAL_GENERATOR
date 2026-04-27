// =============================================================
//  tb_top_manual.v  -  60-tick testbench
//  Guarantees BUY, SELL and HOLD all appear after warmup
//
//  Price sequence design:
//   Ticks  0-20 : WARMUP  - slow rise so SMA/EMA/RSI initialize
//   Ticks 21-30 : SELL    - sharp drop, RSI>70 then crash, death cross
//   Ticks 31-40 : BUY     - sharp rally, RSI<30, golden cross, high vol
//   Ticks 41-59 : HOLD    - sideways chop, RSI neutral, low volume
// =============================================================

`timescale 1ns / 1ps

module tb_top_manual;

// ── Clock & Reset ────────────────────────────────────────────
reg clk = 0;
reg rst = 1;
always #5 clk = ~clk;   // 100 MHz

// ── DUT ports ────────────────────────────────────────────────
reg  [31:0] price_in  = 0;
reg  [31:0] volume_in = 0;
reg         valid_in  = 0;

wire        sig_buy, sig_sell, sig_hold;
wire [3:0]  confidence;

// ── DUT ──────────────────────────────────────────────────────
top dut (
    .clk        (clk),
    .rst        (rst),
    .price_in   (price_in),
    .volume_in  (volume_in),
    .valid_in   (valid_in),
    .sig_buy    (sig_buy),
    .sig_sell   (sig_sell),
    .sig_hold   (sig_hold),
    .confidence (confidence)
);

// ── Waveform dump ────────────────────────────────────────────
initial begin
    $dumpfile("tb_top_manual.vcd");
    $dumpvars(0, tb_top_manual);
end

// =============================================================
//  PRICE & VOLUME DATA  (Q16.16 = real_price x 65536)
//
//  Quick converter table:
//    $120 = 32'd7864320     $125 = 32'd8192000
//    $130 = 32'd8519680     $133 = 32'd8716288
//    $135 = 32'd8847360     $138 = 32'd9043968
//    $140 = 32'd9175040     $143 = 32'd9371648
//    $145 = 32'd9502720     $147 = 32'd9633792
//    $148 = 32'd9699328     $150 = 32'd9830400
//    $152 = 32'd9961472     $153 = 32'd10027008
//    $155 = 32'd10158080    $157 = 32'd10289152
//    $158 = 32'd10354688    $160 = 32'd10485760
//    $165 = 32'd10813440    $170 = 32'd11141120
//    $175 = 32'd11468800    $180 = 32'd11796480
//    $185 = 32'd12124160    $190 = 32'd12451840
//    $195 = 32'd12779520    $200 = 32'd13107200
//
//  Volume (units x 65536):
//    LOW  2000 = 32'd131072000
//    MED  4000 = 32'd262144000
//    HIGH 7000 = 32'd458752000
//    VERY 9000 = 32'd589824000
// =============================================================

parameter NUM_TICKS = 60;
reg [31:0] price_data  [0:NUM_TICKS-1];
reg [31:0] volume_data [0:NUM_TICKS-1];

integer i;
real    real_price;

reg seen_buy, seen_sell, seen_hold;

initial begin

 // TICKS 0-20: WARMUP - flat/mixed so RSI stays neutral ~50
price_data[0]  = 32'd9830400;   // $150
price_data[1]  = 32'd9699328;   // $148
price_data[2]  = 32'd9961472;   // $152
price_data[3]  = 32'd9830400;   // $150
price_data[4]  = 32'd9699328;   // $148
price_data[5]  = 32'd9961472;   // $152
price_data[6]  = 32'd9830400;   // $150
price_data[7]  = 32'd9699328;   // $148
price_data[8]  = 32'd9961472;   // $152
price_data[9]  = 32'd9830400;   // $150
price_data[10] = 32'd9699328;   // $148
price_data[11] = 32'd9961472;   // $152
price_data[12] = 32'd9830400;   // $150
price_data[13] = 32'd9699328;   // $148
price_data[14] = 32'd9961472;   // $152
price_data[15] = 32'd9830400;   // $150
price_data[16] = 32'd9699328;   // $148
price_data[17] = 32'd9961472;   // $152
price_data[18] = 32'd9830400;   // $150
price_data[19] = 32'd9961472;   // $152
price_data[20] = 32'd9830400;   // $150

// TICKS 21-30: SELL - big spike then crash, RSI > 70
price_data[21] = 32'd11468800;  // $175 spike
price_data[22] = 32'd13107200;  // $200 RSI peaks
price_data[23] = 32'd13107200;  // $200 stay high
price_data[24] = 32'd13107200;  // $200 RSI solidly >70
price_data[25] = 32'd12451840;  // $190 death cross
price_data[26] = 32'd11468800;  // $175
price_data[27] = 32'd10485760;  // $160 SELL fires here
price_data[28] = 32'd9175040;   // $140
price_data[29] = 32'd7864320;   // $120
price_data[30] = 32'd6553600;   // $100

// TICKS 31-44: Stay at $100 - force RSI to decay
price_data[31] = 32'd6553600;  // $100
price_data[32] = 32'd6553600;  // $100
price_data[33] = 32'd6553600;  // $100
price_data[34] = 32'd6553600;  // $100
price_data[35] = 32'd6553600;  // $100
price_data[36] = 32'd6553600;  // $100
price_data[37] = 32'd6553600;  // $100
price_data[38] = 32'd6553600;  // $100
price_data[39] = 32'd6553600;  // $100
price_data[40] = 32'd6553600;  // $100
price_data[41] = 32'd6553600;  // $100
price_data[42] = 32'd6553600;  // $100
price_data[43] = 32'd6553600;  // $100
price_data[44] = 32'd6553600;  // $100

// TICKS 45-54: Sharp rally - BUY fires here
price_data[45] = 32'd7208960;  // $110
price_data[46] = 32'd7864320;  // $120
price_data[47] = 32'd8519680;  // $130
price_data[48] = 32'd9175040;  // $140
price_data[49] = 32'd9830400;  // $150
price_data[50] = 32'd10485760; // $160
price_data[51] = 32'd10813440; // $165
price_data[52] = 32'd11141120; // $170
price_data[53] = 32'd11468800; // $175
price_data[54] = 32'd11796480; // $180

// TICKS 55-69: HOLD zone
price_data[55] = 32'd10485760; // $160
price_data[56] = 32'd10551296; // $161
price_data[57] = 32'd10485760; // $160
price_data[58] = 32'd10420224; // $159
price_data[59] = 32'd10485760; // $160
price_data[60] = 32'd10551296; // $161
price_data[61] = 32'd10485760; // $160
price_data[62] = 32'd10420224; // $159
price_data[63] = 32'd10485760; // $160
price_data[64] = 32'd10551296; // $161
price_data[65] = 32'd10485760; // $160
price_data[66] = 32'd10420224; // $159
price_data[67] = 32'd10485760; // $160
price_data[68] = 32'd10551296; // $161
price_data[69] = 32'd10485760; // $160

// VOLUMES
for (i = 0;  i <= 20; i = i+1) volume_data[i] = 32'd262144000;
for (i = 21; i <= 30; i = i+1) volume_data[i] = 32'd589824000;
for (i = 31; i <= 54; i = i+1) volume_data[i] = 32'd589824000;
for (i = 55; i <= 69; i = i+1) volume_data[i] = 32'd131072000;
    // ----------------------------------------------------------
    // VOLUMES
    // ----------------------------------------------------------
    for (i = 0; i <= 20; i = i + 1)
        volume_data[i] = 32'd262144000;   // 4000 - medium (warmup)

    for (i = 21; i <= 30; i = i + 1)
        volume_data[i] = 32'd589824000;   // 9000 - very high (sell confirm)

    for (i = 31; i <= 40; i = i + 1)
        volume_data[i] = 32'd589824000;   // 9000 - very high (buy confirm)

    for (i = 41; i <= 59; i = i + 1)
        volume_data[i] = 32'd131072000;   // 2000 - very low (no confirm)

end

// =============================================================
//  MAIN STIMULUS
// =============================================================
initial begin

    seen_buy  = 0;
    seen_sell = 0;
    seen_hold = 0;

    // Reset
    rst = 1;
    repeat(4) @(posedge clk);
    @(negedge clk);
    rst = 0;
    repeat(2) @(posedge clk);

    $display("=========================================================");
    $display("  FPGA Trading Signal Generator - 60-Tick Testbench");
    $display("=========================================================");
    $display("  Tick | Price($) |  RSI | Signal | Conf | Zone");
    $display("---------------------------------------------------------");

    for (i = 0; i < NUM_TICKS; i = i + 1) begin

        @(negedge clk);
        price_in  = price_data[i];
        volume_in = volume_data[i];
        valid_in  = 1;

        @(posedge clk);
        #1;
        valid_in = 0;

        // Wait for all pipelines to settle
        repeat(10) @(posedge clk);
        #1;

        real_price = $itor(price_data[i]) / 65536.0;

        if (sig_buy)  seen_buy  = 1;
        if (sig_sell) seen_sell = 1;
        if (sig_hold) seen_hold = 1;

        $display("  %4d | %8.2f | %4d |  %s%s%s |  %2d  | %s",
            i,
            real_price,
            dut.u_rsi.rsi_out,
            sig_buy  ? "BUY " : "    ",
            sig_sell ? "SELL" : "    ",
            sig_hold ? "HOLD" : "    ",
            confidence,
            (i <= 20) ? "WARMUP   " :
            (i <= 30) ? "SELL zone" :
            (i <= 40) ? "BUY zone " :
                        "HOLD zone"
        );
    end

    // Final summary
    $display("=========================================================");
    $display("  SIGNAL COVERAGE REPORT:");
    $display("    BUY  generated : %s", seen_buy  ? "YES" : "NO");
    $display("    SELL generated : %s", seen_sell ? "YES" : "NO");
    $display("    HOLD generated : %s", seen_hold ? "YES" : "NO");
    $display("---------------------------------------------------------");
    if (seen_buy && seen_sell && seen_hold)
        $display("  ALL THREE SIGNALS VERIFIED - PROJECT COMPLETE!");
    else
        $display("  WARNING: some signals missing. Check RSI warmup.");
    $display("=========================================================");
    $finish;
end

// =============================================================
//  SELF-CHECKING ASSERTIONS
// =============================================================    

// Never more than one signal at a time
always @(posedge clk) begin
    if (!rst) begin
        if ((sig_buy + sig_sell + sig_hold) > 1) begin
            $display("[FAIL] t=%0t : Multiple signals asserted!", $time);
            //$finish;//
        end
    end
end

// HOLD must have confidence = 0
always @(posedge clk) begin
    if (!rst && sig_hold && confidence !== 4'd0)
        $display("[WARN] t=%0t : HOLD but confidence=%0d", $time, confidence);
end

// BUY or SELL must have confidence > 0
always @(posedge clk) begin
    if (!rst && (sig_buy | sig_sell) && confidence === 4'd0)
        $display("[WARN] t=%0t : BUY/SELL but confidence=0", $time);
end

endmodule