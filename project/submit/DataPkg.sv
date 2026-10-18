`include "core_struct.vh"

module DataPkg(
    input CorePack::mem_op_enum mem_op,
    input CorePack::data_t reg_data,
    input CorePack::addr_t dmem_waddr,
    output CorePack::data_t dmem_wdata
);

  import CorePack::*;

  // Data package
  // fill your code
 always_comb begin
    case(mem_op)
      MEM_B:  dmem_wdata = {8{reg_data[7:0]}};
      MEM_H:  dmem_wdata = {4{reg_data[15:0]}};
      MEM_W:  dmem_wdata = {2{reg_data[31:0]}};
      default:dmem_wdata = reg_data;
    endcase
  end
endmodule
