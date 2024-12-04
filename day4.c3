/*
 * Advent of Code 2024 day 4
 * Sample solution demonstrating C3 language and standard library.
 */
import std::io, std::time, std::collections;

fn int! solve1(List(<String>) lines)
{
	int matches = 0;
	usz line_max = lines[0].len - 3;
	usz lines_max = lines.len() - 3;
	foreach (y, line : lines)
	{
		foreach (x, c : line)
		{
			if (c != 'X') continue;
			if (x > 2 && line[x - 3:3] == "SAM") matches++;
			if (x < line_max && line[x + 1:3] == "MAS") matches++;
			if (y > 2)
			{
				if (lines[y - 1][x] == 'M' && lines[y - 2][x] == 'A' && lines[y - 3][x] == 'S') matches++;
				if (x > 2 && lines[y - 1][x - 1] == 'M' && lines[y - 2][x - 2] == 'A' && lines[y - 3][x - 3] == 'S') matches++;
				if (x < line_max && lines[y - 1][x + 1] == 'M' && lines[y - 2][x + 2] == 'A' && lines[y - 3][x + 3] == 'S') matches++;
			}
			if (y < lines_max)
			{
				if (lines[y + 1][x] == 'M' && lines[y + 2][x] == 'A' && lines[y + 3][x] == 'S') matches++;
				if (x > 2 && lines[y + 1][x - 1] == 'M' && lines[y + 2][x - 2] == 'A' && lines[y + 3][x - 3] == 'S') matches++;
				if (x < line_max && lines[y + 1][x + 1] == 'M' && lines[y + 2][x + 2] == 'A' && lines[y + 3][x + 3] == 'S') matches++;
			}
		}
	}
	return matches;
}

macro bool is_valid_pair(char a, char b)
{
	return (a == 'M' && b == 'S') || (a == 'S' && b == 'M');
}
fn int! solve2(List(<String>) lines)
{
	int matches = 0;
	usz last_x = lines[0].len - 1;
	usz last_y = lines.len() - 1;
	foreach (y, line : lines)
	{
		if (y == 0 || y == last_y) continue;
		foreach (x, c : line)
		{
			if (x == 0 || x == last_x) continue;
			if (c != 'A') continue;
			if (!is_valid_pair(lines[y - 1][x - 1], lines[y + 1][x + 1])) continue;
			if (!is_valid_pair(lines[y + 1][x - 1], lines[y - 1][x + 1])) continue;
			matches++;
		}
	}
	return matches;
}


fn void main()
{
	io::printn("Advent of code, day 4.");
	@pool()
	{
		List(<String>) lines;
		lines.temp_init();
		File f = file::open("day4.txt", "rb")!!;
        defer (void)f.close();
		while (try line = io::treadline(&f)) lines.push(line);
		// Simple benchmarking with Clock, "mark" returns the last duraction and resets the clock
		Clock c = clock::now();
		io::printfn("* Task 1: %d - completed in %s", solve1(lines)!!, c.mark());
		io::printfn("* Task 2: %d - completed in %s", solve2(lines)!!, c.mark());
	};
}
