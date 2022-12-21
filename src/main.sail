/* Derived from the SAIL-x86 model. */

$include "instrumentFns.sail"

register haltAddrReg : sbits(48)

// Set 64 bit mode
val initialise_64_bit_mode : unit -> unit effect {escape, rreg, wreg}
function initialise_64_bit_mode () = {
	msrs[0][11 .. 0] = [Mk_ia32_eferbits(msrs[0][11 ..0]) with lma = 0b1].bits;
	seg_hidden_attrs[1][15 .. 0] = [Mk_code_segment_descriptor_attributesbits(seg_hidden_attrs[1][15 .. 0]) with l = 0b1].bits;
}

// Using the __SetConfig method.  See aarch32 example for example.
val __SetConfig : (string, int) -> unit effect {escape, rreg, wreg}
function __SetConfig (arg, value) =
	match arg {
		"rip" => { rip = { default_cap with address = get_slice_int(64, value, 0) } },
		"rax" => { write_rgfi(0, get_slice_int(64, value, 0)) },
		"rbx" => { write_rgfi(3, get_slice_int(64, value, 0)) },
		"rcx" => { write_rgfi(1, get_slice_int(64, value, 0)) },
		"rdx" => { write_rgfi(2, get_slice_int(64, value, 0)) },
		"rsi" => { write_rgfi(6, get_slice_int(64, value, 0)) },
		"rdi" => { write_rgfi(7, get_slice_int(64, value, 0)) },
		"rsp" => { write_rgfi(4, get_slice_int(64, value, 0)) },
		"rbp" => { write_rgfi(5, get_slice_int(64, value, 0)) },
		"r8" => { write_rgfi(8, get_slice_int(64, value, 0)) },
		"r9" => { write_rgfi(9, get_slice_int(64, value, 0)) },
		"r10" => { write_rgfi(10, get_slice_int(64, value, 0)) },
		"r11" => { write_rgfi(11, get_slice_int(64, value, 0)) },
		"r12" => { write_rgfi(12, get_slice_int(64, value, 0)) },
		"r13" => { write_rgfi(13, get_slice_int(64, value, 0)) },
		"r14" => { write_rgfi(14, get_slice_int(64, value, 0)) },
		"r15" => { write_rgfi(15, get_slice_int(64, value, 0)) },
		"rflags" => { rflags = Mk_rflagsbits(get_slice_int(32, value, 0)) },
		"cr4" => { ctrs[4] = get_slice_int(64, value, 0) },
		"ha" => { haltAddrReg = get_slice_int(48, value, 0) },
		"set64bit" => {
			// Ignore the value
			initialise_64_bit_mode()
		},
		"app_view" => { app_view = (value != 0) },
		_ => throw(Emsg("Unrecognised Config"))
	}

// This should print information about __SetConfig to stderr.
val __ListConfig : unit -> unit
function __ListConfig () = ()

// This function is so we can compile to a C emulator which does pretty does everything
val doEverything : unit -> unit effect {eamem, escape, rmem, rreg, undef, wmv, wreg}
function doEverything () = {
	//initialiseState();
	steps = x86_run_halt(haltAddrReg, 10000, true, false, 0);
	print_int("Steps = ", steps);
}

// A main function for C compilation
val main : unit -> unit effect {eamem, escape, rmem, rreg, undef, wmv, wreg}
function main () =
	doEverything()
