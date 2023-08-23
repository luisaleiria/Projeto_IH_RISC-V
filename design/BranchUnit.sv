`timescale 1ns / 1ps

module BranchUnit #(
    parameter PC_W = 9,
    parameter DATA_WIDTH = 32
) (
    input logic [PC_W-1:0] Cur_PC,
    input logic [31:0] Imm_out,
    input logic Branch,
    input logic [31:0] AluResult,
    input logic [2:0] Funct3,
    input logic [DATA_WIDTH-1:0]    SrcA,
    input logic [DATA_WIDTH-1:0]    SrcB,
    output logic [31:0] PC_Imm,
    output logic [31:0] PC_Four,
    output logic [31:0] BrPC,
    output logic PcSel
);

  logic Branch_Sel;
  logic BranchResult;
  logic [31:0] PC_Full;
  always_comb
    begin
        case(Funct3)
        3'b000:        // BEQ
                BranchResult = (SrcA == SrcB) ? 1 : 0;
        3'b001:        // BNE
                BranchResult = (SrcA != SrcB) ? 1 : 0;
        3'b100:        // BLT
                BranchResult = (SrcA < SrcB) ? 1 : 0;
        3'b101:        // BGE
                BranchResult = (SrcA > SrcB) ? 1 : 0;
        default:
                BranchResult = 0;
        endcase
    end
  assign PC_Full = {23'b0, Cur_PC};

  assign PC_Imm = PC_Full + Imm_out;
  assign PC_Four = PC_Full + 32'b100;
  assign Branch_Sel = Branch && BranchResult;  // 0:Branch is taken; 1:Branch is not taken

  assign BrPC = (Branch_Sel) ? PC_Imm : 32'b0;  // Branch -> PC+Imm   // Otherwise, BrPC value is not important
  assign PcSel = Branch_Sel;  // 1:branch is taken; 0:branch is not taken(choose pc+4)

endmodule
