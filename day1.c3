/*
 * Advent of Code 2024 day 1
 * Sample solution demonstrating C3 language and standard library.
 */
import std::io, std::time, std::math, std::collections;


fn long! calculate()
{
	File f = file::open("day1.txt", "rb")!;
	defer (void)f.close();
	long total = 0;
	PriorityQueue(<long>) a, b;
	a.temp_init();
	b.temp_init();
	while (try line = io::treadline(&f))
	{
		String[] split = line.tsplit(" ");
		assert(split.len > 2);
		a.push(split[0].to_long()!);
		b.push(split[^1].to_long()!);
	}
	while (a.len())
	{
		long diff = math::abs(a.pop() - b.pop())!;
		total += diff;
	}
	return total;
}

fn long! similarity()
{
	File f = file::open("day1.txt", "rb")!;
	defer (void)f.close();
	long total = 0;
	// We read by line and store it in a temporary string.
	List(<long>) a;
	HashMap(<long, int>) b;
	a.temp_init();
	b.temp_init();
	while (try line = io::treadline(&f))
	{
		String[] split = line.tsplit(" ");
		assert(split.len > 2);
		a.push(split[0].to_long()!);
		long val = split[^1].to_long()!;
		int old = b[val] ?? 0;
		b[val] = old + 1;
	}
	while (try av = a.pop())
	{
		total += av * (b[av] ?? 0);
	}
	return total;
}

fn void main()
{
	io::printn("Advent of code, day 1.");
	@pool()
	{
		// Simple benchmarking with Clock, "mark" returns the last duraction and resets the clock
		Clock c = clock::now();
		io::printfn("* Task 1: %d - completed in %s", calculate()!!, c.mark());
		io::printfn("* Task 2: %d - completed in %s", similarity()!!, c.mark());
	};
}