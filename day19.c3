/*
 * Advent of Code 2024 day 19
 */
import std::io, std::time, std::math, std::collections;

fn void main()
{
	io::printn("Advent of code, day 19.");
	@pool()
	{
		// Simple benchmarking with Clock, "mark" returns the last duration and resets the clock
		Clock c = clock::now();
		io::printfn("* Part 1: %s - completed in %s", solve1(), c.mark());
		io::printfn("* Part 2: %s - completed in %s", solve2(), c.mark());
	};
}

def MemoMap = HashMap(<String, ulong>);

fn int solve1()
{
	File f = file::open("day19.txt", "rb")!!;
	defer (void)f.close();
	String[] patterns = io::treadline(&f).tsplit(", ")!!;
	(void)io::treadline(&f);
	List(<int[2]>) backtrack_buffer;
	backtrack_buffer.temp_init();
	int ok;
	// Let's do backtracking, weeeeeee!
	while NEXT: (try line = io::treadline(&f))
	{
		int index = 0;
		backtrack_buffer.clear();
		while OUTER: (index < line.len)
		{
			int pattern_start = 0;
			while (true)
			{
				String s = line[index..];
				foreach (int i, p : patterns[pattern_start..])
				{
					// Found, so we store the backtrack "token"".
					if (s.starts_with(p))
					{
						if (i != patterns.len - 1)
						{
							backtrack_buffer.push({ index, pattern_start + i + 1 });
						}
						index += p.len;
						continue OUTER;
					}
				}
				int[<2>]! backtrack = backtrack_buffer.pop();
				if (catch backtrack) continue NEXT;
				pattern_start = backtrack.y;
				index = backtrack.x;
			}
		}
		ok++;
	}
	return ok;
}

fn ulong match(MemoMap* memo, String line, String[] patterns)
{
	if (try val = memo.get(line)) return val;
	ulong total;
	foreach (p : patterns)
	{
		if (line.starts_with(p))
		{
			if (p.len == line.len)
			{
				total++;
				continue;
			}
			total += match(memo, line[p.len..], patterns);
		}
	}
	memo.set(line, total);
	return total;
}

fn ulong solve2()
{
	// For this we *need* memoization.
	File f = file::open("day19.txt", "rb")!!;
	defer (void)f.close();
	String[] patterns = io::treadline(&f).tsplit(", ")!!;
	(void)io::treadline(&f);
	MemoMap memo;
	memo.temp_init();
	ulong ok;
	while NEXT: (try line = io::treadline(&f))
	{
		ok += match(&memo, line, patterns);
	}
	return ok;
}