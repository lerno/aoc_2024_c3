/*
 * Advent of Code 2024 day 10
 */
import std::io, std::time, std::math, std::collections;

fn uint int[<2>].hash(self) => self.x * 31 + self.y;
def FoundMap = HashMap(<int[<2>], bool>);

fn void main()
{
	io::printn("Advent of code, day 10.");
	@pool()
	{
		Map map = load_global_map();
		// Simple benchmarking with Clock, "mark" returns the last duration and resets the clock
		Clock c = clock::now();
		io::printfn("* Path part 1/2: %s - completed in %s", solve(map), c.mark());
	};
}

struct Map
{
	char[200][] data;
	int width;
}

// This is what we need to implement to have indexing and foreach on the type
fn int Map.len(self) @inline @operator(len) => self.width;
fn char[] Map.get(self, int i) @inline @operator([]) => self.data[i][:self.width];

fn Map load_global_map()
{
	File f = file::open("day10.txt", "rb")!!;
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
	return { .data = map_buffer[:height], .width = width, };
}

fn int trails_to(Map* map, FoundMap* found, int x, int y, char num)
{
	if (num == '9')
	{
		if (!found) return 1;
		if (found.has_key({ x, y })) return 0;
		found.set({x, y}, true);
		return 1;
	}
	int total;
	if (x > 0 && (*map)[y][x - 1] == num + 1) total += trails_to(map, found, x - 1, y, num + 1);
	if (x < map.width - 1 && (*map)[y][x + 1] == num + 1) total += trails_to(map, found, x + 1, y, num + 1);
	if (y < map.data.len - 1 && (*map)[y + 1][x] == num + 1) total += trails_to(map, found, x, y + 1, num + 1);
	if (y > 0 && (*map)[y - 1][x] == num + 1) total += trails_to(map, found, x, y - 1, num + 1);
	return total;
}

fn int[2] solve(Map map)
{
	int total = 0;
	int total_trails = 0;
	FoundMap found;
	found.temp_init();
	foreach (int y, chars : map)
	{
		foreach (int x, c : chars)
		{
			if (c == '0')
			{
				found.clear();
				total += trails_to(&map, &found, x, y, '0');
				total_trails += trails_to(&map, null, x, y, '0');
			}
		}
	}
	return { total, total_trails };
}