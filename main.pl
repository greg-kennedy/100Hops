#!/usr/bin/env perl
use strict;
use warnings;
# turn off the "deep recursion" warning
no warnings 'recursion';

# define the board size
use constant BOARD_SIZE => 10;
# enable debug printout
use constant DEBUG => 0;

# DEBUG: pretty-print a board
sub pp
{
  my $board_ref = shift;
  for (my $y = 0; $y < BOARD_SIZE; $y ++)
  {
    printf("%03d | " . ("%3d " x (BOARD_SIZE)) . "\n", $y, @{$board_ref->[$y]});
  }
  printf("    +" . ("----" x BOARD_SIZE) . "\n");
  printf("      " . ("%3d " x BOARD_SIZE) . "\n", (0 .. (BOARD_SIZE - 1)));
}

# Create an empty board
sub create_board
{
  my @board;

  # Pre-fill board with the number of valid moves.
  for (my $y = 0; $y < BOARD_SIZE; $y ++) {
    for (my $x = 0; $x < BOARD_SIZE; $x ++) {
      $board[$y][$x] = - (
        ($y > 2) +
        ($y < (BOARD_SIZE - 3)) +
        ($x > 2) +
        ($x < (BOARD_SIZE - 3)) +
        ($y > 1 && $x > 1) +
        ($y > 1 && $x < (BOARD_SIZE - 2)) +
        ($y < (BOARD_SIZE - 2) && $x > 1) +
        ($y < (BOARD_SIZE - 2) && $x < (BOARD_SIZE - 2))
      );
    }
  }

  if (DEBUG) {
    printf("Created initial board:\n");
    pp(\@board);
  }

  return \@board;
}

# Recursive make-a-move function
sub move_rec
{
  my $prev_board = shift;
  my $y = shift;
  my $x = shift;
  my $move_num = shift;

  # copy the input board
  my @board = map { [ @{$_} ] } @$prev_board;

  # make move
  $board[$y][$x] = $move_num;

  # Did we reach the end?
  if ($move_num == (BOARD_SIZE * BOARD_SIZE)) { return \@board }

  # Not done.  Update each square touched by this move.
  #  move generation is much copy-paste but hopefully it's not too bad.
  my @move_list;
  if ($y > 2 && $board[$y - 3][$x] < 0) { push @move_list, [(++ $board[$y - 3][$x]), [$y - 3, $x] ] }
  if ($y < (BOARD_SIZE - 3) && $board[$y + 3][$x] < 0) { push @move_list, [(++ $board[$y + 3][$x]), [$y + 3, $x] ] }
  if ($x > 2 && $board[$y][$x - 3] < 0) { push @move_list, [(++ $board[$y][$x - 3]), [$y, $x - 3] ] }
  if ($x < (BOARD_SIZE - 3) && $board[$y][$x + 3] < 0) { push @move_list, [(++ $board[$y][$x + 3]), [$y, $x + 3] ] }
  if ($y > 1 && $x > 1 && $board[$y - 2][$x - 2] < 0) { push @move_list, [(++ $board[$y - 2][$x - 2]), [$y - 2, $x - 2] ] }
  if ($y > 1 && $x < (BOARD_SIZE - 2) && $board[$y - 2][$x + 2] < 0) { push @move_list, [(++ $board[$y - 2][$x + 2]), [$y - 2, $x + 2] ] }
  if ($y < (BOARD_SIZE - 2) && $x > 1 && $board[$y + 2][$x - 2] < 0) { push @move_list, [(++ $board[$y + 2][$x - 2]), [$y + 2, $x - 2] ] }
  if ($y < (BOARD_SIZE - 2) && $x < (BOARD_SIZE - 2) && $board[$y + 2][$x + 2] < 0) { push @move_list, [(++ $board[$y + 2][$x + 2]), [$y + 2, $x + 2] ] }

  if (DEBUG) {
    printf("After move %d (%d, %d):\n", $move_num, $y, $x);
    pp(\@board);
  }

  # If we generated no moves at this step, that's bad: it means we haven't reached move_num, but also can't go anywhere
  return unless @move_list;

  # Sort them in order from least reachable to most
  my @sorted_move_list = sort { ($b->[0] <=> $a->[0]) || ($a->[1][0] <=> $b->[1][0]) || ($a->[1][1] <=> $b->[1][1]) } @move_list;

  if (DEBUG) {
    printf("Computed %d potential moves:\n", scalar @move_list);
    foreach my $move (@sorted_move_list) {
      printf("  val %d: %d, %d\n", $move->[0], $move->[1][0], $move->[1][1]);
    }
  }

  # try each move in order.  If a non-undef value comes back, it means we completed the grid, and should return to the parent.
  foreach my $move (@sorted_move_list)
  {
    my $val = move_rec(\@board, $move->[1][0], $move->[1][1], $move_num + 1);
    return $val if defined $val;
  }

  # none of those moves turned out good
  if (DEBUG) {
    printf("FAILED, backtracking from %d\n",$move_num);
  }
  return;
}

# Build board, recurse, and print the winner
pp(move_rec(create_board, 0, 0, 1));
