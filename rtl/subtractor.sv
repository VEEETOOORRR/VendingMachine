module subtractor (
    input logic credit,
    input logic price,

    output logic result
);

    assign result = credit - price;

endmodule