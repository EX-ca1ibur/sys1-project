module top(
    input SW0,
    input SW1,
    input SW2,
    output LD0
);

    main ldut(
        .I0(SW0),
        .I1(SW1),
        .I2(SW2),
        .O(LD0)
    );

endmodule