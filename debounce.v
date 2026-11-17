// debounce.v
// Simple debouncer + rising-edge detector for a single push-button.
// en_tick is a slow enable pulse (e.g. 1 kHz) coming from clock_divider.

module debounce (
    input  wire clk,
    input  wire rst,
    input  wire en_tick,
    input  wire btn_in,
    output reg  btn_clean,   // debounced level
    output reg  btn_pulse    // one-cycle pulse on press (rising edge)
);

    reg [3:0] shift_reg = 4'b0000;
    reg btn_clean_d = 1'b0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg   <= 4'b0000;
            btn_clean   <= 1'b0;
            btn_clean_d <= 1'b0;
            btn_pulse   <= 1'b0;
        end else begin
            btn_pulse <= 1'b0;
            if (en_tick) begin
                shift_reg <= {shift_reg[2:0], btn_in};
                if (shift_reg == 4'b1111) begin
                    btn_clean <= 1'b1;
                end else if (shift_reg == 4'b0000) begin
                    btn_clean <= 1'b0;
                end

                btn_clean_d <= btn_clean;
                if (btn_clean && !btn_clean_d) begin
                    btn_pulse <= 1'b1; // rising edge detected
                end
            end
        end
    end

endmodule
