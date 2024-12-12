/*
 * Advent of Code 2024 day 12
 * Sample solution demonstrating C3 language and standard library.
 */
import std::io, std::time;

fn int[<2>] add_region(bool[200][200]* visited, String[] lines, int[<2>] pos, int[<2>] max)
{
	if ((*visited)[pos.x][pos.y]) return { 0, 0 };
	(*visited)[pos.x][pos.y] = true;
	String line = lines[pos.y];
	char c = line[pos.x];
	int[<2>] result = { 1, 0 };
	int ce;
	switch
	{
		case pos.x == 0: ce++;
		case line[pos.x - 1] == c: result += add_region(visited, lines, { pos.x - 1, pos.y }, max);
		default: ce++;
	}
	switch
	{
		case pos.x == max.x: ce++;
		case line[pos.x + 1] == c: result += add_region(visited, lines, { pos.x + 1, pos.y }, max);
		default: ce++;
	}
	switch
	{
		case pos.y == 0: ce++;
		case lines[pos.y - 1][pos.x] == c: result += add_region(visited, lines, { pos.x, pos.y - 1}, max);
		default: ce++;
	}
	switch
	{
		case pos.y == max.y: ce++;
		case lines[pos.y + 1][pos.x] == c: result += add_region(visited, lines, { pos.x, pos.y + 1 }, max);
		default: ce++;
	}
	return result + { 0, ce };
}

fn int solve1()
{
	String map = (String)file::load_temp("day12.txt")!!;
	String[] lines = map.tsplit("\n");
	int[<2>] max = { lines[0].len - 1, lines.len - 1 };
	int total;
	bool[200][200] visited;
	foreach (int y, line : lines)
	{
		foreach (int x, c : line)
		{
			if (visited[x][y]) continue;
			total += add_region(&visited, lines, { x, y }, max).product();
		}
	}
	return total;
}

fn int[<2>] add_region2(bool[200][200]* visited, String[] lines, int[<2>] pos, int[<2>] max)
{
	if ((*visited)[pos.x][pos.y]) return { 0, 0 };
	(*visited)[pos.x][pos.y] = true;
	String line = lines[pos.y];
	char c = line[pos.x];
	int[<2>] result = { 1, 0 };
	int corners;
	char c00 = pos.product() == 0 ? '.' : lines[pos.y - 1][pos.x - 1];
	char c01 = pos.x == 0 || pos.y == max.y ? '.' : lines[pos.y + 1][pos.x - 1];
	char c10 = pos.x == max.x || pos.y == 0 ? '.' : lines[pos.y - 1][pos.x + 1];
	char c11 = pos.x == max.x || pos.y == max.y ? '.' : lines[pos.y + 1][pos.x + 1];
	char d10 = pos.x == 0 ? '.' : line[pos.x - 1];
	char d20 = pos.x == max.x ? '.' : line[pos.x + 1];
	char d01 = pos.y == 0 ? '.' : lines[pos.y - 1][pos.x];
	char d02 = pos.y == max.y ? '.' : lines[pos.y + 1][pos.x];

	if (d10 == c) result += add_region2(visited, lines, { pos.x - 1, pos.y }, max);
	if (d20 == c) result += add_region2(visited, lines, { pos.x + 1, pos.y }, max);
	if (d01 == c) result += add_region2(visited, lines, { pos.x, pos.y - 1}, max);
	if (d02 == c) result += add_region2(visited, lines, { pos.x, pos.y + 1}, max);

	if (d10 != c && d01 != c) corners++;
	if (d10 != c && d02 != c) corners++;
	if (d20 != c && d02 != c) corners++;
	if (d20 != c && d01 != c) corners++;
	if (d10 == c && d01 == c && c00 != c) corners++;
	if (d20 == c && d01 == c && c10 != c) corners++;
	if (d10 == c && d02 == c && c01 != c) corners++;
	if (d20 == c && d02 == c && c11 != c) corners++;

	return result + { 0, corners };
}

fn int solve2()
{
	String map = (String)file::load_temp("day12.txt")!!;
	String[] lines = map.tsplit("\n");
	int[<2>] max = { lines[0].len - 1, lines.len - 1 };
	int total;
	bool[200][200] visited;
	foreach (int y, line : lines)
	{
		foreach (int x, c : line)
		{
			if (visited[x][y]) continue;
			int[<2>] val = add_region2(&visited, lines, { x, y }, max);
			total += val.product();
		}
	}
	return total;
}

fn void main()
{
	io::printn("Advent of code, day 12.");
	@pool()
	{
		// Simple benchmarking with Clock, "mark" returns the last duraction and resets the clock
		Clock c = clock::now();
		io::printfn("* Task 1: %d - completed in %s", solve1(), c.mark());
		io::printfn("* Task 2: %d - completed in %s", solve2(), c.mark());
	};
}