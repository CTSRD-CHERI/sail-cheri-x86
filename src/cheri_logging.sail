$ifndef __X86_LOGGING
$define __X86_LOGGING

val printState : unit -> unit
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
}

function log_memory_read(addr, value) = {
	print_endline(bits_str(read_rip()) + ": R " + bits_str(addr) + " " + dec_str(1) + " " + bits_str(value))
}

function log_memory_write(addr, value) = {
	print_endline(bits_str(read_rip()) + ": W " + bits_str(addr) + " " + dec_str(1) + " " + bits_str(value))
}

$endif
