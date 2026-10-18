`include "core_struct.vh"

module DataTrunc (
    input CorePack::data_t dmem_rdata,
    input CorePack::mem_op_enum mem_op,
    input CorePack::addr_t dmem_raddr,
    output CorePack::data_t read_data
);

  import CorePack::*;

  // Data trunction
  // fill your code
logic [7:0]  b_data;
  logic [15:0] h_data;
  logic [31:0] w_data;

  assign b_data = dmem_rdata[ (dmem_raddr[2:0] * 8) +: 8 ];
  assign h_data = dmem_rdata[ (dmem_raddr[2:1] * 16) +: 16 ];
  assign w_data = dmem_rdata[ (dmem_raddr[2] * 32) +: 32 ];

  always_comb begin
    case(mem_op)
      MEM_B:   read_data = {{56{b_data[7]}}, b_data};
      MEM_H:   read_data = {{48{h_data[15]}}, h_data};
      MEM_W:   read_data = {{32{w_data[31]}}, w_data};
      MEM_UB:  read_data = {56'd0, b_data};
      MEM_UH:  read_data = {48'd0, h_data};
      MEM_UW:  read_data = {32'd0, w_data};
      default: read_data = dmem_rdata;
    endcase
  end

endmodule
