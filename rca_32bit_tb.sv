//=============================================================
// Module      : rca_32bit_tb
// Description : Self-checking testbench for rca_32bit
//=============================================================
`timescale 1ns/1ps

module rca_32bit_tb;

    logic [31:0] a, b;
    logic        cin;
    logic [31:0] sum;
    logic        cout;

    int errors = 0;

    // DUT instantiation
    rca_32bit dut (
        .a    (a),
        .b    (b),
        .cin  (cin),
        .sum  (sum),
        .cout (cout)
    );

    // Task to apply inputs and check result against expected 33-bit sum
    task automatic run_test(
        input [31:0] ta,
        input [31:0] tb,
        input        tcin
    );
        logic [32:0] expected;
        a = ta; b = tb; cin = tcin;
        #10; // allow combinational settle

        expected = {1'b0, ta} + {1'b0, tb} + tcin;

        if (sum !== expected[31:0] || cout !== expected[32]) begin
            errors++;
            $display("FAIL: a=%0d b=%0d cin=%0b | sum=%0d(exp %0d) cout=%0b(exp %0b)",
                       ta, tb, tcin, sum, expected[31:0], cout, expected[32]);
        end else begin
            $display("PASS: a=%0d b=%0d cin=%0b | sum=%0d cout=%0b",
                       ta, tb, tcin, sum, cout);
        end
    endtask

    initial begin
        $display("---------------------------------------------------");
        $display(" 32-bit Ripple Carry Adder Testbench");
        $display("---------------------------------------------------");

        // Basic cases
        run_test(32'd0,          32'd0,          1'b0); // zero + zero
        run_test(32'd1,          32'd1,          1'b0); // simple add
        run_test(32'd100,        32'd250,        1'b0); // small numbers
        run_test(32'hFFFFFFFF,   32'd1,           1'b0); // overflow -> cout=1, sum=0
        run_test(32'hFFFFFFFF,   32'hFFFFFFFF,    1'b1); // max + max + cin
        run_test(32'h80000000,   32'h80000000,    1'b0); // MSB carry test
        run_test(32'hAAAAAAAA,   32'h55555555,    1'b0); // alternating bits -> all 1s
        run_test(32'h12345678,   32'h9ABCDEF0,    1'b0); // random pattern
        run_test(32'd0,          32'd0,           1'b1); // cin only
        run_test(32'hFFFFFFFF,   32'd0,           1'b0); // max + zero

        $display("---------------------------------------------------");
        if (errors == 0)
            $display(" ALL TESTS PASSED");
        else
            $display(" TOTAL FAILURES: %0d", errors);
        $display("---------------------------------------------------");

        $finish;
    end

endmodule
