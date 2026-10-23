module uart_tx #(
    parameter CLK_FREQ = 50_000_000, // 假设真实系统时钟 50MHz
    parameter BAUD_RATE = 115_200    // 假设波特率 115200
)(
    input clk,
    input rst_n,
    input tx_start,          // 发送触发信号（按一下发一次）
    input [7:0] tx_data,     // 要发送的 8 位数据
    output reg tx,           // 串口发送线
    output reg tx_busy       // 忙碌标志
);

    // 算一下发一个 bit 需要多少个时钟周期
    localparam BPS_CNT = CLK_FREQ / BAUD_RATE; 

    // 状态机定义
    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    reg [1:0] state;
    reg [15:0] clk_cnt;      // 波特率计数器
    reg [2:0] bit_cnt;       // 数据位计数器 (0~7)
    reg [7:0] data_reg;      // 暂存要发送的数据

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            tx <= 1'b1;
            tx_busy <= 1'b0;
            clk_cnt <= 0;
            bit_cnt <= 0;
            data_reg <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    if (tx_start) begin
                        tx_busy <= 1'b1;
                        data_reg <= tx_data; // 把数据抓进来
                        state <= START;
                        clk_cnt <= 0;
                    end
                end
                
                START: begin
                    tx <= 1'b0; // 起始位拉低
                    if (clk_cnt == BPS_CNT - 1) begin
                        clk_cnt <= 0;
                        state <= DATA;
                        bit_cnt <= 0;
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end
                
                DATA: begin
                    tx <= data_reg[bit_cnt]; // 低位先发 (LSB first)
                    if (clk_cnt == BPS_CNT - 1) begin
                        clk_cnt <= 0;
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
                    tx <= 1'b1; // 停止位拉高
                    if (clk_cnt == BPS_CNT - 1) begin
                        clk_cnt <= 0;
                        state <= IDLE;
                        tx_busy <= 1'b0;
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end
            endcase
        end
    end
endmodule