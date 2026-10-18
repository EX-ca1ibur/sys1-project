module Cnt #(
    parameter BASE = 10,
    parameter INITIAL = 0
) (
    input en,
    input clk,
    input rstn,
    input low_co,
    input high_rst,
    output co,
    output reg [3:0] cnt
);

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        cnt <= 4'(INITIAL);
    end else if (high_rst) begin
        cnt <= 4'd0;
    end else if (en && low_co) begin
        if (cnt == 4'(BASE) - 4'd1) begin
            cnt <= 4'd0;
        end else begin
            cnt <= cnt + 4'd1;
        end
    end
end

assign co = (cnt == 4'(BASE) - 4'd1) && en && low_co;// fill the code

endmodule