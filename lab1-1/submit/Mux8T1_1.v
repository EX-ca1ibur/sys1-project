module Mux8T1_1( 
   input [7:0] I,
   input [2:0] S,
   output O 
);

wire out0, out1;

MUX4T1_1 mux0 (
    .I0(I[0]),
    .I1(I[1]),
    .I2(I[2]),
    .I3(I[3]),
    .S (S[1:0]),
    .O (out0)
);


MUX4T1_1 mux1 (
    .I0(I[4]),
    .I1(I[5]),
    .I2(I[6]),
    .I3(I[7]),
    .S (S[1:0]),
    .O (out1)
);


assign O = S[2] ? out1 : out0;//your verilog code
   
endmodule
