module Cnt2num #(
    parameter BASE = 24,
    parameter INITIAL = 16
)(
    input en,
    input clk,
    input rstn,
    input high_rst,
    input low_co,
    output co,
    output [7:0] cnt
);

    localparam HIGH_BASE = 10;
    localparam LOW_BASE  = 10;
    localparam HIGH_INIT = INITIAL/10;
    localparam LOW_INIT  = INITIAL%10;
    localparam HIGH_CO   = (BASE-1)/10;
    localparam LOW_CO    = (BASE-1)%10;

 wire [3:0] high_cnt;
    wire [3:0] low_cnt;
    wire low_co_wire;
    wire inner_rst;

    assign inner_rst = (high_cnt == 4'(HIGH_CO)) && (low_cnt == 4'(LOW_CO)) && en && low_co;
    assign co = inner_rst;
    assign cnt = {high_cnt, low_cnt};

    Cnt #(
        .BASE(LOW_BASE),
        .INITIAL(LOW_INIT)
    ) u_low_cnt (
        .en(en),
        .clk(clk),
        .rstn(rstn),
        .low_co(low_co),
        .high_rst(high_rst | inner_rst),
        .co(low_co_wire),
        .cnt(low_cnt)
    );

    Cnt #(
        .BASE(HIGH_BASE),
        .INITIAL(HIGH_INIT)
    ) u_high_cnt (
        .en(en),
        .clk(clk),
        .rstn(rstn),
        .low_co(low_co_wire),
        .high_rst(high_rst | inner_rst),
        .co(),
        .cnt(high_cnt)
    );// fill the code

    

endmodule