// clock_divider.v
// Divide the 100 MHz board clock down to slower, usable pulses.
// tick_1hz    -> used for game timing (sequence display speed, etc.)
// tick_1khz   -> ~1 kHz tick used to drive the button debouncers

module clock_divider #(
    parameter CLK_FREQ = 100_000_000
)(
    input  wire clk,
    input  wire rst,
    output reg  tick_1hz,
    output reg  tick_1khz
);

    // ---- 1 Hz tick ----
    reg [26:0] cnt_1hz = 0;
    localparam integer MAX_1HZ = CLK_FREQ - 1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_1hz  <= 0;
            tick_1hz <= 1'b0;
        end else if (cnt_1hz == MAX_1HZ) begin
            cnt_1hz  <= 0;
            tick_1hz <= 1'b1;
        end else begin
            cnt_1hz  <= cnt_1hz + 1'b1;
            tick_1hz <= 1'b0;
        end
    end

    // ---- 1 kHz tick (for debounce) ----
    reg [16:0] cnt_1khz = 0;
    localparam integer MAX_1KHZ = (CLK_FREQ / 1000) - 1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_1khz  <= 0;
            tick_1khz <= 1'b0;
        end else if (cnt_1khz == MAX_1KHZ) begin
            cnt_1khz  <= 0;
            tick_1khz <= 1'b1;
        end else begin
            cnt_1khz  <= cnt_1khz + 1'b1;
            tick_1khz <= 1'b0;
        end
    end

endmodule
