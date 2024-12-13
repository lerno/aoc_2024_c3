/*
 * Advent of Code 2024 day 13
 * Sample solution demonstrating C3 language and standard library.
 */
import std::io, std::time, std::math;

fn void main()
{
	io::printn("Advent of code, day 13.");
	@pool()
	{
		// Simple benchmarking with Clock, "mark" returns the last duraction and resets the clock
		Clock c = clock::now();
		io::printfn("* Task 1: %d - completed in %s", solve(true), c.mark());
		io::printfn("* Task 2: %d - completed in %s", solve(false), c.mark());
	};
}

fn long[<2>] split_xy(String s, String start, String split)
{
	String[] parts = s[start.len..].tsplit(split);
	assert(parts.len == 2);
	return { parts[0].to_long()!!, parts[1].to_long()!! };
}

fn long count_tokens(long[<2>] a, long[<2>] b, long[<2>] prize)
{
	// We seek an integer solution to a * k1 + b * k2 = prize

	// | a.x b.x | |k1| = | prize.x prize.y |
	// | a.y b.y | |k2|
	long det = a.x * b.y - b.x * a.y;
	// The case when a = k * b
	if (!det)
	{
		// We only needed to handle this if there was an actual solution.
		// This doesn't happen.
		assert((prize % b).max() > 0 || prize.x / b.x != prize.y / b.y);
		return 0;
	}
	// User Cramer's rule:
	long k1 = prize.x * b.y - b.x * prize.y;
	if (k1 % det != 0) return 0;
	long k2 = a.x * prize.y - prize.x * a.y;
	if (k2 % det != 0) return 0;
	return (k1 * 3 + k2) / det;
}

fn long solve(bool part1)
{
	File f = file::open("day13.txt", "rb")!!;
	defer (void)f.close();
	long tokens;
	while (try line = io::treadline(&f))
   	{
   	    long[<2>] a = split_xy(line, "Button A: X+", ", Y+");
   	    long[<2>] b = split_xy(io::treadline(&f)!!, "Button B: X+", ", Y+");
   	    long[<2>] prize = split_xy(io::treadline(&f)!!, "Prize: X=", ", Y=");
   	    (void)io::treadline(&f);
   	    switch
   	    {
   	        case part1: tokens += count_tokens(a, b, prize);
   	        default: tokens += count_tokens(a, b, prize + (long[<2>])10000000000000);
   	    }
	}
	return tokens;
}
