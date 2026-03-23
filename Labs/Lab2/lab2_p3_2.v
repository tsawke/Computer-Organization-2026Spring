module lab2_p3_2 (
    input wire [7:0] x,
    output wire [31:0] y
);
    assign y = {{24{x[7]}}, x};
endmodule