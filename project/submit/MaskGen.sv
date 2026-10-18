`include "core_struct.vh"

module MaskGen(
    input CorePack::mem_op_enum mem_op,
    input CorePack::addr_t dmem_waddr,
    output CorePack::mask_t dmem_wmask
);

  import CorePack::*;

  // Mask generation
  // fill your code
 always_comb begin
        case(mem_op)
            MEM_B:  dmem_wmask = 8'b00000001 << dmem_waddr[2:0];
            MEM_H:  dmem_wmask = 8'b00000011 << {dmem_waddr[2:1], 1'b0};
            MEM_W:  dmem_wmask = 8'b00001111 << {dmem_waddr[2],   2'b00};
            default: dmem_wmask = 8'b11111111;
        endcase
    end
endmodule
