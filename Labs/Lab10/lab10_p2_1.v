`include "/data/workspace/myshixun/imem.v" 
module IFetch(
    input clk, rst, branch, zero,
    input [31:0] imm,
    output [31:0] inst
);

    reg [31:0] pc;

    imem #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(14),
        .INIT_FILE("ifetch_test.txt")
    ) uimem (
        .clka(clk),
        .addra(pc[15:2]),
        .douta(inst)
    );
    
    always @(negedge clk or posedge rst) begin
        if(rst)
            pc <= 32'h0;
        else if(branch && zero)
            pc <= pc + (imm << 1);
        else
            pc <= pc + 4;
    end

endmodule