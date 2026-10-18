`include"conv_struct.vh"
module Shift (
    input clk,
    input rst,
    input Conv::data_t in_data,
    input in_valid,
    output reg in_ready,

    output Conv::data_vector data,
    output reg out_valid,
    input out_ready
);

    typedef enum logic {RDATA, TDATA} fsm_state;
    fsm_state state_reg;
    Conv::data_t data_reg [Conv::LEN-1:0];

    // fill the code

    integer i;

    assign data.data[0] = data_reg[0];
    assign data.data[1] = data_reg[1];
    assign data.data[2] = data_reg[2];
    assign data.data[3] = data_reg[3];

    always_ff @(posedge clk) begin
        if (rst) begin
            state_reg <= RDATA;
            in_ready <= 1'b0;
            out_valid <= 1'b0;
            for (i = 0; i < Conv::LEN; i = i + 1) begin
                data_reg[i] <= '0;
            end
        end else begin
            case (state_reg)
                RDATA: begin
                    in_ready <= 1'b1;
                    out_valid <= 1'b0;
                    if (in_valid && in_ready) begin
                        // 握手成功，立即撤销 in_ready 防止下一周期被误判为再次握手
                        in_ready <= 1'b0;
                        data_reg[0] <= data_reg[1];
                        data_reg[1] <= data_reg[2];
                        data_reg[2] <= data_reg[3];
                        data_reg[3] <= in_data;
                        state_reg <= TDATA;
                    end
                end
                TDATA: begin
                    in_ready <= 1'b0;
                    out_valid <= 1'b1;
                    if (out_valid && out_ready) begin
                        out_valid <= 1'b0;
                        state_reg <= RDATA;
                    end
                end
                default: begin
                    state_reg <= RDATA;
                    in_ready <= 1'b0;
                    out_valid <= 1'b0;
                end
            endcase
        end
    end

endmodule
