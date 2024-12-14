/*
 * Advent of Code 2024 day 14
 * Sample solution demonstrating C3 language and standard library.
 */
import std::io, std::time, std::math, std::collections;

const int[<2>] SIZE = { 101, 103 };

fn void main()
{
	io::printn("Advent of code, day 14.");
	@pool()
	{
		RobotList robots = load_robots();
		// Simple benchmarking with Clock, "mark" returns the last duraction and resets the clock
		Clock c = clock::now();
		io::printfn("* Task 1: %d - completed in %s", solve(robots), c.mark());
		io::printfn("* Task 2: %d - completed in %s", solve2(robots), c.mark());
	};
}

struct Robot
{
	int[<2>] pos;
	int[<2>] velocity;
}

def RobotList = List(<Robot>);

fn RobotList load_robots()
{
	File f = file::open("day14.txt", "rb")!!;
	defer (void)f.close();
	RobotList robots;
	robots.temp_init();
	while (try line = io::treadline(&f))
   	{
   	    line = line[2..];
   	    String[] parts = line.tsplit(" v=");
   	    String[] pos = parts[0].tsplit(",");
   	    String[] v = parts[1].tsplit(",");
		robots.push({{ pos[0].to_int(), pos[1].to_int()}, { v[0].to_int(), v[1].to_int()!! }})!!;
	}
	return robots;
}

fn long solve(RobotList robots)
{
	int steps = 100;
	int[<4>] quadrant;
	int[<2>] mid = SIZE / 2;
	foreach (robot : robots)
	{
		int[<2>] pos = robot.pos;
		pos = ((pos + robot.velocity * steps) % SIZE + SIZE) % SIZE;
		switch
		{
			case pos.x < mid.x && pos.y < mid.y: quadrant[0]++;
			case pos.x > mid.x && pos.y < mid.y: quadrant[1]++;
			case pos.x < mid.x && pos.y > mid.y: quadrant[2]++;
			case pos.x > mid.x && pos.y > mid.y: quadrant[3]++;
		}
	}
	return quadrant.product();
}


fn bool check_robots(RobotList robots, int steps)
{
	int[SIZE.x][SIZE.y] map;
	foreach (robot : robots)
	{
		int[<2>] pos = robot.pos;
		pos = ((pos + robot.velocity * steps) % SIZE + SIZE) % SIZE;
		map[pos.y][pos.x]++;
	}
	foreach (&line : map)
	{
		int consequtive;
		foreach (c : line)
		{
			if (c == 0)
			{
				consequtive = 0;
				continue;
			}
			consequtive++;
			// Needs visual verification!
			if (consequtive > 10) return true;
		}
	}
	return false;
}

fn int solve2(RobotList robots)
{
	for (int i = 0; i < SIZE.x * SIZE.y; i++)
	{
		if (check_robots(robots, i)) return i;
	}
	abort("No solution!");
}