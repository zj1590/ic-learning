module seq_detector(
    input clk,
    input rst_n,
    input din,
    output reg dout
);

    // 1. 定义状态
    parameter IDLE = 3'd0;
    parameter S1   = 3'd1; // 检测到 1
    parameter S2   = 3'd2; // 检测到 10
    parameter S3   = 3'd3; // 检测到 101
    parameter S4   = 3'd4; // 检测到 1011

    reg [2:0] curr_state;
    reg [2:0] next_state;

    // 2. 第一段：状态寄存器（时序逻辑）
    always @(posedge clk or negedge rst_n) 
    begin
        if (!rst_n)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end

    // 3. 第二段：次态组合逻辑（看输入，决定下一步去哪）
    always @(*) 
    begin
        next_state = IDLE; // 给个默认值，防止锁存器
        case (curr_state)
            IDLE: if (din) next_state = S1; else next_state = IDLE;
            S1  : if (!din) next_state = S2; else next_state = S1;
            S2  : if (din) next_state = S3; else next_state = IDLE;
            S3  : if (din) next_state = S4; else next_state = S2;
            S4  : if (din) next_state = S1; else next_state = S2;
            default: next_state = IDLE;
        endcase
    end

    // 4. 第三段：输出逻辑（时序逻辑）
   
/*     always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            dout <= 1'b0;
        else if (curr_state == S4)  
            dout <= 1'b1;
        else
            dout <= 1'b0;
    end */

    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
            dout <= 1'b0;
        else if (curr_state == S3 && din == 1'b1) // 在S4状态又来了个1，说明凑齐了1011
            dout <= 1'b1;
        else
            dout <= 1'b0;
    end

endmodule