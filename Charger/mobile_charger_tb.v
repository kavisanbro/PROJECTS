module charger_ic_tb;

reg battery_full;
reg overheating;

wire charging_enable;

charger_ic uut (
    .battery_full(battery_full),
    .overheating(overheating),
    .charging_enable(charging_enable)
);

initial begin

    battery_full = 0;
    overheating = 0;
    #10;

    battery_full = 1;
    overheating = 0;
    #10;

    battery_full = 0;
    overheating = 1;
    #10;

    battery_full = 1;
    overheating = 1;
    #10;

end

endmodule