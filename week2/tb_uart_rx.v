`timescale 1ns/1ps

module tb_uart_rx;
    reg clk;
    reg rst_n;
    
    // TX 模块的信号
    reg tx_start;
    reg [7:0] tx_data;
    wire tx;
    wire tx_busy;

    // RX 模块的信号
    wire [7:0] rx_data;
    wire rx_done;

    // 例化发送模块 (为了仿真快，参数依然改小)
    uart_tx #(
        .CLK_FREQ(50),      
        .BAUD_RATE(5)       
    ) u_tx (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // 例化接收模块
    uart_rx #(
        .CLK_FREQ(50),      
        .BAUD_RATE(5)       
    ) u_rx (
        .clk(clk),
        .rst_n(rst_n),
        .rx(tx),            // 核心：把 TX 发出的线，直接连到 RX 的接收线上！
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    // 时钟生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 激励
    initial begin
        $dumpfile("uart_rx.vcd");
        $dumpvars(0, tb_uart_rx);

        rst_n = 0;
        tx_start = 0;
        tx_data = 8'h00;
        #20;
        rst_n = 1;
        #20;

        // 让 TX 发送一个 8'hA5 (10100101)
        tx_data = 8'hA5; 
        tx_start = 1;
        #10;
        tx_start = 0;
        
        // 等待发送和接收完成
        #1500;
        $finish;
    end
endmodule