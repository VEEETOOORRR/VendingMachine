module subtractor (
    input logic credit,
    input logic price,

    output logic change
);

    // Módulo puramente combinacional
    assign change = credit - price;

endmodule