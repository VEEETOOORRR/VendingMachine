package vending_pkg;

    typedef enum logic [2:0] {
        IDLE      = 3'b000,
        COLLECT   = 3'b001,
        CHECK     = 3'b010,
        DISPENSE  = 3'b011,
        CHANGE    = 3'b100,
        ERROR     = 3'b101
    } state_t;

    typedef enum logic [1:0] {
        CAFE  = 2'b00,
        AGUA  = 2'b01,
        SUCO  = 2'b10,
        SNACK = 2'b11
    } item_t;

endpackage
