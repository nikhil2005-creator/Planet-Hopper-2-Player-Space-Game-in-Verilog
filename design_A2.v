`timescale 1ns / 1ps

module game(
    input clk,
    input rst,
    input [2:0] pos1,
    input [2:0] pos2,
    output [1:0] winner_ID
);

    // Planet constants
    localparam [2:0] PLAN1 = 0, PLAN2 = 1, PLAN3 = 2, PLAN4 = 3, PLAN5 = 4;
    localparam [2:0] IDLE  = 5;
    localparam [2:0] TRAVEL = 6;//one cycle delay adding

    // Revolutions constants
    localparam [2:0] PLAN1_REV = 1, PLAN2_REV = 0, PLAN3_REV = 4, PLAN4_REV = 3, PLAN5_REV = 2;
    // Toxicity/Reward constants
    localparam [7:0] PLAN1_T = 1, PLAN2_T = 3, PLAN3_T = 2, PLAN4_T = 2, PLAN5_T = 4;

    reg [7:0] p1rwd, p2rwd;
    reg [4:0] cycle;
    reg [2:0] pos1_reg, pos2_reg;
    reg [2:0] rev1, rev2;
    reg [2:0] dest1, dest2;

    reg [7:0] p1rwd_next, p2rwd_next;
    reg [4:0] cycle_next;
    reg [2:0] pos1_next, pos2_next;
    reg [2:0] rev1_next, rev2_next;
    reg [2:0] dest1_next, dest2_next;

    assign winner_ID = (cycle < 20) ? 3 :(p1rwd > p2rwd) ? 1 :(p1rwd < p2rwd) ? 2 :3;

    always@(posedge clk, posedge rst) begin
        if(rst) begin
            p1rwd <= 50;
            p2rwd <= 50;
            pos1_reg <= IDLE;
            pos2_reg <= IDLE;
            cycle <= 0;
            rev1 <= 0;
            rev2 <= 0;
            dest1 <= 0;
            dest2 <= 0;
        end
        else begin
            p1rwd <= p1rwd_next;
            p2rwd <= p2rwd_next;
            pos1_reg <= pos1_next;
            pos2_reg <= pos2_next;
            cycle <= cycle_next;
            rev1 <= rev1_next;
            rev2 <= rev2_next;
            dest1 <= dest1_next;
            dest2 <= dest2_next;
        end
    end

    always@(*) begin
        p1rwd_next = p1rwd;
        p2rwd_next = p2rwd;
        pos1_next = pos1_reg;
        pos2_next = pos2_reg;
        cycle_next = cycle;
        rev1_next = rev1;
        rev2_next = rev2;
        dest1_next = dest1;
        dest2_next = dest2;

        if(cycle < 20) begin
            //Player1
            case (pos1_reg)
                IDLE: pos1_next = pos1;
                TRAVEL: pos1_next = dest1;
                PLAN1: if (rev1 == PLAN1_REV) begin
                           if (p1rwd < PLAN1_T) p1rwd_next = 0;
                           else begin
                            p1rwd_next = p1rwd - PLAN1_T;
                            pos1_next = TRAVEL;
                            dest1_next = 1;
                            rev1_next = 0;end
                       end
                       else rev1_next = rev1 + 1;
                PLAN2: if (rev1 == PLAN2_REV) begin
                           if (p1rwd < PLAN2_T) p1rwd_next = 0;
                           else begin
                            p1rwd_next = p1rwd - PLAN2_T;
                            pos1_next = TRAVEL;
                            dest1_next = 3;
                            rev1_next = 0;end
                       end
                       else rev1_next = rev1 + 1;
                PLAN3: if (rev1 == PLAN3_REV) begin
                           if (p1rwd + PLAN3_T > 255) p1rwd_next = 255;
                           else begin
                            p1rwd_next = p1rwd + PLAN3_T;
                            pos1_next = TRAVEL;
                            dest1_next = 1;
                            rev1_next = 0;end
                       end
                       else rev1_next = rev1 + 1;
                PLAN4: if (rev1 == PLAN4_REV) begin
                           if (p1rwd + PLAN4_T > 255) p1rwd_next = 255;
                           else begin
                            p1rwd_next = p1rwd + PLAN4_T;
                            pos1_next = TRAVEL;
                            dest1_next = 2;
                            rev1_next = 0;end
                       end
                       else rev1_next = rev1 + 1;
                PLAN5: if (rev1 == PLAN5_REV) begin
                           if (p1rwd + PLAN5_T > 255) p1rwd_next = 255;
                           else begin
                            p1rwd_next = p1rwd + PLAN5_T;
                            pos1_next = TRAVEL;
                            dest1_next = 2;
                            rev1_next = 0;end
                       end else rev1_next = rev1 + 1;
            endcase

            //Player2
            case (pos2_reg)
                IDLE: pos2_next = pos2;
                TRAVEL: pos2_next = dest2;
                PLAN1: if (rev2 == PLAN1_REV) begin
                           if (p2rwd < PLAN1_T) p2rwd_next = 0;
                           else begin
                            p2rwd_next = p2rwd - PLAN1_T;
                            pos2_next = TRAVEL;
                            dest2_next = 1;
                            rev2_next = 0;end
                       end
                       else rev2_next = rev2 + 1;
                PLAN2: if (rev2 == PLAN2_REV) begin
                           if (p2rwd < PLAN2_T) p2rwd_next = 0;
                           else begin
                            p2rwd_next = p2rwd - PLAN2_T;
                            pos2_next = TRAVEL;
                            dest2_next = 3;
                            rev2_next = 0;end
                       end
                       else rev2_next = rev2 + 1;
                PLAN3: if (rev2 == PLAN3_REV) begin
                           if (p2rwd + PLAN3_T > 255) p2rwd_next = 255;
                           else begin
                            p2rwd_next = p2rwd + PLAN3_T;
                            pos2_next = TRAVEL;
                            dest2_next = 1;
                            rev2_next = 0;end
                       end
                       else rev2_next = rev2 + 1;
                PLAN4: if (rev2 == PLAN4_REV) begin
                           if (p2rwd + PLAN4_T > 255) p2rwd_next = 255;
                           else begin
                            p2rwd_next = p2rwd + PLAN4_T;
                            pos2_next = TRAVEL;
                            dest2_next = 2;
                            rev2_next = 0;end
                       end
                       else rev2_next = rev2 + 1;
                PLAN5: if (rev2 == PLAN5_REV) begin
                           if (p2rwd + PLAN5_T > 255) p2rwd_next = 255;
                           else begin
                            p2rwd_next = p2rwd + PLAN5_T;
                            pos2_next = TRAVEL;
                            dest2_next = 2;
                            rev2_next = 0;end
                       end
                       else rev2_next = rev2 + 1;
            endcase

            cycle_next = cycle + 1;
        end
    end

endmodule