/*
 * Advent of Code 2024 day 3
 * Sample solution demonstrating C3 language and standard library.
 */
import std::io, std::time;

fn int read_mul(String s, long* total)
{
	char* start = s.ptr;

	if (s.len < 8) return s.len;

	if (s[0..3] != "mul(") return 1;
	s = s[4..];

	usz idx = s.index_of(",") ?? 0;
	if (idx == 0) return 1;  // "mul(," or no ","

	long! val = s[0:idx].to_long();
	if (catch val) return 1;

	s = s[idx + 1..];
	if (s.len == 0) return 1;

	usz idx2 = s.index_of(")") ?? 0;
	if (idx2 == 0) return 1; // No ")" or "mul(1,)"

	long! val2 = s[0:idx2].to_long();

	if (catch val2) return 1;
	*total += val * val2;

	return (int)(s.ptr + idx2 - start) + 1;
}

fn int read_next(String s, long* total, bool* enable)
{
	if (s.len < 4) return s.len;
	if (s[0..2] == "mul")
	{
		if (!*enable) return read_mul(s, &&0l);
		return read_mul(s, total);
	}
	if (s[0..3] == "do()")
	{
		*enable = true;
		return 4;
	}
	if (s.len > 6 && s[0..6] == "don't()")
	{
		*enable = false;
		return 7;
	}
	return 1;
}

fn long! solve1()
{
	String data = (String)file::load_temp("day3.txt")!;
	usz len = data.len;
	long total = 0;
	for (usz i = 0; i < len;)
	{
		i += read_mul(data[i..], &total);
	}
	return total;
}

fn long! solve2()
{
	String data = (String)file::load_temp("day3.txt")!;
	usz len = data.len;
	long total = 0;
	bool enabled = true;
	for (usz i = 0; i < len;)
	{
		i += read_next(data[i..], &total, &enabled);
	}
	return total;
}


fn void main()
{
	io::printn("Advent of code, day 3.");
	@pool()
	{
		// Simple benchmarking with Clock, "mark" returns the last duraction and resets the clock
		Clock c = clock::now();
		io::printfn("* Task 1: %d - completed in %s", solve1()!!, c.mark());
		io::printfn("* Task 2: %d - completed in %s", solve2()!!, c.mark());
	};
}