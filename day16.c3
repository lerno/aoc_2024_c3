/*
 * Advent of Code 2024 day 16
 *
 * This day's solution is subpar. It uses depth-first, which will lead to a stack overflow on -O0
 * But I'm down with a fever, so this has to be good enough.
 */
import std::io, std::time, std::math, std::collections::list;

fn void main()
{
	io::printn("Advent of code, day 16.");
	@pool()
	{
		// Simple benchmarking with Clock, "mark" returns the last duration and resets the clock
		Clock c = clock::now();
		io::printfn("* Path part 1/2: %s - completed in %s", solve(), c.mark());
	};
}

enum Dir : int (usz[<2>] change)
{
	RIGHT = { 1, 0 },
	DOWN = { 0, 1 },
	LEFT = { -1, 0 },
	UP = { 0, -1 },
}

def IntMap = Slice2d(<int[4]>);
def BoolMap = Slice2d(<bool>);

fn bool try_walk(IntMap map, BoolMap best, usz[<2>] start, Dir dir, Dir old_dir, usz[<2>] end, int score, int result)
{
	// Walking backwards is not ok.
	if ((dir.ordinal + 2) % 4 == old_dir.ordinal && score != 0)
	{
		return false;
	}
	// Same direction
	if (dir == old_dir) return walk(map, best, start + dir.change, dir, end, score + 1, result);
	return walk(map, best, start + dir.change, dir, end, score + 1001, result);
}

fn bool walk(IntMap map, BoolMap best, usz[<2>] start, Dir dir, usz[<2>] end, int score, int result)
{
	int[<4>] loc_score = map.get_coord(start);
	int dir_score = loc_score[dir.ordinal];
	if (dir_score == int.max || (dir_score > 0 && (dir_score < score))) return false;
	loc_score[dir.ordinal] = score;
	map.set_coord(start, loc_score);
	if (start == end)
	{
		return score <= result;
	}
	bool val1 = try_walk(map, best, start, UP, dir, end, score, result);
	bool val2 = try_walk(map, best, start, DOWN, dir, end, score, result);
	bool val3 = try_walk(map, best, start, LEFT, dir, end, score, result);
	bool val4 = try_walk(map, best, start, RIGHT, dir, end, score, result);
	if (val1 || val2 || val3 || val4)
	{
		if (result != int.max) best.set_coord(start, true);
		return true;
	}
	return false;
}
fn int[<2>] solve()
{
	File f = file::open("day16.txt", "rb")!!;
	defer (void)f.close();
	int[4][200][200]* map_buffer = mem::temp_new(int[4][200][200]);
	int[4][200][200]* map_copy = mem::temp_new(int[4][200][200]);
	bool[200][200]* best_buffer = mem::temp_new(bool[200][200]);
	// Load the file into memory
    int height = 0;
    int width @noinit;
    usz[<2>] start @noinit;
    usz[<2>] end @noinit;
    String instructions;
    while (try line = io::treadline(&f))
    {
        if (!height) width = line.len;
        foreach (x, c : line)
        {
            switch (c)
            {
                case 'S': start = { x, height };
                case 'E': end = { x, height };
                case '#': (*map_buffer)[height][x][..] = int.max;
            }
        }
        height++;
    }
    *map_copy = *map_buffer;
    IntMap slice = array::slice2d(map_buffer, 0, width, 0, height);
    IntMap slice2 = array::slice2d(map_copy, 0, width, 0, height);
    BoolMap best = array::slice2d(best_buffer, 0, width, 0, height);
    walk(slice, best, start, RIGHT, end, 0, int.max);
    int result = int.max;
    foreach (val : slice.get_coord(end))
    {
        if (val > 0) result = math::min(result, val);
    }
    walk(slice2, best, start, RIGHT, end, 0, result);
    int total = 0;
    best.@each(;usz[<2>] pos, bool val)
    {
        if (val) total++;
	};

	return { result , total + 1 };
}
