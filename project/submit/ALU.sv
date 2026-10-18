`include "core_struct.vh"
module ALU (
  input  CorePack::data_t a,
  input  CorePack::data_t b,
  input  CorePack::alu_op_enum  alu_op,
  output CorePack::data_t res
);

  import CorePack::*;

  // fill your code
  logic [31:0] w32_add;
  logic [31:0] w32_sub;
  logic [31:0] w32_sll;
  logic [31:0] w32_srl;
  logic [31:0] w32_sra;

  assign w32_add = a[31:0] + b[31:0];
  assign w32_sub = a[31:0] - b[31:0];
  assign w32_sll = a[31:0] << b[4:0];
  assign w32_srl = a[31:0] >> b[4:0];
  assign w32_sra = $signed(a[31:0]) >>> b[4:0];

 always_comb begin
    case(alu_op)
      ALU_ADD:  res = a + b;
      ALU_SUB:  res = a - b;
      ALU_SLL:  res = a << b[5:0];
      ALU_SLT:  res = ($signed(a) < $signed(b)) ? 64'd1 : 64'd0;
      ALU_SLTU: res = (a < b) ? 64'd1 : 64'd0;
      ALU_XOR:  res = a ^ b;
      ALU_SRL:  res = a >> b[5:0];
      ALU_SRA:  res = $signed(a) >>> b[5:0];
      ALU_OR:   res = a | b;
      ALU_AND:  res = a & b;
      ALU_ADDW: res = {{32{w32_add[31]}}, w32_add};
      ALU_SUBW: res = {{32{w32_sub[31]}}, w32_sub};
      ALU_SLLW: res = {{32{w32_sll[31]}}, w32_sll};
      ALU_SRLW: res = {{32{w32_srl[31]}}, w32_srl};
      ALU_SRAW: res = {{32{w32_sra[31]}}, w32_sra};
      default:  res = 64'd0;
    endcase
  end
endmodule
