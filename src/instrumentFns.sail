/* Derived from the SAIL-x86 model. */

$include "../sail-x86/model/out.sail"

val printState : unit -> unit effect {rreg, escape}
function printState () = {
	print_endline("cax = " + capToString(rax));
	print_endline("cbx = " + capToString(rbx));
	print_endline("ccx = " + capToString(rcx));
	print_endline("cdx = " + capToString(rdx));
	print_endline("csi = " + capToString(rsi));
	print_endline("cdi = " + capToString(rdi));
	print_endline("cbp = " + capToString(rbp));
	print_endline("csp = " + capToString(rsp));
	print_endline("c8  = " + capToString(r8));
	print_endline("c9  = " + capToString(r9));
	print_endline("c10 = " + capToString(r10));
	print_endline("c11 = " + capToString(r11));
	print_endline("c12 = " + capToString(r12));
	print_endline("c13 = " + capToString(r13));
	print_endline("c14 = " + capToString(r14));
	print_endline("c15 = " + capToString(r15));

	print_bits("rflags = ", rflags.bits);

	print_endline("cip = " + capToString(rip));
	print_endline("ddc = " + capToString(ddc));
}

function log_memory_read(addr, value) = {
	print_endline(bits_str(read_rip()) + ": R " + bits_str(addr) + " " + dec_str(1) + " " + bits_str(value))
}

function log_memory_write(addr, value) = {
	print_endline(bits_str(read_rip()) + ": W " + bits_str(addr) + " " + dec_str(1) + " " + bits_str(value))
}

val x86_step_print_halt : (sbits(48), bool, bool, int) -> bool effect {eamem, escape, rmem, rreg, undef, wmv, wreg}
function x86_step_print_halt(haltAddr, printEachStep, printCount, count) = {
	if read_rip() == haltAddr then {
		return true
	} else {
		x86_fetch_decode_execute();
		if printEachStep then printState();
		if printCount then print_int("Steps = ", count + 1);
		return false
	}
}

// Simulates the same ACL2 function
val x86_run_halt : (sbits(48), int, bool, bool, int) -> int effect {eamem, escape, rmem, rreg, undef, wmv, wreg}
function x86_run_halt (haltAddr, maxSteps, printEachStep, printCount, count) = {
	if maxSteps == 0 then {
		return count
	} else {
		try {
			let halt? : bool = x86_step_print_halt(haltAddr, printEachStep, printCount, count + 1);
			if halt?  then {
				return count
			} else {
				return x86_run_halt(haltAddr, maxSteps - 1, printEachStep, printCount, count + 1)
			}
		}
		catch {
			Emsg(msg) => { print_endline(msg); return count }
		}
	}
}
