`timescale 1ns/1ps

module tb_seq_detector_110;
    reg clk;
    reg rst_n;
    reg din;
    wire dout;

    seq_detector_110 u_seq_detector_110(
        .clk(clk),
        .rst_n(rst_n),
        .din(din),
        .dout(dout)
    );

    // 时钟生成
    initial 
    begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 激励
    initial 
    begin
        $dumpfile("seq_detector_110.vcd");
        $dumpvars(0, tb_seq_detector_110);

        rst_n = 0;
        din = 0;
        #20;
        rst_n = 1;
        
     
        // 注意：这里每次赋值后加 #10，是为了对齐时钟周期
        #5; // 稍微错开一点时钟沿，让波形更好看
        din = 1; #10;
        din = 1; #10;
        din = 0; #10;
  
        
        din = 0; #10;
        din = 1; #10;
        din = 0; #10;
        din = 1; #10;
        din = 1; #10;
        din = 1; #10;
        din = 0; #10; // 此时 dout 又应该变高1个周期

        #10;
        $finish;
    end
    
endmodule