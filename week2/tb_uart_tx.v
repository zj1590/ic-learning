`timescale 1ns/1ps

module tb_uart_tx;
    reg clk;
    reg rst_n;
    reg tx_start;
    reg [7:0] tx_data;
    wire tx;
    wire tx_busy;

    // 核心：修改参数！假装系统时钟只有 50Hz，波特率是 5
    // 这样 BPS_CNT = 50 / 5 = 10。每发一个 bit 只要 10 个周期，仿真飞快！
    uart_tx #(
        .CLK_FREQ(50),      
        .BAUD_RATE(5)       
    ) u_uart_tx (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // 时钟生成 (周期10ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 激励
    initial begin
        $dumpfile("uart_tx.vcd");
        $dumpvars(0, tb_uart_tx);

        rst_n = 0;
        tx_start = 0;
        tx_data = 8'h00;
        #20;
        rst_n = 1;
        #20;

        // 发送第一个数据：8'h55 (二进制 01010101)
        tx_data = 8'h55; 
        tx_start = 1;
        #10;
        tx_start = 0; // 触发一下立刻松开
        
        // 等待发送完成 (10个bit * 10个周期 = 100个时钟 = 1000ns)
        #1200;

        // 发送第二个数据：8'hA5 (二进制 10100101)
        tx_data = 8'hA5;
        tx_start = 1;
        #10;
        tx_start = 0;

        #1200;
        $finish;
    end
endmodule