/*
 * Advent of Code 2024 day 15
 */
import std::io, std::time, std::math, std::collections::list;

fn void main()
{
	io::printn("Advent of code, day 15.");
	@pool()
	{
		String instructions;
		// Simple benchmarking with Clock, "mark" returns the last duration and resets the clock
		Clock c = clock::now();
		io::printfn("* Path part 1: %s - completed in %s", solve1(), c.mark());
		io::printfn("* Path part 2: %s - completed in %s", solve2(), c.mark());
	};
}


// Let's build a map with operator overloading, borrowed from ol' AoC 2023
struct Map
{
	char[200][] data;
	int width;
	int[<2>] start;
}

// This is what we need to implement to have indexing and foreach on the type
fn int Map.len(self) @inline @operator(len) => self.data.len;
fn char[] Map.get(self, int i) @inline @operator([]) => self.data[i][:self.width];

fn int[<2>] push(Map map, int[<2>] pos, int[<2>] dir)
{
	int[<2>] new_pos = dir + pos;
	switch (map[new_pos.y][new_pos.x])
	{
		case '.': return new_pos;
		case '#': return pos;
		case 'O': break;
		default: unreachable();
	}
	int[<2>] push_pos = new_pos + dir;
	while OUTER: (true)
	{
		char c = map[push_pos.y][push_pos.x];
		switch (c)
		{
			case 'O': break;
			case '.': break OUTER;
			default: return pos;
		}
		push_pos += dir;
	}
	map[push_pos.y][push_pos.x] = 'O';
	map[new_pos.y][new_pos.x] = '.';
	return new_pos;
}

fn long solve1()
{
	File f = file::open("day15.txt", "rb")!!;
	defer (void)f.close();
	static char[200][200] map_buffer;
	// Load the file into memory
    int height = 0;
    int width @noinit;
    int[<2>] start;
    String instructions;
    while (try line = io::treadline(&f))
    {
    	if (!line.len) break;
    	width = line.len;
    	if (try i = line.index_of("@"))
    	{
    	    start = { (int)i, height };
    	    line[i] = '.';
    	}
    	map_buffer[height++][0:width] = line;
    }
	assert(height < 200 && width < 200);
    while (try line = io::treadline(&f))
    {
		instructions = instructions.tconcat(line);
    }
	Map map = { .data = map_buffer[:height], .width = width, .start = start };

	int[<2>] pos = map.start;
	foreach (c : instructions)
	{
		switch (c)
		{
			case '^': pos = push(map, pos, { 0, -1 });
			case '<': pos = push(map, pos, { -1, 0 });
			case '>': pos = push(map, pos, { +1, 0 });
			case 'v': pos = push(map, pos, { 0, +1 });
		}
	}
	long total;
	foreach (y, line : map.data)
	{
		foreach (x, c : line)
		{
			if (c == 'O') total += (long)(x + y * 100);
		}
	}
	return total;
}

fn void print_map(Map map, int[<2>] pos)
{
	io::printn();
	foreach (y, l : map)
	{
		io::print(y);
		if (pos.y == y)
		{
			l[pos.x] = '@';
			io::printn((String)l);
			l[pos.x] = '.';
			continue;
		}
		io::printn((String)l);
	}
}

fn bool may_push2(Map map, int[<2>] pos, int[<2>] dir)
{
	int[<2>] new_pos = dir + pos;
	switch (map[new_pos.y][new_pos.x])
	{
		case '.':
			return true;
		case '#':
			return false;
		case '[':
			if (dir.x > 0) return may_push2(map, new_pos + { 1, 0 }, dir);
			// Vertical
			return may_push2(map, new_pos, dir) && may_push2(map, new_pos + { 1, 0 }, dir);
		case ']':
			if (dir.x < 0) return may_push2(map, new_pos + { -1, 0 }, dir);
			return may_push2(map, new_pos, dir) && may_push2(map, new_pos + { -1, 0 }, dir);
		default: unreachable();
	}
}

fn void make_push2(Map map, int[<2>] pos, int[<2>] dir, char c)
{
	int[<2>] new_pos = dir + pos;
	switch (map[new_pos.y][new_pos.x])
	{
		case '.':
			break;
		case '[':
			make_push2(map, new_pos, dir, '[');
			if (dir.y != 0) make_push2(map, new_pos + { 1, 0 }, dir, ']');
		case ']':
			make_push2(map, new_pos, dir, ']');
			if (dir.y != 0) make_push2(map, new_pos + { -1, 0 }, dir, '[');
		default: unreachable();
	}
	map[pos.y][pos.x] = '.';
	map[new_pos.y][new_pos.x] = c;
}

fn int[<2>] push2(Map map, int[<2>] pos, int[<2>] dir)
{
	int[<2>] new_pos = dir + pos;
	switch (map[new_pos.y][new_pos.x])
	{
		case '.':
			return new_pos;
		case '[':
			if (!may_push2(map, pos, dir)) return pos;
			make_push2(map, pos, dir, '.');
			return new_pos;
		case ']':
			if (!may_push2(map, pos, dir)) return pos;
			make_push2(map, pos, dir, '.');
			return new_pos;
		case '#':
			return pos;
		default: unreachable();
	}
}

fn long solve2()
{
	File f = file::open("day15.txt", "rb")!!;
	defer (void)f.close();
	static char[200][200] map_buffer;
	// Load the file into memory
    int height = 0;
    int width @noinit;
    int[<2>] start;
    String instructions;
    while (try line = io::treadline(&f))
    {
    	if (!line.len) break;
    	width = line.len * 2;
    	char[] new_line = map_buffer[height++][0 : width];
    	foreach (i, c : line)
    	{
    	    switch (c)
    	    {
    	        case '@':
		    	    start = { (int)i * 2, height - 1 };
		    	    nextcase;
    	        case '.':
    	            new_line[i * 2 : 2] = '.';
    	        case 'O':
    	            new_line[i * 2 : 2] = "[]";
    	        case '#':
					new_line[i * 2 : 2] = "##";
				default:
					break;
    	    }
    	}
    }
	assert(height < 200 && width < 200);
    while (try line = io::treadline(&f))
    {
		instructions = instructions.tconcat(line);
    }
	Map map = { .data = map_buffer[:height], .width = width, .start = start };
	int[<2>] pos = map.start;
	foreach (c : instructions)
	{
		switch (c)
		{
			case '^': pos = push2(map, pos, { 0, -1 });
			case '<': pos = push2(map, pos, { -1, 0 });
			case '>': pos = push2(map, pos, { +1, 0 });
			case 'v': pos = push2(map, pos, { 0, +1 });
		}
	}
	long total;
	foreach (y, line : map.data)
	{
		foreach (x, c : line)
		{
			if (c == '[') total += (long)(x + y * 100);
		}
	}
	return total;
}