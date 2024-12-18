/*
 * Advent of Code 2024 day 17
 */
import std::io, std::time, std::math, std::collections::list;

fn void main()
{
	io::printn("Advent of code, day 17.");
	@pool()
	{
		Data data;
		int[20] program_buffer;
		int[] program = load_program(&data, &program_buffer);

		// Simple benchmarking with Clock, "mark" returns the last duration and resets the clock
		Clock c = clock::now();
		io::printfn("* Path part 1: %s - completed in %s", solve1(data, program), c.mark());
		io::printfn("* Path part 2: %s - completed in %s", solve2(data, program), c.mark());

	};
}

fn int[] load_program(Data* data, int[] buffer)
{
	@pool()
	{
		File f = file::open("day17.txt", "rb")!!;
		defer (void)f.close();
		data.a = io::treadline(&f)[12..].to_long()!!;
		data.b = io::treadline(&f)[12..].to_long()!!;
		data.c = io::treadline(&f)[12..].to_long()!!;
		(void)io::treadline(&f);
		int len = 0;
		// We read the program differently here.
		foreach (i, s : io::treadline(&f)[9..].tsplit(",")!!)
		{
			buffer[i] = (int)s[0] - '0';
			len++;
		}
		return buffer[:len];
	};
}

struct Data
{
	ulong a, b, c;
}

fault ExecResult
{
	SILENT
}

enum OpCode : int
{
	ADV,
	BXL,
	BST,
	JNZ,
	BXC,
	OUT,
	BDV,
	CDV,
}

fn ulong combo(ulong operand, Data* data)
{
	switch (operand)
	{
		case 0..3: return operand;
		case 4: return data.a;
		case 5: return data.b;
		case 6: return data.c;
		default: unreachable();
	}
}

macro int! execute(OpCode code, ulong operand, uint *sptr, Data* data_ref)
{
	switch (code)
	{
		case ADV:
			ulong shift = combo(operand, data_ref);
			if (shift > 63)
			{
				data_ref.a = 0;
				break;
			}
			data_ref.a >>= shift;
		case BXL:
			data_ref.b ^= operand;
		case BST:
			data_ref.b = combo(operand, data_ref) & 0x7;
		case JNZ:
			if (!data_ref.a) break;
			*sptr = (uint)operand;
		case BXC:
			data_ref.b ^= data_ref.c;
		case OUT:
			return (int)combo(operand, data_ref) & 0x7;
		case BDV:
			ulong shift = combo(operand, data_ref);
			if (shift > 63)
			{
				data_ref.b = 0;
				break;
			}
			data_ref.b = data_ref.a >> shift;
		case CDV:
			ulong shift = combo(operand, data_ref);
			if (shift > 63)
			{
				data_ref.b = 0;
				break;
			}
			data_ref.c = data_ref.a >> shift;
		default:
			unreachable();
	}
	return ExecResult.SILENT?;
}

fn String solve1(Data data, int[] program)
{
	uint sptr = 0;
	bool first = true;
	DString str;
	str.temp_init();
	while (sptr < program.len)
	{
		OpCode code = (OpCode)program[sptr++];
		ulong operand = (ulong)program[sptr++];
		if (try res = execute(code, operand, &sptr, &data))
		{
			if (!first) str.append(',');
			str.appendf("%s", res);
			first = false;
		}
	}
	return str.str_view();
}

fn long solve2(Data data, int[] program)
{
	Data original = data;
	ulong found = 0;
	// First we try to use match octets from the most significant bit.
	for OUTER: (int i = program.len - 1; i >= 0; i--)
	{
		// Test octet
		for CHECK: (ulong j = 0; j < 8; j++)
		{
			data = original;
			ulong test = data.a = found + j << (3 * i);
			int index;
			uint sptr = 0;
			bool match = false;
			bool first = true;
			while (sptr < program.len)
			{
				OpCode code = (OpCode)program[sptr++];
				ulong operand = (ulong)program[sptr++];
				if (try res = execute(code, operand, &sptr, &data))
				{
					assert(index < program.len);
					// If we had a match at the place, we're done.
					if (index == i && res == program[index])
					{
						// We update our new "found"
						found = test;
						break CHECK;
					}
					index++;
				}
			}
			// We didn't find a match, so we don't update "found" and hope that
			// this is fine because the next octet makes things right.
		}
	}
	// Now we have a pretty good "found", but it's not quite right yet, so we iterate over a few thousand possibilities
	for OUTER: (long i = -7000; i < 8000; i++)
	{
		data = original;
		ulong test = data.a = found + i;
		int index;
		uint sptr = 0;
		bool match = false;
		bool first = true;
		while (sptr < program.len)
		{
			OpCode code = (OpCode)program[sptr++];
			ulong operand = (ulong)program[sptr++];
			if (try res = execute(code, operand, &sptr, &data))
			{
				if (res != program[index]) continue OUTER;
				index++;
			}
		}
		return test;
	}
	abort("No solution found!");
}