/*
 * Advent of Code 2024 day 2
 * Sample solution demonstrating C3 language and standard library.
 */
import std::io, std::time;

// Check if safe, optionally skipping an entry
fn bool is_safe(int[] val, int skip)
{
	// Skipping the first entry.
	if (skip == 0)
	{
		skip = -1;
		val = val[1..];
	}
	int prev = val[0];
	// Skipping the second entry.
	if (skip == 1)
	{
		val = val[1..];
		skip = -1;
	}
	// Start testing from index 1
	val = val[1..];
	skip--;
	int dir = val[0] - prev;
	// Wrong direction
	if (dir == 0) return false;
	foreach (i, v : val)
	{
		// Skip?
		if (skip == i) continue;
		switch (v - prev)
		{
			case 1:
			case 2:
			case 3:
				if (dir < 0) return false;
			case -1:
			case -2:
			case -3:
				if (dir > 0) return false;
			default:
				return false;
		}
		prev = v;
	}
	return true;
}

fn int! safety(bool dampener)
{
	File f = file::open("day2.txt", "rb")!;
	defer (void)f.close();
	int total = 0;
	// We read by line and store it in a temporary string.
	while (try line = io::treadline(&f))
	{
		String[] split = line.tsplit(" ");
		assert(split.len < 20);
		int[20] buf;
		// Preconvert it.
		foreach (i, s : split)
		{
			buf[i] = s.to_int()!!;
		}
		int[] val = buf[:split.len];
		if (is_safe(val, -1))
		{
			total++;
			continue;
		}
		if (!dampener) continue;
		for (int i = val.len; i >= 0; i--)
		{
			if (is_safe(val, i))
			{
				total++;
				break;
			}
		}
	}
	return total;
}


fn void main()
{
	io::printn("Advent of code, day 2.");
	@pool()
	{
		// Simple benchmarking with Clock, "mark" returns the last duraction and resets the clock
		Clock c = clock::now();
		io::printfn("* Task 1: %d - completed in %s", safety(false)!!, c.mark());
		io::printfn("* Task 2: %d - completed in %s", safety(true)!!, c.mark());
	};
}