`include "core_struct.vh"
module Core (
    input clk,
    input rst,

    Mem_ift.Master imem_ift,
    Mem_ift.Master dmem_ift,

    output cosim_valid,
    output CorePack::CoreInfo cosim_core_info
);
    import CorePack::*;

    // fill your code
    // =========================================================================
    // Single-cycle CPU: CPI = 1, all stages (IF/ID/EX/MEM/WB) in one cycle
    // =========================================================================

    // ---- PC ----
    logic [63:0] pc;
    logic [63:0] next_pc;

    always_ff @(posedge clk or posedge rst) begin
        if(rst) pc <= '0;
        else    pc <= next_pc;
    end

    // ---- Instruction fetch (combinational) ----
    logic [31:0] inst;
    assign inst = pc[2] ? imem_ift.r_reply_bits.rdata[63:32]
                        : imem_ift.r_reply_bits.rdata[31:0];

    // ---- Decode fields ----
    logic [4:0]  rs1;
    logic [4:0]  rs2;
    logic [4:0]  rd;
    assign rs1 = inst[19:15];
    assign rs2 = inst[24:20];
    assign rd  = inst[11:7];

    // ---- Controller (combinational) ----
    logic        we_reg;
    logic        we_mem;
    logic        re_mem;
    logic        npc_sel;
    imm_op_enum  immgen_op;
    alu_op_enum  alu_op;
    cmp_op_enum  cmp_op;
    alu_asel_op_enum alu_asel;
    alu_bsel_op_enum alu_bsel;
    wb_sel_op_enum   wb_sel;
    mem_op_enum      mem_op;
    logic        illegal_inst;

    controller u_ctrl(
        .inst        (inst),
        .we_reg      (we_reg),
        .we_mem      (we_mem),
        .re_mem      (re_mem),
        .npc_sel     (npc_sel),
        .immgen_op   (immgen_op),
        .alu_op      (alu_op),
        .cmp_op      (cmp_op),
        .alu_asel    (alu_asel),
        .alu_bsel    (alu_bsel),
        .wb_sel      (wb_sel),
        .mem_op      (mem_op),
        .illegal_inst(illegal_inst)
    );

    // ---- Register file (write at posedge, read combinational) ----
    logic [63:0] read_data_1;
    logic [63:0] read_data_2;
    logic [63:0] wb_val;

    RegFile u_rf(
        .clk         (clk),
        .rst         (rst),
        .we          (we_reg),
        .read_addr_1 (rs1),
        .read_addr_2 (rs2),
        .write_addr  (rd),
        .write_data  (wb_val),
        .read_data_1 (read_data_1),
        .read_data_2 (read_data_2)
    );

    // ---- Immediate generation (combinational) ----
    logic [63:0] i_imm;
    logic [63:0] s_imm;
    logic [63:0] b_imm;
    logic [63:0] u_imm;
    logic [63:0] uj_imm;
    logic [63:0] imm;

    assign i_imm  = {{52{inst[31]}}, inst[31:20]};
    assign s_imm  = {{52{inst[31]}}, inst[31:25], inst[11:7]};
    assign b_imm  = {{51{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
    assign u_imm  = {{32{inst[31]}}, inst[31:12], 12'b0};
    assign uj_imm = {{43{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};

    always_comb begin
        case(immgen_op)
            I_IMM:  imm = i_imm;
            S_IMM:  imm = s_imm;
            B_IMM:  imm = b_imm;
            U_IMM:  imm = u_imm;
            UJ_IMM: imm = uj_imm;
            default: imm = i_imm;
        endcase
    end

    // ---- ALU inputs (mux) ----
    logic [63:0] alu_a;
    logic [63:0] alu_b;
    logic [63:0] alu_res;

    assign alu_a = alu_asel == ASEL_REG ? read_data_1 :
                   alu_asel == ASEL_PC  ? pc          : 64'b0;

    assign alu_b = alu_bsel == BSEL_REG ? read_data_2 :
                   alu_bsel == BSEL_IMM ? imm         : 64'b0;

    ALU u_alu(
        .a     (alu_a),
        .b     (alu_b),
        .alu_op(alu_op),
        .res   (alu_res)
    );

    // ---- Branch comparison ----
    logic br_taken;

    Cmp u_cmp(
        .a      (read_data_1),
        .b      (read_data_2),
        .cmp_op (cmp_op),
        .cmp_res(br_taken)
    );

    // ---- Memory (DMEM) ----
    mask_t           mask;
    logic [63:0] trunc_data;
    logic [63:0] dmem_wdata;

    MaskGen u_mask(
        .mem_op    (mem_op),
        .dmem_waddr(alu_res),
        .dmem_wmask(mask)
    );

    DataTrunc u_trunc(
        .dmem_rdata(dmem_ift.r_reply_bits.rdata),
        .mem_op    (mem_op),
        .dmem_raddr(alu_res),
        .read_data (trunc_data)
    );

    DataPkg u_datapkg(
        .mem_op    (mem_op),
        .reg_data  (read_data_2),
        .dmem_waddr(alu_res),
        .dmem_wdata(dmem_wdata)
    );

    // ---- Bus connections ----

    // IMEM (read-only, always requesting)
    assign imem_ift.r_request_bits.raddr = pc;
    assign imem_ift.r_request_valid      = 1'b1;
    assign imem_ift.r_reply_ready        = 1'b1;

    // DMEM read (combinational, suppressed during reset)
    assign dmem_ift.r_request_bits.raddr = alu_res;
    assign dmem_ift.r_request_valid      = re_mem && !rst;
    assign dmem_ift.r_reply_ready        = 1'b1;

    // DMEM write (sequential, at posedge clk, suppressed during reset)
    assign dmem_ift.w_request_bits.waddr = alu_res;
    assign dmem_ift.w_request_bits.wdata = dmem_wdata;
    assign dmem_ift.w_request_bits.wmask = mask;
    assign dmem_ift.w_request_valid      = we_mem && !rst;
    assign dmem_ift.w_reply_ready        = 1'b1;

    // ---- Next PC ----
    // Decode instruction classes locally (combinational, matches Controller)
    logic is_jal;
    logic is_jalr;
    logic is_branch;

    assign is_jal    = (inst[6:0] == 7'b1101111);
    assign is_jalr   = (inst[6:0] == 7'b1100111);
    assign is_branch = (inst[6:0] == 7'b1100011);

    // npc_sel from Controller covers JAL + JALR; branch_taken covers B-type
    assign next_pc = illegal_inst              ? 64'h0 :
                     is_jal                    ? alu_res :             // JAL:  pc + uj_imm
                     is_jalr                   ? {alu_res[63:1], 1'b0} : // JALR: (rs1 + imm) & ~1
                     (is_branch && br_taken)   ? alu_res :             // B-type taken: pc + b_imm
                                                 pc + 4;               // default: sequential

    // ---- Write-back mux ----
    always_comb begin
        case(wb_sel)
            WB_SEL_ALU: wb_val = alu_res;
            WB_SEL_MEM: wb_val = trunc_data;
            WB_SEL_PC:  wb_val = pc + 4;
            default:    wb_val = alu_res;
        endcase
    end

    // ---- Co-simulation debug signals (valid every cycle) ----
    assign cosim_valid = ~illegal_inst;

    assign cosim_core_info.pc        = pc;
    assign cosim_core_info.inst      = {32'b0, inst};
    assign cosim_core_info.rs1_id    = {59'b0, rs1};
    assign cosim_core_info.rs1_data  = read_data_1;
    assign cosim_core_info.rs2_id    = {59'b0, rs2};
    assign cosim_core_info.rs2_data  = read_data_2;
    assign cosim_core_info.alu       = alu_res;
    assign cosim_core_info.mem_addr  = alu_res;
    assign cosim_core_info.mem_we    = {63'b0, dmem_ift.w_request_valid};
    assign cosim_core_info.mem_wdata = dmem_ift.w_request_bits.wdata;
    assign cosim_core_info.mem_rdata = dmem_ift.r_reply_bits.rdata;
    assign cosim_core_info.rd_we     = {63'b0, we_reg};
    assign cosim_core_info.rd_id     = {59'b0, rd};
    assign cosim_core_info.rd_data   = wb_val;
    assign cosim_core_info.br_taken  = {63'b0, br_taken};
    assign cosim_core_info.npc       = next_pc;

endmodule
