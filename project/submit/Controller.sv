`include "core_struct.vh"
module controller (
    input CorePack::inst_t inst,
    output logic we_reg,
    output logic we_mem,
    output logic re_mem,
    output logic npc_sel,
    output CorePack::imm_op_enum immgen_op,
    output CorePack::alu_op_enum alu_op,
    output CorePack::cmp_op_enum cmp_op,
    output CorePack::alu_asel_op_enum alu_asel,
    output CorePack::alu_bsel_op_enum alu_bsel,
    output CorePack::wb_sel_op_enum wb_sel,
    output CorePack::mem_op_enum mem_op,
    output logic illegal_inst
    // output ControllerPack::ControllerSignals ctrl_signals
);

    import CorePack::*;
    // import ControllerPack::*;
    
    // fill your code
  logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = inst[6:0];
    assign funct3 = inst[14:12];
    assign funct7 = inst[31:25];

    logic inst_rtype;
    logic inst_itype;
    logic inst_load;
    logic inst_store;
    logic inst_branch;
    logic inst_jal;
    logic inst_jalr;
    logic inst_lui;
    logic inst_auipc;
    logic inst_immw;
    logic inst_regw;

    assign inst_rtype  = (opcode == 7'b0110011);
    assign inst_itype  = (opcode == 7'b0010011);
    assign inst_load   = (opcode == 7'b0000011);
    assign inst_store  = (opcode == 7'b0100011);
    assign inst_branch = (opcode == 7'b1100011);
    assign inst_jal    = (opcode == 7'b1101111);
    assign inst_jalr   = (opcode == 7'b1100111);
    assign inst_lui    = (opcode == 7'b0110111);
    assign inst_auipc  = (opcode == 7'b0010111);
    assign inst_immw   = (opcode == 7'b0011011);
    assign inst_regw   = (opcode == 7'b0111011);

    logic load_lb;
    logic load_lh;
    logic load_lw;
    logic load_ld;
    logic load_lbu;
    logic load_lhu;
    logic load_lwu;

    assign load_lb  = inst_load && (funct3 == 3'b000);
    assign load_lh  = inst_load && (funct3 == 3'b001);
    assign load_lw  = inst_load && (funct3 == 3'b010);
    assign load_ld  = inst_load && (funct3 == 3'b011);
    assign load_lbu = inst_load && (funct3 == 3'b100);
    assign load_lhu = inst_load && (funct3 == 3'b101);
    assign load_lwu = inst_load && (funct3 == 3'b110);

    logic store_sb;
    logic store_sh;
    logic store_sw;
    logic store_sd;

    assign store_sb = inst_store && (funct3 == 3'b000);
    assign store_sh = inst_store && (funct3 == 3'b001);
    assign store_sw = inst_store && (funct3 == 3'b010);
    assign store_sd = inst_store && (funct3 == 3'b011);

    assign we_reg = inst_rtype | inst_itype | inst_load | inst_jal | inst_jalr | inst_lui | inst_auipc | inst_immw | inst_regw;
    assign we_mem = inst_store;
    assign re_mem = inst_load;
    assign npc_sel = inst_jal | inst_jalr;
    
    always_comb begin
        case(1'b1)
            inst_itype | inst_load | inst_jalr | inst_immw: immgen_op = I_IMM;
            inst_store:                            immgen_op = S_IMM;
            inst_branch:                           immgen_op = B_IMM;
            inst_lui | inst_auipc:                 immgen_op = U_IMM;
            inst_jal:                               immgen_op = UJ_IMM;
            default:                                immgen_op = I_IMM;
        endcase
    end

    always_comb begin
        if(inst_rtype | inst_regw) begin
            case({funct7, funct3})
                {7'b0000000, 3'b000}: alu_op = inst_regw ? ALU_ADDW : ALU_ADD;
                {7'b0100000, 3'b000}: alu_op = inst_regw ? ALU_SUBW : ALU_SUB;
                {7'b0000000, 3'b001}: alu_op = inst_regw ? ALU_SLLW : ALU_SLL;
                {7'b0000000, 3'b010}: alu_op = ALU_SLT;
                {7'b0000000, 3'b011}: alu_op = ALU_SLTU;
                {7'b0000000, 3'b100}: alu_op = ALU_XOR;
                {7'b0000000, 3'b101}: alu_op = inst_regw ? ALU_SRLW : ALU_SRL;
                {7'b0100000, 3'b101}: alu_op = inst_regw ? ALU_SRAW : ALU_SRA;
                {7'b0000000, 3'b110}: alu_op = ALU_OR;
                {7'b0000000, 3'b111}: alu_op = ALU_AND;
                default:               alu_op = ALU_ADD;
            endcase
        end else if(inst_itype | inst_immw) begin
            case(funct3)
                3'b000: alu_op = inst_immw ? ALU_ADDW : ALU_ADD;
                3'b001: alu_op = inst_immw ? ALU_SLLW : ALU_SLL;
                3'b010: alu_op = ALU_SLT;
                3'b011: alu_op = ALU_SLTU;
                3'b100: alu_op = ALU_XOR;
                3'b101: alu_op = inst_immw ? (funct7[5] ? ALU_SRAW : ALU_SRLW) : (funct7[5] ? ALU_SRA : ALU_SRL);
                3'b110: alu_op = ALU_OR;
                3'b111: alu_op = ALU_AND;
                default: alu_op = ALU_ADD;
            endcase
        end else begin
            alu_op = ALU_ADD;
        end
    end

    always_comb begin
        if(inst_branch) begin
            case(funct3)
                3'b000: cmp_op = CMP_EQ;
                3'b001: cmp_op = CMP_NE;
                3'b100: cmp_op = CMP_LT;
                3'b101: cmp_op = CMP_GE;
                3'b110: cmp_op = CMP_LTU;
                3'b111: cmp_op = CMP_GEU;
                default: cmp_op = CMP_EQ;
            endcase
        end else begin
            cmp_op = CMP_EQ;
        end
    end

    assign alu_asel = inst_auipc | inst_jal | inst_branch ? ASEL_PC :
                     inst_lui                              ? ASEL0  :
                                                             ASEL_REG;
    assign alu_bsel = inst_itype | inst_immw | inst_load | inst_store | inst_lui | inst_auipc | inst_jal | inst_jalr | inst_branch ? BSEL_IMM : BSEL_REG;

    assign wb_sel = inst_load                ? WB_SEL_MEM :
                   (inst_jal | inst_jalr) ? WB_SEL_PC  :
                                            WB_SEL_ALU;

    always_comb begin
        case(1'b1)
            load_lw:  mem_op = MEM_W;
            store_sw: mem_op = MEM_W;
            load_lh:  mem_op = MEM_H;
            load_lb:  mem_op = MEM_B;
            load_ld:  mem_op = MEM_D;
            load_lhu: mem_op = MEM_UH;
            load_lbu: mem_op = MEM_UB;
            load_lwu: mem_op = MEM_UW;
            store_sh: mem_op = MEM_H;
            store_sb: mem_op = MEM_B;
            store_sd: mem_op = MEM_D;
            default:  mem_op = MEM_NO;
        endcase
    end

    // illegal instruction detection
    assign illegal_inst = ~(inst_rtype | inst_itype | inst_load | inst_store |
                            inst_branch | inst_jal | inst_jalr | inst_lui |
                            inst_auipc | inst_immw | inst_regw);

endmodule
