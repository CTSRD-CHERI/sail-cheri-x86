/* NOP */
val x86_one_byte_nop : (proc_mode, sbits(48), sbits(48), prefixes, bits(8), bits(8), modr_m, sib) -> unit

function x86_one_byte_nop (proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib) = {
    let increment_rip_by = 0;
    let increment_rip_by : bits(3) = bits_of_int(increment_rip_by, 3);
    let (flg, temp_rip) : (option(string), sbits(49)) = add_to_iptr(proc_mode, temp_rip, sail_zero_extend(increment_rip_by, 48));
    if is_some(flg) then throw(Emsg("Model state error: :RIP-INCREMENT-ERROR"));
    let badlength? : option(int) = check_instruction_length(start_rip, truncate(temp_rip, 48), 0b000);
    if is_some(badlength?) then throw(Emsg("A fault occurred.  Original ACL2 AST: (!!FAULT-FRESH :GP 0 :INSTRUCTION-LENGTH BADLENGTH?)"));
    write_iptr(proc_mode, truncate(temp_rip, 48))
}

function ext_one_byte_opcode_execute(proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib) = {
    if 0x06 == prefixes[opr] & logbitp(3, rex_byte) then {
        throw(Emsg("A fault occurred.  X86-ILLEGAL-INSTRUCTION \"#UD Encountered!\""))
    };
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
      0x90 => {
          if 0xf0 == prefixes[lck] then {
	      throw(Emsg("A fault occurred.  X86-ILLEGAL-INSTRUCTION \"#UD Encountered!\""))
	  } else {
	      x86_one_byte_nop(proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib);
              true
	  }
      },
      0xc7 => {
          if 0x06 != prefixes[opr] then false else {
              if modr_m[reg] == 0b000 then {
                  if 0xf0 == prefixes[lck] then {
	              throw(Emsg("A fault occurred.  X86-ILLEGAL-INSTRUCTION \"#UD Encountered!\""))
	          } else {
                      x86_movc_op_en_mi(proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib);
		      true
		  }
	      } else {
                   throw(Emsg("A fault occurred.  X86-ILLEGAL-INSTRUCTION \"#UD Encountered!\""))
	      }
	  }
      },
      m if unsigned(m) >= unsigned(0xa0) & unsigned(m) <= unsigned(0xa3) => {
          if in_capability_mode(proc_mode) | 0x06 == prefixes[opr] |
	    0x07 == prefixes[adr] then {
	      throw(Emsg("A fault occurred.  X86-ILLEGAL-INSTRUCTION \"#UD Encountered!\""))
	  } else {
	      false
          }
      },
      _ => {
          if 0x06 == prefixes[opr] then {
              throw(Emsg("A fault occurred.  X86-ILLEGAL-INSTRUCTION \"#UD Encountered!\""))
          } else {
              false
          }
      }
    }
}
