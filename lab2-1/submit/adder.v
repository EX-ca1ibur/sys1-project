module Adder(
    input a,
    input b,
    input c_in,
    output s,
    output c_out
);
     assign s=a^b^c_in;
    assign c_out=(a&b)|(a&c_in)|(b&c_in);
    //fill your code here
    
endmodule 
