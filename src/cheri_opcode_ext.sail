$ifndef __X86_OPCODE_EXT
$define __X86_OPCODE_EXT

$include "../sail-x86/model/structures.sail"

enum proc_mode = {
  Mode_Capability,
  Mode_64bit,
  Mode_Compatibility,
  Mode_Protected,
  Mode_Real,
  Mode_SMM
}

function in_capability_mode(proc_mode) : proc_mode -> bool = match proc_mode {
    Mode_Capability => true,
    _ => false
}
function in_64bit_mode(proc_mode) : proc_mode -> bool = match proc_mode {
    Mode_Capability => true,
    Mode_64bit => true,
    _ => false
}
function in_compatibility_mode(proc_mode) : proc_mode -> bool = match proc_mode {
    Mode_Compatibility => true,
    _ => false
}
function in_protected_mode(proc_mode) : proc_mode -> bool = match proc_mode {
    Mode_Protected => true,
    _ => false
}
function in_real_mode(proc_mode) : proc_mode -> bool = match proc_mode {
    Mode_Real => true,
    _ => false
}
function in_system_management_mode(proc_mode) : proc_mode -> bool = match proc_mode {
    Mode_SMM => true,
    _ => false
}

/*! Returns the current mode of operation of the x86 machine
<p>We only support 64-bit, Compatibility, and 32-bit Protected Modes
 for now.</p>
 <p>See @ ( see x86-modes ) .</p> */
val x86_operation_mode : unit -> proc_mode

function x86_operation_mode () = {
    if n64_bit_modep() then {
        if rip.flag_cap_mode then Mode_Capability else Mode_64bit
    } else Mode_Compatibility
}

bitfield prefixes : bits(52) =
  {nxt : 51..44, adr : 43..36, opr : 35..28, seg : 27..20, rep : 19..12, lck : 11..4, num : 3..0}

val is_ext_prefix_byte : (proc_mode, prefixes, bits(8), range(0, 15), bits(8)) -> bool

function is_ext_prefix_byte(proc_mode, prefixes, rex_byte, cnt, byte) = {
    if in_64bit_mode(proc_mode) | in_capability_mode(proc_mode) then {
        match byte {
          0x06 => true,
          0x07 => true,
          _ => false
	}
    } else false
}

val process_ext_prefix_byte : (proc_mode, prefixes, bits(8), range(0, 15), bits(8)) -> (prefixes, bits(8), bool)

function process_ext_prefix_byte(proc_mode, prefixes, rex_byte, cnt, byte) = {
    assert(in_64bit_mode(proc_mode) | in_capability_mode(proc_mode));
    match byte {
      0x06 => ([prefixes with opr = byte], rex_byte, true),
      0x07 => ([prefixes with adr = byte], rex_byte, true),
      _ => (prefixes, rex_byte, false)
    }
}

val ext_one_byte_opcode_execute : (proc_mode, sbits(48), sbits(48), prefixes, bits(8), bits(8), modr_m, sib) -> bool

val ext_two_byte_opcode_execute : (proc_mode, sbits(48), sbits(48), prefixes, bits(8), bits(8), bits(8), modr_m, sib) -> bool

val ext_vex_0f_execute : (proc_mode, sbits(48), sbits(48), prefixes, bits(8), vex_prefixes, bits(8), modr_m, sib) -> bool

function ext_vex_0f_execute(proc_mode, start_rip, temp_rip, prefixes, rex_byte, vex_prefixes, opcode, modr_m, sib) = false

val ext_vex_0f38_execute : (proc_mode, sbits(48), sbits(48), prefixes, bits(8), vex_prefixes, bits(8), modr_m, sib) -> bool

function ext_vex_0f38_execute(proc_mode, start_rip, temp_rip, prefixes, rex_byte, vex_prefixes, opcode, modr_m, sib) = false

val ext_vex_0f3a_execute : (proc_mode, sbits(48), sbits(48), prefixes, bits(8), vex_prefixes, bits(8), modr_m, sib) -> bool

function ext_vex_0f3a_execute(proc_mode, start_rip, temp_rip, prefixes, rex_byte, vex_prefixes, opcode, modr_m, sib) = false

val ext_evex_0f_execute : (proc_mode, sbits(48), sbits(48), prefixes, bits(8), evex_prefixes, bits(8), modr_m, sib) -> bool

function ext_evex_0f_execute(proc_mode, start_rip, temp_rip, prefixes, rex_byte, evex_prefixes, opcode, modr_m, sib) = false

val ext_evex_0f38_execute : (proc_mode, sbits(48), sbits(48), prefixes, bits(8), evex_prefixes, bits(8), modr_m, sib) -> bool

function ext_evex_0f38_execute(proc_mode, start_rip, temp_rip, prefixes, rex_byte, evex_prefixes, opcode, modr_m, sib) = false

val ext_evex_0f3a_execute : (proc_mode, sbits(48), sbits(48), prefixes, bits(8), evex_prefixes, bits(8), modr_m, sib) -> bool

function ext_evex_0f3a_execute(proc_mode, start_rip, temp_rip, prefixes, rex_byte, evex_prefixes, opcode, modr_m, sib) = false

val unimplemented_x86_syscall_app_view : (proc_mode, sbits(48), sbits(48), bits(52), bits(8), bits(8), bits(8), bits(8)) -> unit
function unimplemented_x86_syscall_app_view (_, _, _, _, _, _, _, _) = throw(Syscall())

$endif
