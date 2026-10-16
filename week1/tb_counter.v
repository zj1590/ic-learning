`timescale 1ns/1ps

module tb_counter;
    reg clk;
    reg rst_n;
    wire [3:0] cnt;

    counter u_counter(
        .clk(clk),
        .rst_n(rst_n),
        .cnt(cnt)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 产生时钟，周期10ns
    end

    initial begin
        $dumpfile("counter.vcd");
        $dumpvars(0, tb_counter);

        rst_n = 0;
        #20;
        rst_n = 1;
        #200;
        $finish;
    end
endmodule