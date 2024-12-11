/*
 * Advent of Code 2024 day 11
 */
import std::io, std::time, std::math, std::collections;

def LongList = List(<long>);
const CACHE_SIZE = 10000;
long[CACHE_SIZE][76] cache;

fn long blink(long val, int left)
{
	if (val < CACHE_SIZE)
	{
		if (long cached = cache[left][val]) return cached;
	}
	long total = 1;
	long start_val = val;
	int start_left = left;
	while OUTER: (left)
	{
		if (val == 0)
		{
			val = 1;
			left--;
			continue;
		}
		for (long mult = 10, long half = 10; mult < long.max / 100; half *= 10, mult *= 100)
		{
			if (val < mult)
			{
				val *= 2024;
				left--;
				continue OUTER;
			}
			if (val >= mult && val < mult * 10)
			{
				left--;
				total += blink(val / half, left);
				val %= half;
				continue OUTER;
			}
		}
		unreachable();
	}
	if (start_val < CACHE_SIZE)
	{
		cache[start_left][start_val] = total;
	}
	return total;
}

fn long solve(int blinks)
{
	long stones = 0;
	String line = (String)file::load_temp("day11.txt")!!;
	foreach (s : line.tsplit(" "))
	{
		stones += blink(s.to_long()!!, blinks);
	}
	return stones;
}

fn void main()
{
	io::printn("Advent of code, day 11.");
	@pool()
	{
		// Simple benchmarking with Clock, "mark" returns the last duration and resets the clock
		Clock c = clock::now();
		io::printfn("* Path part 1: %s - completed in %s", solve(25), c.mark());
		io::printfn("* Path part 1: %s - completed in %s", solve(75), c.mark());
	};
}