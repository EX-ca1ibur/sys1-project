module main( 
   input I0,
   input I1,
   input I2,
   input I3,
   output O 
);
wire A = I3;
wire B = I2;
wire C = I1;
wire D = I0;
assign O = (~B & ~C & ~D) | (~A & ~B & C) | (~A & B & D) | (C & D) | (A & C);

endmodule
