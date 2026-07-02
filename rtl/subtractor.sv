module subtractor (
    input logic [7:0] credit,
    input logic [7:0] price,

    output logic [7:0] change
);

    // Módulo puramente combinacional
    assign change = credit - price;

endmodule