# 100 Hops

This is a solution to the 100 Hops puzzle, [posted to Stack Overflow here](https://puzzling.stackexchange.com/questions/20238/explore-the-square-with-100-hops).  The game is simple:  Start with an empty 10x10 grid.  From any starting cell, you may jump in one of 8 directions - three steps horizontal or vertical, or 2 steps diagonal.  The objective is to completely cover the grid, without landing on any cell twice.

I first became aware of this puzzle due to a blog post on [solving it using brute-force recursion here](https://www.nurkiewicz.com/2018/09/brute-forcing-seemingly-simple-number.html).  This solution, in Java, certainly "works" but spends a lot of time digging.  I hoped to do better, by solving it more efficently, and scalable to a greater grid size.

## Heuristic
I remembered from a high school programming course on recursion, trying to solve the Knight's Tour problem.  This is a similar setup, except all hops must follow the moves of a knight as it travels to each square on a chessboard.  The heuristic that helps to solve this is to hit the hardest-to-reach squares first, before tackling the easier ones.  This helps to keep us from getting "boxed in".  The flow is:

* on each square, keep a count of how many "entrances" can reach it
* each time you visit a square, decrement the entrances for all reachable squares by one
* sort each potential move by the minimum number of reachable squares at the destination
* depth-first traverse each until you fill the board or hit a dead end (no valid squares to move to)

As it turns out, a similar approach works very well for 100 Hops.  It's not even necessary to recurse, really: the heuristic is so good, it finds a solution first-try and could be completely iterative.  Recursion may still be helpful when trying to brute-force a "perfect tour", that is, the final square is one hop away from the first.

## Implementation
I create the board as a 2-dimensional array.  Each cell is initialized with a negative number, with magnitude = number of hops still land on the board.  The 10x10 array looks like this:

    000 |  -3  -3  -4  -5  -5  -5  -5  -4  -3  -3
    001 |  -3  -3  -4  -5  -5  -5  -5  -4  -3  -3
    002 |  -4  -4  -6  -7  -7  -7  -7  -6  -4  -4
    003 |  -5  -5  -7  -8  -8  -8  -8  -7  -5  -5
    004 |  -5  -5  -7  -8  -8  -8  -8  -7  -5  -5
    005 |  -5  -5  -7  -8  -8  -8  -8  -7  -5  -5
    006 |  -5  -5  -7  -8  -8  -8  -8  -7  -5  -5
    007 |  -4  -4  -6  -7  -7  -7  -7  -6  -4  -4
    008 |  -3  -3  -4  -5  -5  -5  -5  -4  -3  -3
    009 |  -3  -3  -4  -5  -5  -5  -5  -4  -3  -3
        +----------------------------------------
            0   1   2   3   4   5   6   7   8   9

From here, pick a starting point, and call the recursive move function.  Each time you visit a cell, overwrite it with move_number, and update the other reachable cells (value < 0) by incremeting their value by 1.  From those reachable cells, then pick the move with the smallest number, and hop into it.  For example, after move 3, the board looks as follows:

    000 |   1  -3  -4   2  -5  -5  -4  -4  -3  -3
    001 |  -3  -3  -4  -5  -5  -5  -5  -4  -3  -3
    002 |  -4   3  -5  -7  -6  -6  -7  -6  -4  -4
    003 |  -4  -5  -7  -7  -8  -8  -8  -7  -5  -5
    004 |  -5  -5  -7  -7  -8  -8  -8  -7  -5  -5
    005 |  -5  -4  -7  -8  -8  -8  -8  -7  -5  -5
    006 |  -5  -5  -7  -8  -8  -8  -8  -7  -5  -5
    007 |  -4  -4  -6  -7  -7  -7  -7  -6  -4  -4
    008 |  -3  -3  -4  -5  -5  -5  -5  -4  -3  -3
    009 |  -3  -3  -4  -5  -5  -5  -5  -4  -3  -3
        +----------------------------------------
            0   1   2   3   4   5   6   7   8   9

The game completes when move_num is placed in a cell.  The 10x10 example looks like this:

    000 |   1  69  66   2  70  65  23  54  64  22
    001 |  43  18  15  44  19  14  45  20  13  46
    002 |  67   3  41  68  95  57  71  98  24  53
    003 |  16  83  76  17  84  77  26  55  63  21
    004 |  42  35  94  79  72  99  90  58  12  47
    005 |  75   4  40  86  96  56  85  97  25  52
    006 |  31  82  73  34  89  78  27  50  62   8
    007 |  39  36  93  80  37 100  91  59  11  48
    008 |  74   5  30  87   6  29  88   7  28  51
    009 |  32  81  38  33  92  60  10  49  61   9
        +----------------------------------------
            0   1   2   3   4   5   6   7   8   9

The 10x10 board is solved almost instantly on a Pentium 4, 1.3ghz machine, 512MB.  For fun I threw 50x50 at it: the machine resolved it in 2.08 real-time seconds.  100x100 was too much RAM and went into swap.  An iterative solution, or one that uses tail-call when a move is "forced", would help immensely.
