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
	print_endline("ddc = " + capToString(ddc));
}

function log_gpr_write(idx) = {
    match idx {
        0 => print_endline("cax = " + capToString(rax)),
        1 => print_endline("ccx = " + capToString(rcx)),
        2 => print_endline("cdx = " + capToString(rdx)),
        3 => print_endline("cbx = " + capToString(rbx)),
        4 => print_endline("csp = " + capToString(rsp)),
        5 => print_endline("cbp = " + capToString(rbp)),
        6 => print_endline("csi = " + capToString(rsi)),
        7 => print_endline("cdi = " + capToString(rdi)),
        8 => print_endline("c8 = " + capToString(r8)),
        9 => print_endline("c9 = " + capToString(r9)),
        10 => print_endline("c10 = " + capToString(r10)),
        11 => print_endline("c11 = " + capToString(r11)),
        12 => print_endline("c12 = " + capToString(r12)),
        13 => print_endline("c13 = " + capToString(r13)),
        14 => print_endline("c14 = " + capToString(r14)),
        15 => print_endline("c15 = " + capToString(r15))
    }
}

function log_capr_write(idx) = {
    match idx {
        0 => print_endline("ddc = " + capToString(ddc)),
        1 => print_endline("cfs = " + capToString(cfs)),
        2 => print_endline("cgs = " + capToString(cgs))
    }
}

function log_rflags_write() = {
    print_bits("rflags = ", rflags.bits);
}

function log_rip_write() = {
    print_endline("cip = " + capToString(rip));
}

function log_memory_read(addr, len, value) = {
	print_endline(bits_str(read_rip()) + ": R " + bits_str(addr) + " " + dec_str(len) + " " + bits_str(value))
}

function log_memory_write(addr, len, value) = {
	print_endline(bits_str(read_rip()) + ": W " + bits_str(addr) + " " + dec_str(len) + " " + bits_str(value))
}

function log_memtag_read(addr, tag) = {
	print_endline(bits_str(read_rip()) + ": R tag[" + bits_str(addr) + "] ->  " + (if tag then "1" else "0"))
}

function log_memtag_write(addr, tag) = {
	print_endline(bits_str(read_rip()) + ": W tag[" + bits_str(addr) + "] <-  " + (if tag then "1" else "0"))
}

$endif
