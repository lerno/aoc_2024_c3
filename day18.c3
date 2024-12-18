/*
 * Advent of Code 2024 day 18
 */
import std::io, std::time, std::math, std::collections::list;

fn void main()
{
	io::printn("Advent of code, day 18.");
	@pool()
	{
		// Simple benchmarking with Clock, "mark" returns the last duration and resets the clock
		Clock c = clock::now();
		io::printfn("* Path part 1: %s - completed in %s", solve1(), c.mark());
		io::printfn("* Path part 2: %s - completed in %s", solve2(), c.mark());

	};
}

const DROP = 1024;
const LAST_COORD = 70;

def CoordList = List(<int[<2>]>);
def DataList = List(<int[<3>]>);

fn int solve1()
{
	CoordList list;
	list.temp_init();
	File f = file::open("day18.txt", "rb")!!;
    defer (void)f.close();
    while (try line = io::treadline(&f))
    {
        String[] split = line.tsplit(",");
        list.push({ split[0].to_int(), split[1].to_int() })!!;
    }
    int[71][71] data;
    Slice2d(<int>) map = array::slice2d(&data, 0, LAST_COORD, 0, LAST_COORD);
    for (int i = 0; i < DROP; i++)
    {
        map.set_coord(list[i], int.max);
    }
    DataList points;
    points.temp_init();
    points.push({ 0, 0, 1 });
    while (try point = points.pop())
    {
        int* ref = map.get_coord_ref(point.xy);
        int val = *ref;
        if (val != 0 && (val == int.max || val <= point.z)) continue;
        *ref = point.z;
        if (point.x != 0) points.push({ point.x - 1, point.y, point.z + 1 });
        if (point.y != 0) points.push({ point.x, point.y - 1, point.z + 1 });
        if (point.x != LAST_COORD) points.push({ point.x + 1, point.y, point.z + 1 });
        if (point.y != LAST_COORD) points.push({ point.x, point.y + 1, point.z + 1 });
    }
    return map.get_xy(LAST_COORD, LAST_COORD) - 1;
}

fn bool check_if_blocked(int steps, Slice2d(<int>) map, DataList points, CoordList blocks)
{
    points.clear();
	points.push({ 0, 0, 1 });
	for (int i = 0; i < steps; i++)
	{
		map.set_coord(blocks[i], int.max);
	}
    while (try point = points.pop())
    {
        int* ref = map.get_coord_ref(point.xy);
        int val = *ref;
        if (val != 0 && (val == int.max || val <= point.z)) continue;
        *ref = point.z;
        if (point.x != 0) points.push({ point.x - 1, point.y, point.z + 1 });
        if (point.y != 0) points.push({ point.x, point.y - 1, point.z + 1 });
        if (point.x != LAST_COORD) points.push({ point.x + 1, point.y, point.z + 1 });
        if (point.y != LAST_COORD) points.push({ point.x, point.y + 1, point.z + 1 });
    }
	return map.get_xy(LAST_COORD, LAST_COORD) == 0;
}

fn int[<2>] solve2()
{
	CoordList list;
	list.temp_init();
	File f = file::open("day18.txt", "rb")!!;
    defer (void)f.close();
    while (try line = io::treadline(&f))
    {
        String[] split = line.tsplit(",");
        list.push({ split[0].to_int(), split[1].to_int() })!!;
    }
    int[71][71] data;
    Slice2d(<int>) map = array::slice2d(&data, 0, LAST_COORD, 0, LAST_COORD);
    DataList points;
    points.temp_init();
    int more = (int)list.len();
    int less = 0;
    int i = DROP;
    // Binary search for a solution
    while (true)
    {
        mem::clear(&data, $sizeof(data));
	    bool is_blocked = check_if_blocked(i, map, points, list);
	    if (is_blocked)
	    {
	        more = i - 1;
	        i = (more + less) / 2;
	    }
	    else
	    {
	        if (more < less) return list[(usz)i];
	        less = i + 1;
	        i = (less + more) / 2;
	    }
    }
}
