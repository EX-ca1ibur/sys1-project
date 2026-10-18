module Mux4T1_32(
    input [31:0] I0,
    input [31:0] I1,
    input [31:0] I2,
    input [31:0] I3,
    input [1:0] S,
    output [31:0] O
);
wire [31:0] inputs[3:0]; 

assign inputs[0] = I0;
assign inputs[1] = I1;
assign inputs[2] = I2;
assign inputs[3] = I3;

assign O = inputs[S];

    //fill your code

endmodule

