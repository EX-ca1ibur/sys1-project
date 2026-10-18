`timescale 1ns / 1ps

module SegDecoder (
    input wire [3:0] data,
    input wire point,
    input wire LE,

    output wire a,
    output wire b,
    output wire c,
    output wire d,
    output wire e,
    output wire f,
    output wire g,
    output wire p
);
  
  wire wire0, wire1, wire2, wire3;
  wire inv_wire0, inv_wire1, inv_wire2, inv_wire3;
  assign {wire3 ,wire2, wire1, wire0} = data;
  assign {inv_wire0, inv_wire1, inv_wire2, inv_wire3} = {~wire0, ~wire1, ~wire2, ~wire3};
  
  // minterms for number 0-f
  wire [15:0] and_gate;

  assign and_gate[0] = inv_wire0 & inv_wire1 & inv_wire2 & inv_wire3;
  assign and_gate[1] = wire0 & inv_wire1 & inv_wire2 & inv_wire3; // 1
  assign and_gate[2] = inv_wire0 & wire1 & inv_wire2 & inv_wire3;
  assign and_gate[3] = wire0 & wire1 & inv_wire2 & inv_wire3;
  assign and_gate[4] = inv_wire0 & inv_wire1 & wire2 & inv_wire3; // 4  
  assign and_gate[5] = wire0 & inv_wire1 & wire2 & inv_wire3;
  assign and_gate[6] = inv_wire0 & wire1 & wire2 & inv_wire3;
  assign and_gate[7] = wire0 & wire1 & wire2 & inv_wire3;
  assign and_gate[8] = inv_wire0 & inv_wire1 & inv_wire2 & wire3;
  assign and_gate[9] = wire0 & inv_wire1 & inv_wire2 & wire3;
  assign and_gate[10] = inv_wire0 & wire1 & inv_wire2 & wire3; // A
  assign and_gate[11] = wire0 & wire1 & inv_wire2 & wire3; // B
  assign and_gate[12] = inv_wire0 & inv_wire1 & wire2 & wire3; // C
  assign and_gate[13] = wire0 & inv_wire1 & wire2 & wire3; // D
  assign and_gate[14] = inv_wire0 & wire1 & wire2 & wire3; // E
  assign and_gate[15] = wire0 & wire1 & wire2 & wire3; // F

  wire a_or, a_result;
  assign a_or = and_gate[1] | and_gate[4] | and_gate[11] | and_gate[13];
  assign a_result = a_or | LE;
  assign a = a_result;

  
  wire b_or;
  assign b_or = and_gate[5] | and_gate[6] | and_gate[11] | and_gate[12] | and_gate[14] | and_gate[15];
  assign b = b_or | LE;
  
 
  wire c_or;
  assign c_or = and_gate[2] | and_gate[12] | and_gate[14] | and_gate[15];
  assign c = c_or | LE;
  

   wire d_or;
  assign d_or = and_gate[1] | and_gate[4] | and_gate[7] | and_gate[10] | and_gate[15];
  assign d = d_or | LE;
 
  wire e_or;
  assign e_or = and_gate[1] | and_gate[3] | and_gate[4] | and_gate[5] | and_gate[7] | and_gate[9];
  assign e = e_or | LE;
  
 
  wire f_or;
  assign f_or = and_gate[1] | and_gate[2] | and_gate[3] | and_gate[7] | and_gate[13];
  assign f = f_or | LE;
  
 
  wire g_or;
  assign g_or = and_gate[0] | and_gate[1] | and_gate[7] | and_gate[12];
  assign g = g_or | LE;
  
  
  assign p = (~point) | LE;

endmodule