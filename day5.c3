/*
 * Advent of Code 2024 day 5
 * Sample solution demonstrating C3 language and standard library.
 */
import std::io, std::time, std::collections;

def UpdateList = List(<IntList>);
def IntList = List(<int>);
def NumsMap = HashMap(<int, Number*>);
def Number = IntList;

fn Number* create_num(int i)
{
	Number* n = mem::temp_new(Number);
	n.temp_init();
	return n;
}

fn NumsMap setup_map(List(<int[2]>) lines)
{
	NumsMap nums;
	nums.temp_init();
	foreach (line : lines)
	{
		Number* n = nums.@get_or_set(line[0], create_num(line[0]));
		n.push(line[1]);
	}
	return nums;
}

fn int! solve1(List(<int[2]>) lines, UpdateList list)
{
	NumsMap nums = setup_map(lines);
	int total = 0;
	foreach OUTER: (update : list)
	{
		foreach (i, v : update.array_view()[1..])
		{
			Number* n = nums[v]!!;
			foreach (val : update.array_view()[0..i])
			{
				if (n.contains(val)) continue OUTER;
			}
		}
		total += update[update.len() / 2];
	}
	return total;
}

fn void fix_order(NumsMap nums, int[] list)
{
	while OUTER: (true)
	{
		foreach (i, v : list[1..])
		{
			Number* n = nums[v]!!;
			foreach (j, val : list[0..i])
			{
				if (n.contains(val))
				{
					list[j] = v;
					list[i + 1] = val;
					continue OUTER;
				}
			}
		}
		return;
	}
}
fn int! solve2(List(<int[2]>) lines, UpdateList list)
{
	NumsMap nums = setup_map(lines);
	int total = 0;
	foreach OUTER: (update : list)
	{
		foreach (i, v : update.array_view()[1..])
		{
			Number* n = nums[v]!!;
			foreach (val : update.array_view()[0..i])
			{
				if (n.contains(val))
				{
					fix_order(nums, update.array_view());
					total += update[update.len() / 2];
					continue OUTER;
				}
			}
		}
	}
	return total;
}

fn void main()
{
	io::printn("Advent of code, day 5.");
	@pool()
	{
		List(<int[2]>) lines;
		lines.temp_init();
		File f = file::open("day5.txt", "rb")!!;
        defer (void)f.close();
		while (String line = io::treadline(&f)!!)
		{
			line = line.trim();
			if (!line.len) break;
			String[] parts = line.tsplit("|");
			assert(parts.len == 2);
			lines.push({ parts[0].to_int()!!, parts[1].to_int()!! });
		}
		UpdateList list;
		list.temp_init();
		while (try line = io::treadline(&f))
		{
			IntList elements;
			elements.temp_init();
			foreach (s : line.tsplit(","))
			{
				elements.push(s.to_int()!!);
			}
			list.push(elements);
		}
		// Simple benchmarking with Clock, "mark" returns the last duraction and resets the clock
		Clock c = clock::now();
		io::printfn("* Task 1: %d - completed in %s", solve1(lines, list)!!, c.mark());
		io::printfn("* Task 2: %d - completed in %s", solve2(lines, list)!!, c.mark());
	};
}
