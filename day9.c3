/*
 * Advent of Code 2024 day 9
 * Sample solution demonstrating C3 language and standard library.
 */
import std::io, std::time, std::collections;

fn void fill(ushort[] data, ushort value, int start, char len)
{
	if (len == 0) return;
	data[start:len] = value;
}

fn ulong solve()
{
	char[] data = file::load_temp("day9.txt")!!;
	usz len;
	foreach (i, c : data)
	{
		len += (usz)(c - '0');
	}
	ushort[] packed = mem::temp_alloc_array(ushort, len);
	usz pos;
	foreach (i, c : data)
	{
		if (c == '0') continue;
		len = c - (usz)'0';
		packed[pos:len] = i % 2 ? ushort.max : (ushort)(i / 2);
		pos += len;
	}
	foreach (i, c : packed)
	{
		if (c == ushort.max)
		{
			pos = i;
			break;
		}
	}
	foreach_r (i, &x : packed)
	{
		if (*x == ushort.max) continue;
		packed[pos++] = *x;
		*x = ushort.max;
		while (pos < i && packed[pos] != ushort.max) pos++;
		if (i <= pos) break;
	}
	usz total = 0;
	// Checksum
	foreach (i, x : packed)
	{
		if (x == ushort.max) break;
		total += x * i;
	}
	return total;
}

fn ulong calc_value(usz num, isz index, usz len)
{
	return num * (2 * index + len - 1) * len / 2;
}

// This should be solved with a nicer data structure
fn ulong solve2()
{
	char[] data = file::load_temp("day9.txt")!!;
	ulong total;
	usz idx;
	usz reverse_idx = data.len - 1;
	foreach OUTER: (i, &c_ptr : data)
	{
		usz len = (usz)*c_ptr - '0';
		if (!len) continue;
		if (len >= 10)
		{
			idx += len - 10;
			continue;
		}
		if (i % 2 == 0)
		{
			total += calc_value(i / 2, idx, len);
			idx += len;
			continue;
		}
		// Quadratic, ouch!
		foreach_r (j, &rcptr : data)
		{
			if (j % 2) continue;
			if (i >= j) break;
			usz reverse_len = (usz)*rcptr - '0';
			if (reverse_len >= 10) continue;
			if (len >= reverse_len)
			{
				total += calc_value(j / 2, idx, reverse_len);
				idx += reverse_len;
				*rcptr += 10;
				len -= reverse_len;
				if (!len) continue OUTER;
			}
		}
		idx += len;
	}
	return total;
}

fn void main()
{
	io::printn("Advent of code, day 9.");
	@pool()
	{
		// Simple benchmarking with Clock, "mark" returns the last duraction and resets the clock
		Clock c = clock::now();
		io::printfn("* Task 1: %d - completed in %s", solve(), c.mark());
		io::printfn("* Task 2: %d - completed in %s", solve2(), c.mark());
	};
}
