//=============================================================
// Module      : full_adder
// Description : Single-bit full adder (basic building block)
//=============================================================
`timescale 1ns/1ps

module full_adder (
    input  logic a,
    input  logic b,
    input  logic cin,
    output logic sum,
    output logic cout
);
    // Low power note: XOR-based sum path minimizes gate count;
    // cout uses majority function to reduce glitch propagation
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);

endmodule


//=============================================================
// Module      : rca_32bit
// Description : 32-bit Ripple Carry Adder built from 32 full adders
//               Low power design considerations:
//                 - No redundant logic / minimal cell count per stage
//                 - Uniform bit-slice structure eases physical design
//                   (regular layout -> shorter routing -> lower cap)
//                 - Carry chain kept as short combinational path per
//                   bit to limit glitch/switching propagation depth
//=============================================================

module rca_32bit (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic        cin,
    output logic [31:0] sum,
    output logic         cout
);

    logic [32:0] carry; // internal carry chain, carry[0] = cin

    assign carry[0] = cin;
    assign cout      = carry[32];

    genvar i;
    generate
        for (i = 0; i < 32; i++) begin : FA_STAGE
            full_adder u_fa (
                .a    (a[i]),
                .b    (b[i]),
                .cin  (carry[i]),
                .sum  (sum[i]),
                .cout (carry[i+1])
            );
        end
    endgenerate

endmodule
