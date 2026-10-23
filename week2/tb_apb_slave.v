`timescale 1ns/1ps

module tb_apb_slave;
    reg PCLK;
    reg PRESETn;
    reg PSEL;
    reg PENABLE;
    reg PWRITE;
    reg [31:0] PADDR;
    reg [31:0] PWDATA;
    
    wire [31:0] PRDATA;
    wire PREADY;

    apb_slave u_apb_slave (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY)
    );

    // 时钟生成 (周期10ns)
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;
    end

    // 模拟 CPU 写数据的任务
    task apb_write(input [31:0] addr, input [31:0] data);
        begin
            @(posedge PCLK); // 等待时钟上升沿
            PSEL = 1; PENABLE = 0; PWRITE = 1; PADDR = addr; PWDATA = data; // Setup 阶段
            @(posedge PCLK);
            PENABLE = 1; // Access 阶段（使能拉高，Slave在这时把数据拿走）
            @(posedge PCLK);
            PSEL = 0; PENABLE = 0; PWRITE = 0; // 释放总线
        end
    endtask

    // 模拟 CPU 读数据的任务
    task apb_read(input [31:0] addr, output [31:0] data);
        begin
            @(posedge PCLK);
            PSEL = 1; PENABLE = 0; PWRITE = 0; PADDR = addr; // Setup 阶段
            @(posedge PCLK);
            PENABLE = 1; // Access 阶段
            @(posedge PCLK);
            data = PRDATA; // 把数据读走
            PSEL = 0; PENABLE = 0; // 释放总线
        end
    endtask

    reg [31:0] read_data;

    initial begin
        $dumpfile("apb_slave.vcd");
        $dumpvars(0, tb_apb_slave);

        // 初始化
        PRESETn = 0; PSEL = 0; PENABLE = 0; PWRITE = 0; PADDR = 0; PWDATA = 0;
        #20; PRESETn = 1;
        #20;

        // 测试 1：向地址 0x00 写入 32'hA5A5_A5A5
        $display("--- Write 0xA5A5A5A5 to Addr 0x00 ---");
        apb_write(32'h00, 32'hA5A5A5A5);

        // 测试 2：向地址 0x04 写入 32'h1234_5678
        $display("--- Write 0x12345678 to Addr 0x04 ---");
        apb_write(32'h04, 32'h12345678);

        // 测试 3：从地址 0x00 读出数据
        $display("--- Read from Addr 0x00 ---");
        apb_read(32'h00, read_data);
        $display("Read Data: %h", read_data);

        // 测试 4：从地址 0x04 读出数据
        $display("--- Read from Addr 0x04 ---");
        apb_read(32'h04, read_data);
        $display("Read Data: %h", read_data);

        #50;
        $finish;
    end
endmodule