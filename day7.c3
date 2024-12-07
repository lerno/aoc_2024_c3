/*
 * Advent of Code 2024 day 7
 * Sample solution demonstrating C3 language and standard library.
 */
import std::io, std::time, std::collections;

struct Equation
{
	long sum;
	List(<long>) terms;
}

def EqList = List(<Equation>);

fn EqList load_lines()
{
	EqList lines;
	lines.temp_init();
	File f = file::open("day7.txt", "rb")!!;
    defer (void)f.close();
	while (try line = io::treadline(&f))
	{
		String[] parts = line.tsplit(": ");
		List(<long>) terms;
		terms.temp_init();
		assert(parts.len == 2);
		foreach (s : parts[1].split(" "))
		{
			terms.push(s.to_long()!!);
		}
		lines.push({ parts[0].to_long()!!, terms });
	}
	return lines;
}

fn bool is_solvable1(Equation eq)
{
	long target = eq.sum;
	int variants = 1 << (eq.terms.len() - 1);
	for OUTER: (int i = 0; i < variants; i++)
	{
		long total = eq.terms[0];
		foreach (idx, entry : eq.terms.array_view()[1..])
		{
			int mask = 1 << idx;
			if (mask & i)
			{
				total *= entry;
				continue;
			}
			total += entry;
			if (total > target) continue OUTER;
		}
		if (total == target) return true;
	}
	return false;
}

fn long concat(long val1, long val2)
{
	for (long i = 10 ; ; i *= 10)
	{
		if (val2 < i) return val1 * i + val2;
	}
}

fn bool is_solvable2(Equation eq)
{
	long target = eq.sum;
	int vals = (int)eq.terms.len();
	int variants = 1 << (vals - 1);
	for (int i = 0; i < variants; i++)
	{
		for OUTER: (int j = 0; j < variants; j++)
		{
			long total = eq.terms[0];
			foreach (idx, term : eq.terms.array_view()[1..])
			{
				int pos = 1 << idx;
				switch
				{
					case pos & i != 0:
						if (pos & j) continue OUTER;
						total = concat(total, term);
					case pos & j != 0:
						total *= term;
					default:
						total += term;
				}
				if (total > target) continue OUTER;
			}
			if (total == target) return true;
		}
	}
	return false;
}

fn long solve1()
{
	long total;
	EqList eqs = load_lines();
	foreach (eq : eqs)
	{
		if (is_solvable1(eq)) total += eq.sum;
	}
	return total;
}

fn long solve2()
{
	long total;
	EqList eqs = load_lines();
	foreach (eq : eqs)
	{
		if (is_solvable2(eq)) total += eq.sum;
	}
	return total;
}


fn void main()
{
	io::printn("Advent of code, day 7.");
	@pool()
	{
		// Simple benchmarking with Clock, "mark" returns the last duraction and resets the clock
		Clock c = clock::now();
		io::printfn("* Task 1: %d - completed in %s", solve1(), c.mark());
		io::printfn("* Task 2: %d - completed in %s", solve2(), c.mark());
	};
}