module Multiplier #(
    parameter LEN = 32
) (
    input clk,
    input rst,
    input [LEN-1:0] multiplicand,
    input [LEN-1:0] multiplier,
    input start,
    
    output [LEN*2-1:0] product,
    output finish
);

    localparam PRODUCT_LEN = LEN*2;
    logic [LEN-1:0] multiplicand_reg;
    logic [PRODUCT_LEN-1:0] product_reg;

    localparam CNT_LEN = $clog2(LEN);
    typedef enum logic [1:0] {IDLE, WORK, FINAL} fsm_state;
    fsm_state fsm_state_reg;
    fsm_state fsm_state_next;
    logic [CNT_LEN-1:0] work_cnt;

    localparam CNT_NUM = CNT_LEN'(LEN - 1);

    logic [LEN:0] high_sum;
    logic [PRODUCT_LEN:0] product_shift_src;
    logic [PRODUCT_LEN-1:0] product_next;

    assign product = product_reg;
    assign finish  = (fsm_state_reg == FINAL);

    always_comb begin
        fsm_state_next = fsm_state_reg;
        case (fsm_state_reg)
            IDLE: if (start) fsm_state_next = WORK;
            WORK: if (work_cnt == CNT_NUM) fsm_state_next = FINAL;
            FINAL: fsm_state_next = IDLE;
            default: fsm_state_next = IDLE;
        endcase
    end

    always_comb begin
        if (product_reg[0]) begin
            high_sum = {1'b0, product_reg[PRODUCT_LEN-1:LEN]} + {1'b0, multiplicand_reg};
        end else begin
            high_sum = {1'b0, product_reg[PRODUCT_LEN-1:LEN]};
        end
        product_shift_src = {high_sum, product_reg[LEN-1:0]};
        product_next = product_shift_src[PRODUCT_LEN:1];
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            multiplicand_reg <= {LEN{1'b0}};
            product_reg      <= {PRODUCT_LEN{1'b0}};
            work_cnt         <= {CNT_LEN{1'b0}};
            fsm_state_reg    <= IDLE;
        end else begin
            fsm_state_reg <= fsm_state_next;
            case (fsm_state_reg)
                IDLE: begin
                    if (start) begin
                        multiplicand_reg <= multiplicand;
                        product_reg      <= {{LEN{1'b0}}, multiplier};
                        work_cnt         <= '0;
                    end
                end
                WORK: begin
                    product_reg <= product_next;
                    work_cnt <= work_cnt + 1'b1;
                end
                FINAL: begin
                end
                default: begin
                end
            endcase
        end
    end
endmodule