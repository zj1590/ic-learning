`timescale 1ns/1ps

module tb_and_gate;
    reg  a, b;
    wire y;

    and_gate u_and_gate(
        .a(a),
        .b(b),
        .y(y)
    );

    initial begin
        $dumpfile("and_gate.vcd");
        $dumpvars(0, tb_and_gate);

        $monitor("time=%0t a=%b b=%b y=%b", $time, a, b, y);

        a = 0; b = 0; #10;
        a = 0; b = 1; #10;
        a = 1; b = 0; #10;
        a = 1; b = 1; #10;

        $finish;
    end
endmodule