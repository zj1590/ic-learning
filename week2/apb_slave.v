module apb_slave (
    input  wire        PCLK,    // APB 时钟
    input  wire        PRESETn, // APB 复位（低有效）
    
    // 总线输入信号（来自 Master）
    input  wire        PSEL,    // 选中信号
    input  wire        PENABLE, // 使能信号
    input  wire        PWRITE,  // 读写控制：1-写，0-读
    input  wire [31:0] PADDR,   // 地址
    input  wire [31:0] PWDATA,  // 写数据
    
    // 总线输出信号（发回给 Master）
    output reg  [31:0] PRDATA,  // 读数据
    output wire        PREADY   // 就绪信号（永远告诉别人我准备好了）
);

    // 内部寄存器定义
    reg [31:0] reg_a;
    reg [31:0] reg_b;

    // 永远就绪（最简单的从机）
    assign PREADY = 1'b1; 

    // 写操作：当 PSEL、PENABLE 同时为高，且 PWRITE 为 1 时，写入数据
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            reg_a <= 32'h0000_0000;
            reg_b <= 32'h0000_0000;
        end else if (PSEL && PENABLE && PWRITE) begin
            case (PADDR)
                32'h00: reg_a <= PWDATA;
                32'h04: reg_b <= PWDATA;
                default: ; // 其他地址不管
            endcase
        end
    end

    // 读操作：当 PSEL 和 PENABLE 同时为高，且 PWRITE 为 0 时，输出数据
    always @(*) begin
        PRDATA = 32'h0000_0000; // 默认值
        if (PSEL && PENABLE && !PWRITE) begin
            case (PADDR)
                32'h00: PRDATA = reg_a;
                32'h04: PRDATA = reg_b;
                default: PRDATA = 32'hFFFF_FFFF; // 读错地址给个乱码
            endcase
        end
    end

endmodule