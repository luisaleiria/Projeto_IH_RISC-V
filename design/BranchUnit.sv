`timescale 1ns / 1ps

module BranchUnit #(
    parameter PC_W = 9,
    parameter DATA_WIDTH = 32
) (
    input logic [1:0] ALUOp,
    input logic [PC_W-1:0] Cur_PC,
    input logic [31:0] Imm_out,
    input logic Branch,
    input logic [31:0] AluResult,
    input logic [2:0] Funct3,
    input logic JalRType,
    input logic halt,
    input logic [DATA_WIDTH-1:0]    SrcA,
    input logic [DATA_WIDTH-1:0]    SrcB,
    output logic [31:0] PC_Imm,
    output logic [31:0] PC_Four,
    output logic [31:0] BrPC,
    output logic PcSel,
    output logic IsJal
);

  logic Branch_Sel;
  logic halt_flag;
  logic BranchResultBType;
  logic BranchResultJType;
  logic BranchResult;
  logic [31:0] PC_Full;
  always_comb
    begin
        case(Funct3)
        3'b000:        // BEQ
                BranchResultBType = (SrcA == SrcB) ? 1 : 0;
        3'b001:        // BNE
                BranchResultBType = (SrcA != SrcB) ? 1 : 0;
        3'b100:        // BLT
                BranchResultBType = (SrcA < SrcB) ? 1 : 0;
        3'b101:        // BGE
                BranchResultBType = (SrcA > SrcB) ? 1 : 0;
        default:
                BranchResultBType = 0;
        endcase
    end
  always_comb
    begin
        case(ALUOp)
        2'b11:        // JAL
                begin
                BranchResultJType = 1;
                IsJal = 1;
                end
        2'b01:        // NOT JAL
                begin
                BranchResultJType = 0;
                IsJal = 0;
                end
        default:
                begin
                BranchResultJType = 0;
                IsJal = 0;
                end
        endcase
    end

  assign BranchResult = BranchResultJType | BranchResultBType;
  assign PC_Full = {23'b0, Cur_PC};
always_comb
    begin
        if(JalRType)       
        PC_Imm = SrcA + SrcB;        
        else
	PC_Imm = PC_Full + Imm_out;     
    end

  assign PC_Four = PC_Full + 32'b100;
  assign Branch_Sel = Branch && BranchResult;  // 0:Branch is taken; 1:Branch is not taken
  assign halt_flag = halt; 
  assign BrPC = (Branch_Sel) ? PC_Imm : ((halt_flag) ? PC_Full : 32'b0);  // Branch -> PC+Imm   // Otherwise, BrPC value is not important
  assign PcSel = Branch_Sel || halt_flag;  // 1:branch is taken; 0:branch is not taken(choose pc+4)

endmodule
