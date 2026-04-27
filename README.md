# FPGA_BASED_TRADING_SIGNAL_GENERATOR
FPGA-based low-latency trading signal generator using SMA, EMA crossover, RSI, and volume-based aggregation.
# FPGA-Based Trading Signal Generator
 Overview

This project implements a low-latency trading signal generator on FPGA using hardware-accelerated technical indicators.

The system processes streaming price and volume data and generates BUY, SELL, or HOLD signals with a confidence score.

Key Features

* Fully pipelined FPGA design
* Real-time signal generation
* Deterministic latency
* Multi-indicator strategy

Indicators Implemented

* Simple Moving Average (SMA)
* Exponential Moving Average (EMA)
* EMA Crossover Detection
* Relative Strength Index (RSI)
* Volume Confirmation Filter

Architecture

The system consists of:

1. Indicator computation modules
2. Signal aggregation logic
3. Top-level integration module

File Structure

* sma.v – Simple moving average
* ema.v – Exponential moving average
* ema_cross.v – Crossover detection
* rsi.v – RSI calculation
* volume_filter.v – Volume confirmation
* signal_aggregator.v – Decision engine
* top.v – System integration
* tb_top.v – Testbench

Simulation

Testbench simulates:

* Market warmup phase
* Bearish trend (SELL)
* Bullish trend (BUY)
* Sideways market (HOLD)

Output Signals

* sig_buy
* sig_sell
* sig_hold
* confidence (0–15)

Tools

* Verilog HDL
* Simulation: ModelSim / Vivado

Future Work

* PCIe / Ethernet interface
* Real-time market data feed
* Strategy optimization
