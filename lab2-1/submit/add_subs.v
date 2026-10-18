module AddSubers #(
    parameter LENGTH = 32
)(
    input [LENGTH-1:0] a,
    input [LENGTH-1:0] b,
    input do_sub,
    output [LENGTH-1:0] s,
    output c
);
    wire [LENGTH-1:0] b_new;
    assign b_new = do_sub ? ~b : b;

    Adders #(
    .LENGTH(LENGTH)
    ) 
    adders_inst(
    .a(a),
    .b(b_new),
    .c_in(do_sub),
    .s(s),
    .c_out(c)
    );
    //fill your code here
    
endmodule