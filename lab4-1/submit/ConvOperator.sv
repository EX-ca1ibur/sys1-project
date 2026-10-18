`include"conv_struct.vh"
module ConvOperator(
    input clk,
    input rst,
    input Conv::data_vector kernel,
    input Conv::data_vector data,
    input in_valid,
    output reg in_ready,

    output Conv::result_t result,
    output reg out_valid,
    input out_ready
);

    localparam VECTOR_WIDTH = 2*Conv::WIDTH;
    typedef struct {
        Conv::result_t data;
        logic valid;
    } mid_vector;

    mid_vector vector_stage1 [Conv::LEN-1:0];
    mid_vector vector_stage2;

    typedef enum logic [1:0] {RDATA, WORK, TDATA} fsm_state;
    fsm_state state_reg;

    logic mult_start;
    logic [Conv::LEN-1:0] mult_finish;
    Conv::result_t mult_product [Conv::LEN-1:0];
    logic all_mult_finish;

    genvar gi;
    generate
        for (gi = 0; gi < Conv::LEN; gi = gi + 1) begin : gen_mult
            Multiplier #(.LEN(Conv::WIDTH)) u_mult (
                .clk(clk),
                .rst(rst),
                .multiplicand(data.data[gi]),
                .multiplier(kernel.data[gi]),
                .start(mult_start),
                .product(mult_product[gi]),
                .finish(mult_finish[gi])
            );
        end
    endgenerate

    assign all_mult_finish = &mult_finish;
    assign result = vector_stage2.data;

    // 并行加法树 (Parallel Adder Tree)
    // 将 4 个乘积累加: ((p0 + p1) + (p2 + p3))
    // add_tmp[2] = stage1[0] + stage1[1]
    // add_tmp[3] = stage1[2] + stage1[3]
    // add_tmp[1] = add_tmp[2] + add_tmp[3]  ← 树根，最终结果
    Conv::result_t add_tmp [Conv::LEN-1:1] /* verilator split_var */;
    generate
        for (genvar gi = 1; gi < Conv::LEN; gi = gi + 1) begin : gen_adder
            if (gi < Conv::LEN / 2) begin
                // 上层：两个下层结果的加法
                assign add_tmp[gi] = add_tmp[gi*2] + add_tmp[gi*2+1];
            end else begin
                // 底层：从 vector_stage1 读取乘法结果两两相加
                assign add_tmp[gi] = vector_stage1[(gi-Conv::LEN/2)*2].data
                                   + vector_stage1[(gi-Conv::LEN/2)*2+1].data;
            end
        end
    endgenerate

    integer i;
    always_ff @(posedge clk) begin
        if (rst) begin
            state_reg <= RDATA;
            in_ready <= 1'b0;
            out_valid <= 1'b0;
            mult_start <= 1'b0;
            vector_stage2.data <= '0;
            vector_stage2.valid <= 1'b0;
            for (i = 0; i < Conv::LEN; i = i + 1) begin
                vector_stage1[i].data <= '0;
                vector_stage1[i].valid <= 1'b0;
            end
        end else begin
            case (state_reg)
                RDATA: begin
                    in_ready <= 1'b1;
                    out_valid <= 1'b0;
                    if (in_valid && in_ready) begin
                        // 握手成功，立即撤销 in_ready 并启动乘法器
                        in_ready <= 1'b0;
                        mult_start <= 1'b1;
                        for (i = 0; i < Conv::LEN; i = i + 1) begin
                            vector_stage1[i].valid <= 1'b0;
                        end
                        vector_stage2.valid <= 1'b0;
                        state_reg <= WORK;
                        $display("[ConvOperator] Got data: d0=%x d1=%x d2=%x d3=%x",
                                 data.data[0], data.data[1], data.data[2], data.data[3]);
                    end
                end
                WORK: begin
                    in_ready <= 1'b0;
                    mult_start <= 1'b0;
                    // 第1拍：乘法器全部完成 → 锁存乘积到 vector_stage1
                    if (all_mult_finish) begin
                        for (i = 0; i < Conv::LEN; i = i + 1) begin
                            vector_stage1[i].data <= mult_product[i];
                            vector_stage1[i].valid <= 1'b1;
                        end
                    end
                    // 第2拍：vector_stage1 数据有效 →
                    // 并行加法树组合逻辑输出稳定 → 锁存到 vector_stage2
                    // (vector_stage1[i].valid 使用 NB 赋值，下一周期才可见)
                    if (vector_stage1[0].valid) begin
                        vector_stage2.data <= add_tmp[1];  // 并行加法树根节点
                        vector_stage2.valid <= 1'b1;
                        state_reg <= TDATA;
                        $display("[ConvOperator] Stage2 result: %x (products: %x,%x,%x,%x)",
                                 add_tmp[1], vector_stage1[0].data, vector_stage1[1].data,
                                 vector_stage1[2].data, vector_stage1[3].data);
                    end
                end
                TDATA: begin
                    out_valid <= 1'b1;
                    if (out_valid && out_ready) begin
                        // 握手成功，必须立即撤销 valid 防止重复采样
                        out_valid <= 1'b0;
                        state_reg <= RDATA;
                    end
                end
                default: begin
                    state_reg <= RDATA;
                    in_ready <= 1'b0;
                    out_valid <= 1'b0;
                    mult_start <= 1'b0;
                end
            endcase
        end
    end

endmodule
