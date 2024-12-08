/*
 * Advent of Code 2024 day 8
 * Sample solution demonstrating C3 language and standard library.
 */
import std::io, std::time, std::collections;

def CoordList = List(<int[<2>]>);
def AntinodeMap = HashMap(<int[<2>], bool>);

fn uint int[<2>].hash(self) => self[0] * 31 + self[1];

macro int[<2>].in_bounds(self, int[<2>] bounds)
{
	return self.comp_ge({ 0, 0 }).and() && self.comp_lt(bounds).and();
}

fn int add_antinode_line(AntinodeMap* map, int[<2>] pos, int[<2>] diff, int[<2>] bounds)
{
	int total;
	while (pos.in_bounds(bounds))
	{
		if (!map.has_key(pos))
		{
			map.set(pos, true);
        	total++;
		}
		pos += diff;
	}
	return total;
}

fn int add_antinodes_with_resonance(AntinodeMap* map, CoordList* list, int[<2>] bounds)
{
	if (list.len() == 1) return 0;
	int total = 0;
	foreach (i, val : list)
	{
		foreach (j, val2 : list.array_view()[i + 1..])
		{
			int[<2>] diff = val - val2;
			total += add_antinode_line(map, val, diff, bounds);
			total += add_antinode_line(map, val - diff, -diff, bounds);
		}
	}
	return total;
}

fn int add_antinodes(AntinodeMap* map, CoordList* list, int[<2>] bounds)
{
	if (list.len() == 1) return 0;
	int total = 0;
	foreach (i, val : list)
	{
		foreach (j, val2 : list.array_view()[i + 1..])
		{
			int[<2>] pos1 = 2 * val - val2;
			int[<2>] pos2 = 2 * val2 - val;
			if (pos1.in_bounds(bounds) && !map.has_key(pos1))
			{
				map.set(pos1, true);
				total++;
			}
			if (pos2.in_bounds(bounds) && !map.has_key(pos2))
			{
				map.set(pos2, true);
				total++;
			}
		}
	}
	return total;
}

fn int solve(bool resonance)
{
	File f = file::open("day8.txt", "rb")!!;
	defer (void)f.close();
	int y = 0;
	int width = -1;
	HashMap(<char, CoordList*>) map;
	map.temp_init();
	while (try line = io::treadline(&f))
	{
		if (width < 0) width = line.len;
		foreach (int x, c : line)
		{
			if (c != '.')
			{
				CoordList* list = map.@get_or_set(c, mem::temp_new(CoordList).temp_init());
				list.push({ x, y });
			}
		}
		y++;
	}

	AntinodeMap antinodes;
	antinodes.temp_init();
	int total = 0;
	int[<2>] bounds = { width, y };
	map.@each(;char key, CoordList* list)
	{
		if (resonance)
		{
			total += add_antinodes_with_resonance(&antinodes, list, bounds);
		}
		else
		{
			total += add_antinodes(&antinodes, list, bounds);
		}
	};
	return total;
}


fn void main()
{
	io::printn("Advent of code, day 8.");
	@pool()
	{
		// Simple benchmarking with Clock, "mark" returns the last duraction and resets the clock
		Clock c = clock::now();
		io::printfn("* Task 1: %d - completed in %s", solve(false), c.mark());
		io::printfn("* Task 2: %d - completed in %s", solve(true), c.mark());
	};
}