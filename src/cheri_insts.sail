/*! Read a capability from memory or a register.

 Similar to x86_operand_from_modr_m_and_sib_bytes */

val x86_cap_from_modr_m_and_sib_bytes : (proc_mode, bool, seg_reg_idx, prefixes, sbits(48), bits(8), bits(3), bits(2), sib, bits(3)) -> (option(string), Capability, {|0, 1, 2, 4|}, sbits(64))

function x86_cap_from_modr_m_and_sib_bytes (proc_mode, memory_ptr?, seg_reg, prefixes, temp_rip, rex_byte, r_m, mod_var, sib, num_imm_bytes) = {
    let (flg0, addr, increment_rip_by) : (option(string), sbits(64), {|0, 1, 2, 4|}) = {
        if mod_var == 0b11 then {
            (None() : option(string), 0x0000000000000000, 0)
        } else {
            x86_effective_addr(proc_mode, prefixes, temp_rip, rex_byte, r_m, mod_var, sib, num_imm_bytes)
        }
    };
    if is_some(flg0) then {
        (Some("x86-effective-addr-error"), null_cap, 0, 0x0000000000000000)
    } else {
        let (flg2, operand) : (option(string), Capability) = {
            if mod_var == 0b11 then {
                (None() : option(string), read_gpr(unsigned(reg_index(r_m, rex_byte, 0b00))))
            } else {
                let addr_size = select_address_size(proc_mode, Some(prefixes));
                let base_reg = select_base_register(proc_mode, rex_byte, r_m, mod_var, sib);
                rmecap(proc_mode, addr_size, addr, base_reg, seg_reg, memory_ptr?)
            }
        };
        if is_some(flg2) then {
            (Some("Rm-Cap-Error"), null_cap, 0, 0x0000000000000000)
        } else {
            (None() : option(string), operand, increment_rip_by, addr)
        }
    }
}

/*! Write a capability operand to memory or a general-purpose register.

 Similar to x86_operand_to_reg_mem */

val x86_cap_to_reg_mem : (proc_mode, bool, Capability, seg_reg_idx, sbits(64), prefixes, bits(8), bits(3), bits(2), sib) -> option(string)

function x86_cap_to_reg_mem (proc_mode, memory_ptr?, operand, seg_reg, addr, prefixes, rex_byte, r_m, mod_var, sib) = {
    if mod_var == 0b11 then {
        write_gpr(unsigned(reg_index(r_m, rex_byte, 0b00)), operand);
	None() : option(string)
    } else {
	let addr_size = select_address_size(proc_mode, Some(prefixes));
	let base_reg = select_base_register(proc_mode, rex_byte, r_m, mod_var, sib);
	wmecap(proc_mode, addr_size, addr, base_reg, seg_reg, operand, memory_ptr?)
    }
}

val x86_movc_op_en_mr : (proc_mode, sbits(48), sbits(48), prefixes, bits(8), bits(8), modr_m, sib) -> unit

function x86_movc_op_en_mr (proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib) = {
    let r_m : bits(3) = modr_m[r_m];
    let mod_var : bits(2) = modr_m[mod];
    let reg : bits(3) = modr_m[reg];
    let register_var : Capability = read_gpr(unsigned(reg_index(reg, rex_byte, 0b10)));
    let (flg0, addr, increment_rip_by) : (option(string), sbits(64), {|0, 1, 2, 4|}) = {
        if mod_var == 0b11 then {
            (None() : option(string), 0x0000000000000000, 0)
        } else {
            x86_effective_addr(proc_mode, prefixes, temp_rip, rex_byte, r_m, mod_var, sib, 0b000)
        }
    };
    let increment_rip_by : bits(3) = bits_of_int(increment_rip_by, 3);
    if is_some(flg0) then throw(Emsg("Model state error: :X86-EFFECTIVE-ADDR-ERROR"));
    let seg_reg : seg_reg_idx = select_segment_register(proc_mode, prefixes, mod_var, r_m, sib);
    let (flg, temp_rip) : (option(string), sbits(49)) = add_to_iptr(proc_mode, temp_rip, sail_zero_extend(increment_rip_by, 48));
    if is_some(flg) then throw(Emsg("Model state error: :RIP-INCREMENT-ERROR"));
    let badlength? : option(int) = check_instruction_length(start_rip, truncate(temp_rip, 48), 0b000);
    if is_some(badlength?) then throw(Emsg("A fault occurred.  Original ACL2 AST: (!!FAULT-FRESH :GP 0 :INSTRUCTION-LENGTH BADLENGTH?)"));
    let flg2 : option (string) = x86_cap_to_reg_mem(proc_mode, false, register_var, seg_reg, addr, prefixes, rex_byte, r_m, mod_var, sib);
    if is_some(flg2) then throw(Emsg("Model state error: :X86-CAP-TO-REG/MEM"));
    write_iptr(proc_mode, truncate(temp_rip, 48))
}

val x86_movc_op_en_rm : (proc_mode, sbits(48), sbits(48), prefixes, bits(8), bits(8), modr_m, sib) -> unit

function x86_movc_op_en_rm (proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib) = {
    let r_m : bits(3) = modr_m[r_m];
    let mod_var : bits(2) = modr_m[mod];
    let reg : bits(3) = modr_m[reg];
    let seg_reg : seg_reg_idx = select_segment_register(proc_mode, prefixes, mod_var, r_m, sib);
    let (flg0, reg_mem, increment_rip_by, addr) : (option(string), Capability, {|0, 1, 2, 4|}, sbits(64)) = x86_cap_from_modr_m_and_sib_bytes(proc_mode, false, seg_reg, prefixes, temp_rip, rex_byte, r_m, mod_var, sib, 0b000);
    let increment_rip_by : bits(3) = bits_of_int(increment_rip_by, 3);
    if is_some(flg0) then throw(Emsg("Model state error: :X86-CAP-FROM-MODR/M-AND-SIB-BYTES"));
    let (flg, temp_rip) : (option(string), sbits(49)) = add_to_iptr(proc_mode, temp_rip, sail_zero_extend(increment_rip_by, 48));
    if is_some(flg) then throw(Emsg("Model state error: :RIP-INCREMENT-ERROR"));
    let badlength? : option(int) = check_instruction_length(start_rip, truncate(temp_rip, 48), 0b000);
    if is_some(badlength?) then throw(Emsg("A fault occurred.  Original ACL2 AST: (!!FAULT-FRESH :GP 0 :INSTRUCTION-LENGTH BADLENGTH?)"));
    write_gpr(unsigned(reg_index(reg, rex_byte, 0b10)), reg_mem);
    write_iptr(proc_mode, truncate(temp_rip, 48))
}

function ext_one_byte_opcode_execute(proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib) = {
    match opcode {
      0x89 => {
          if 0x06 != prefixes[opr] then false else {
              if 0xf0 == prefixes[lck] then {
	          throw(Emsg("A fault occurred.  X86-ILLEGAL-INSTRUCTION \"#UD Encountered!\""))
	      } else {
                  x86_movc_op_en_mr(proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib);
		  true
	      }
	  }
      },
      0x8b => {
          if 0x06 != prefixes[opr] then false else {
              if 0xf0 == prefixes[lck] then {
	          throw(Emsg("A fault occurred.  X86-ILLEGAL-INSTRUCTION \"#UD Encountered!\""))
	      } else {
                  x86_movc_op_en_rm(proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib);
		  true
	      }
	  }
      },
      _ => false
    }
}
