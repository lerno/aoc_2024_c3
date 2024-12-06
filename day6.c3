/*
 * Advent of Code 2024 day 6
 */
import std::io, std::time, std::math, std::collections::list;

fn void main()
{
	io::printn("Advent of code, day 6.");
	@pool()
	{
		Map map = load_global_map();
		// Simple benchmarking with Clock, "mark" returns the last duration and resets the clock
		Clock c = clock::now();
		int[2] solution = solve(map);
		io::printfn("* Path part 1/2: %s - completed in %s", solution, c.mark());
	};
}

// Let's build a map with operator overloading, borrowed from ol' AoC 2023
struct Map
{
	char[200][] data;
	int width;
	Dir start_dir;
	int[<2>] start;
}

// This is what we need to implement to have indexing and foreach on the type
fn int Map.len(self) @inline @operator(len) => self.width;
fn char[] Map.get(self, int i) @inline @operator([]) => self.data[i][:self.width];

fn Map load_global_map()
{
	File f = file::open("day6.txt", "rb")!!;
	defer (void)f.close();
	static char[200][200] map_buffer;
	// Load the file into memory
    int height = 0;
    int width @noinit;
    while (try line = io::treadline(&f))
    {
    	width = line.len;
    	map_buffer[height++][0:line.len] = line;
    }
	assert(height < 200 && width < 200);
	Dir start_dir;
	int[<2>] start;
	Map map = { .data = map_buffer[:height], .width = width, };
	foreach (int y, chars : map)
	{
		foreach (int x, &c : chars)
		{
			switch (*c)
			{
				case '^':
					map.start_dir = NORTH;
					map.start = { x, y };
				case '>':
					map.start_dir = EAST;
					map.start = { x, y };
				case '<':
					map.start_dir = WEST;
					map.start = { x, y };
				case 'v':
					map.start_dir = SOUTH;
					map.start = { x, y };
				case '.':
					break;
				case '#':
					*c = 0xFF;
					continue;
				default:
					unreachable();
			}
			*c = 0;
		}
	}
    return map;
}

// A convenient direction enum.
enum Dir : char(int[<2>] dir)
{
	NORTH = {  0, -1 },
	EAST = {  1,  0 },
	SOUTH = {  0,  1 },
	WEST = { -1,  0 },
}

fn char Dir.mask(self)
{
	return (char)(1 << self.ordinal);
}


fn bool walk_map(Map map)
{
	int[<2>] pos = map.start;
	Dir curr_dir = map.start_dir;
	int[<2>] max = { map.width, map.data.len };
	while (map[pos.y][pos.x] & curr_dir.mask() == 0)
	{
		char[] chars = map[pos.y];
		chars[pos.x] |= curr_dir.mask();
		int[<2>] next = pos + curr_dir.dir;
		if (next.comp_lt({ 0, 0 }).or() || next.comp_ge(max).or()) return true;
		if (map[next.y][next.x] == 0xFF)
		{
			curr_dir = (Dir)((curr_dir.ordinal + 1) % 4);
			continue;
		}
		pos = next;
	}
	return false;
}

fn void clean_map(Map map)
{
	foreach (chars : map)
	{
		foreach (&c : chars)
		{
			if (*c != 0 && *c != 0xFF) *c = 0;
		}
	}
}

fn int[2] solve(Map map)
{
	int stepped = 0;
	walk_map(map);
	List(<int[<2>]>) possible_obstructions;
	possible_obstructions.temp_init();
	foreach (int y, chars : map)
	{
		foreach (int x, c : chars)
		{
			if (c != 0 && c != 0xFF)
			{
				stepped++;
				possible_obstructions.push({ x, y });
			}
		}
	}
	int loops = 0;
	foreach (pair : possible_obstructions)
	{
		if (pair == map.start) continue;
		clean_map(map);
		char[] line = map[pair.y];
		line[pair.x] = 0xFF;
		if (!walk_map(map)) loops++;
		line[pair.x] = 0;
	}
	return { stepped, loops };
}