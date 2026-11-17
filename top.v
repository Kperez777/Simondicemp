// top.v
// Top-level module for "Simon Dice Digital" on the Nexys A7-100T.
//
// Board connections (see nexys4.xdc), confirmed against the physical
// board silkscreen:
//   CLK100MHZ          -> clk            (pin E3)
//   CPU_RESET           -> rst_raw        (pin C12)
//   BTNU, BTNR, BTND, BTNL -> btn_u/r/d/l (pins M18, M17, P18, P17)
//   LED[3:0]  -> the 4 sequence LEDs (also live button-press feedback)
//   SEG/AN    -> 7-segment digits: score (0-5) during play; spells out
//                "GANASTE" (win) or "PERDISTE" (lose) once the game ends
//   LED[14]   -> lights up ONLY if you win (complete all 5 rounds)
//   LED[15]   -> lights up when the game ends (win OR lose)
//
// Game structure: 5 independent rounds, each with its own fixed 4-step
// sequence (see simon_fsm.v). Completing all 5 rounds is a win.

module top (
    input  wire clk,
    input  wire rst_raw,       // CPU_RESET button, active LOW (confirmed: idle=1, pressed=0)
    input  wire btn_u,
    input  wire btn_r,
    input  wire btn_d,
    input  wire btn_l,
    output wire [15:0] led,
    output wire [6:0]  seg,
    output wire [7:0]  an
);

    // CPU_RESET on the Nexys A7 is active LOW (confirmed against the
    // course's own reference .xdc: "CPU_RESETN, activo en bajo") -- it
    // reads 1 when idle/not pressed and 0 while held down. Our internal
    // 'rst' must be active HIGH (asserted = 1), so we invert it here.
    wire rst = ~rst_raw;

    // ---- Clocking ----
    wire tick_1hz, tick_1khz;
    clock_divider clkdiv (
        .clk       (clk),
        .rst       (rst),
        .tick_1hz  (tick_1hz),
        .tick_1khz (tick_1khz)
    );

    // ---- Button debouncing ----
    wire [3:0] btn_raw = {btn_l, btn_d, btn_r, btn_u}; // btn[3:0]
    wire [3:0] btn_clean;
    wire [3:0] btn_pulse;

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : DEBOUNCE_GEN
            debounce db_i (
                .clk       (clk),
                .rst       (rst),
                .en_tick   (tick_1khz),
                .btn_in    (btn_raw[i]),
                .btn_clean (btn_clean[i]),
                .btn_pulse (btn_pulse[i])
            );
        end
    endgenerate

    // ---- Main game FSM (5 rounds x 4 fixed steps each, no LFSR) ----
    wire [3:0] seq_led;
    wire [3:0] score;
    wire game_over;
    wire win;
    wire [2:0] dbg_state;     // unused in normal play; kept for future debugging
    wire       dbg_any_press; // unused in normal play; kept for future debugging

    simon_fsm #(.NUM_ROUNDS(5), .STEPS_PER_ROUND(4)) fsm_inst (
        .clk           (clk),
        .rst           (rst),
        .tick_1hz      (tick_1hz),
        .btn           (btn_clean),
        .btn_pulse     (btn_pulse),
        .led           (seq_led),
        .score         (score),
        .game_over     (game_over),
        .win           (win),
        .dbg_state     (dbg_state),
        .dbg_any_press (dbg_any_press)
    );

    // ---- 7-segment display ----
    // Shows the score (0-5) during normal play, and spells out
    // "GANASTE" (win) or "PERDISTE" (lose) across the 8 digits once
    // the game ends.
    score_display disp_inst (
        .clk       (clk),
        .rst       (rst),
        .score     (score),
        .game_over (game_over),
        .win       (win),
        .seg       (seg),
        .an        (an)
    );

    // ---- LED mapping ----
    // LED0-3:  game sequence LEDs during playback, AND live feedback of
    //          whichever button you're currently pressing while playing
    // LED4-13: unused (off)
    // LED14:   WIN indicator - lights up ONLY if you complete all 5 rounds
    // LED15:   GAME OVER indicator - lights up when the game ends, win
    //          or lose (so: LED15 alone = you lost; LED15 + LED14 = you won)
    assign led[3:0]  = seq_led;
    assign led[13:4] = 10'b0;
    assign led[14]   = win;
    assign led[15]   = game_over;

endmodule
