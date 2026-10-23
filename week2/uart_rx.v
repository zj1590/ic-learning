module uart_rx #(
    parameter CLK_FREQ = 50_000_000, 
    parameter BAUD_RATE = 115_200    
)(
    input clk,
    input rst_n,
    input rx,                // 接收引脚（别人发给你的数据）
    output reg [7:0] rx_data,// 接收到的 8 位数据
    output reg rx_done       // 接收完成标志（接收完拉高一个周期）
);

    localparam BPS_CNT = CLK_FREQ / BAUD_RATE; 
    localparam HALF_BPS = BPS_CNT / 2; // 半个周期，用于找中点

    // 状态定义
    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    reg [1:0] state;
    reg [15:0] clk_cnt;
    reg [2:0] bit_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            rx_data <= 0;
            rx_done <= 0;
            clk_cnt <= 0;
            bit_cnt <= 0;
        end else begin
            case (state)
                IDLE: begin
                    rx_done <= 1'b0;
                    if (rx == 1'b0) begin // 突然检测到低电平，说明起始位来了！
                        state <= START;
                        clk_cnt <= 0;
                    end
                end
                
                START: begin
                    // 等半个周期，刚好对准起始位的正中间
                    if (clk_cnt == HALF_BPS - 1) begin
                        clk_cnt <= 0;
                        if (rx == 1'b0) begin // 确认一下真的是起始位，不是毛刺
                            state <= DATA;
                            bit_cnt <= 0;
                        end else begin
                            state <= IDLE; // 是假信号，回去继续睡
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end
                
                DATA: begin
                    // 每等一个完整周期，采一次数据
                    if (clk_cnt == BPS_CNT - 1) begin
                        clk_cnt <= 0;
                        rx_data[bit_cnt] <= rx; // 把采到的 0 或 1 存进对应的位里
                        if (bit_cnt == 3'd7) begin
                            state <= STOP;
                        end else begin
                            bit_cnt <= bit_cnt + 1'b1;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end
                
                STOP: begin
                    // 等一个完整周期，应该采到高电平（停止位）
                    if (clk_cnt == BPS_CNT - 1) begin
                        clk_cnt <= 0;
                        state <= IDLE;
                        rx_done <= 1'b1; // 报告老板：接收到一个完整字节了！
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end
            endcase
        end
    end
endmodule