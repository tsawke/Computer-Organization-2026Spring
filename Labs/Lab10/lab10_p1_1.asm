module Controller(
    input [31:0] inst,
    output branch, aluSrc, memRead, memWrite, memToReg, 
    output reg regWrite,
    output reg [1:0] ALUOp
    );

    wire [6:0] opcode;
    assign opcode = inst[6:0];

    localparam OP_RTYPE  = 7'b0110011;
    localparam OP_LOAD   = 7'b0000011;
    localparam OP_STORE  = 7'b0100011;
    localparam OP_BRANCH = 7'b1100011;

    assign branch   = (opcode == OP_BRANCH);
    assign memRead  = (opcode == OP_LOAD);
    assign memWrite = (opcode == OP_STORE);
    assign memToReg = (opcode == OP_LOAD);

    assign aluSrc = (opcode == OP_LOAD) || (opcode == OP_STORE);

    always @(*) begin
        regWrite = 1'b0;
        ALUOp = 2'b00;

        case(opcode)
            OP_RTYPE: begin
                regWrite = 1'b1;
                ALUOp = 2'b10;
            end

            OP_LOAD: begin
                regWrite = 1'b1;
                ALUOp = 2'b00;
            end

            OP_STORE: begin
                regWrite = 1'b0;
                ALUOp = 2'b00;
            end

            OP_BRANCH: begin
                regWrite = 1'b0;
                ALUOp = 2'b01;
            end

            default: begin
                regWrite = 1'b0;
                ALUOp = 2'b00;
            end
        endcase
    end

endmodule