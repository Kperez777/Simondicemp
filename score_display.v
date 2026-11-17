// score_display.v
// Drives all 8 seven-segment digits on the Nexys A7 (common anode,
// active-low segments), time-multiplexed:
//   - During normal play: shows the score (0-5) on the rightmost
//     digit (AN0), the rest blank -- same as before.
//   - When you WIN (completed all 5 rounds): spells out "GANASTE"
//     across the 7 leftmost-used digits (AN6..AN0), AN7 blank.
//   - When you LOSE (wrong button): spells out "PERDISTE" across all
//     8 digits (AN7..AN0).
//
// Letters that don't have a clean 7-segment shape (N, R, D, T) use
// their usual lowercase approximation seen on digital displays/clocks
// (n, r, d, t); they read fine as part of the full word.

module score_display (
    input  wire clk,
    input  wire rst,
    input  wire [3:0] score,
    input  wire game_over,
    input  wire win,
    output reg  [6:0] seg,   // segments a-g (active low)
    output reg  [7:0] an     // anode enables (active low)
);

    // ---- Digit multiplexing ----
    // Cycles through all 8 digits continuously. Each digit stays
    // selected for 2^17 clk cycles (~1.3ms @ 100MHz), so the full
    // 8-digit scan repeats at ~95Hz -- fast enough to look solid and
    // flicker-free to the human eye.
    reg [16:0] refresh_cnt = 0;
    reg [2:0]  digit_sel   = 0; // 0 = AN0 (rightmost) ... 7 = AN7 (leftmost)

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            refresh_cnt <= 0;
            digit_sel   <= 0;
        end else begin
            refresh_cnt <= refresh_cnt + 1'b1;
            if (refresh_cnt == 17'd0)
                digit_sel <= digit_sel + 1'b1; // wraps 0..7 automatically
        end
    end

    // ---- Segment patterns (active low, common anode) ----
    function [6:0] digit_seg; // numeric digits 0-9, for normal play
        input [3:0] v;
        begin
            case (v)
                4'd0: digit_seg = 7'b1000000;
                4'd1: digit_seg = 7'b1111001;
                4'd2: digit_seg = 7'b0100100;
                4'd3: digit_seg = 7'b0110000;
                4'd4: digit_seg = 7'b0011001;
                4'd5: digit_seg = 7'b0010010;
                4'd6: digit_seg = 7'b0000010;
                4'd7: digit_seg = 7'b1111000;
                4'd8: digit_seg = 7'b0000000;
                4'd9: digit_seg = 7'b0010000;
                default: digit_seg = 7'b1111111;
            endcase
        end
    endfunction

    localparam [6:0]
        BLANK = 7'b1111111,
        CH_G  = 7'b1000010,
        CH_A  = 7'b0001000,
        CH_N  = 7'b0101011, // lowercase n
        CH_S  = 7'b0010010,
        CH_T  = 7'b0000111, // lowercase t
        CH_E  = 7'b0000110,
        CH_P  = 7'b0001100,
        CH_R  = 7'b0101111, // lowercase r
        CH_D  = 7'b0100001, // lowercase d
        CH_I  = 7'b1001111;

    // "GANASTE" (7 letters) shown on AN6..AN0, AN7 left blank
    function [6:0] gana_seg;
        input [2:0] pos;
        begin
            case (pos)
                3'd6: gana_seg = CH_G;
                3'd5: gana_seg = CH_A;
                3'd4: gana_seg = CH_N;
                3'd3: gana_seg = CH_A;
                3'd2: gana_seg = CH_S;
                3'd1: gana_seg = CH_T;
                3'd0: gana_seg = CH_E;
                default: gana_seg = BLANK;
            endcase
        end
    endfunction

    // "PERDISTE" (8 letters) shown on AN7..AN0, fills the whole display
    function [6:0] perdiste_seg;
        input [2:0] pos;
        begin
            case (pos)
                3'd7: perdiste_seg = CH_P;
                3'd6: perdiste_seg = CH_E;
                3'd5: perdiste_seg = CH_R;
                3'd4: perdiste_seg = CH_D;
                3'd3: perdiste_seg = CH_I;
                3'd2: perdiste_seg = CH_S;
                3'd1: perdiste_seg = CH_T;
                3'd0: perdiste_seg = CH_E;
                default: perdiste_seg = BLANK;
            endcase
        end
    endfunction

    always @(*) begin
        an = 8'b1111_1111;
        an[digit_sel] = 1'b0; // enable only the currently selected digit

        if (game_over && win) begin
            seg = gana_seg(digit_sel);
        end else if (game_over && !win) begin
            seg = perdiste_seg(digit_sel);
        end else begin
            // Normal play: score digit on the rightmost position only
            seg = (digit_sel == 3'd0) ? digit_seg(score) : BLANK;
        end
    end

endmodule
