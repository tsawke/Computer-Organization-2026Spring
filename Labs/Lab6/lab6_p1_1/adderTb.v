module adderTb();
    
    reg [2:0] in1, in2;
    wire overflow;
    wire [2:0] sum;

    adder ua(in1, in2, sum, overflow);

    initial begin
        $display("start");
        $monitor("%t %b %b %b  %b", $time, in1, in2, sum, overflow);

        {in1, in2} = 6'b000000;
        repeat(63) begin
            #10 {in1, in2} = {in1, in2} + 1;
        end

        #10 $finish;
    end
endmodule