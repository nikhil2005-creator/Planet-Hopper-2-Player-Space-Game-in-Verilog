`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//winner_ID = 1 --> Player 1 won
//winner_ID = 2 --> Player 2 won
//winner_ID = 3 --> Tie    
//////////////////////////////////////////////////////////////////////////////////

module tb_game;
  reg clk, rst;
  reg [2:0] pos1, pos2;
  wire [1:0] winner_ID;

  // DUT
  game uut(
    .clk(clk),
    .rst(rst),
    .pos1(pos1),
    .pos2(pos2),
    .winner_ID(winner_ID)
  );

  // Clock generation
  always #5 clk = ~clk;

  integer test_case = 0;
  real score = 0;

  // Task for checking winner
  task check_winner(input [2:0] p1, input [2:0] p2, input [1:0] expected);
    begin
      test_case = test_case + 1;

      pos1 = p1;
      pos2 = p2;
      rst = 1;
      #10 rst = 0;
      #210; // wait for game to finish

      if (winner_ID == expected) begin
        $display("!! %0d 2.5", test_case);
        $display("PASS | Pos1=%0d Pos2=%0d | Winner=%0d", p1, p2, winner_ID);
        score = score + 2.5;
      end else begin
        $display("!! %0d 0.00", test_case);
        $display("FAIL | Pos1=%0d Pos2=%0d | Expected=%0d Got=%0d", p1, p2, expected, winner_ID);
      end

      #20;
    end
  endtask

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_game);
    clk = 0;
    rst = 0;

    // -------- TEST CASE 1 --------
    check_winner(3'd0, 3'd2, 2'd2);
    // -------- TEST CASE 2 --------
    check_winner(3'd3, 3'd1, 2'd1);
    // -------- TEST CASE 3 --------
    check_winner(3'd1, 3'd2, 2'd2);
    // -------- TEST CASE 4 --------
    check_winner(3'd1, 3'd0, 2'd1);


    $display("-------------------------------------------------");
    $display("Final Score: %0.2f / 10.00", score);
    $display("-------------------------------------------------");
    $finish;
  end

  // Optional monitoring
  initial begin
    // FIX: Changed uut.state1/2 to uut.pos1_reg/pos2_reg which actually exist
    $monitor("Time=%0t | P1_pos=%d | P2_pos=%d | Winner=%d",
              $time, uut.pos1_reg, uut.pos2_reg, winner_ID);
  end

endmodule