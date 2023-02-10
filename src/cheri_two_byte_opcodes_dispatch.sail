function ext_two_byte_opcode_execute(proc_mode, start_rip, temp_rip, prefixes, mandatory_prefix, rex_byte, opcode, modr_m, sib) = {
    if 0x06 == prefixes[opr] & logbitp(3, rex_byte) then {
        throw(Emsg("A fault occurred.  X86-ILLEGAL-INSTRUCTION \"#UD Encountered!\""))
    };
    match opcode {
      0x24 => {
          if in_64bit_mode(proc_mode) then {
	      if 0xf0 == prefixes[lck] then {
                  throw(Emsg("A fault occurred.  X86-ILLEGAL-INSTRUCTION \"#UD Encountered!\""))
	      } else {
	          let (flg1, modr_m) = rme08(proc_mode,
		    select_address_size(proc_mode, Some(prefixes)),
		    sail_sign_extend(temp_rip, 64), None(), 1, ":X");
		  if is_some(flg1) then throw(Emsg("Model state error: :MODR/M-BYTE-READ-ERROR"));
		  let (flg2, temp_rip) = add_to_iptr(proc_mode,
		    temp_rip, 0x000000000001);
		  let temp_rip = truncate(temp_rip, 48);
		  if is_some(flg2) then throw(Emsg("Model state error: :INCREMENT-ERROR"));
		  /* NB: No SIB byte. */
                  x86_mov_cap_regs_op_en_mr(proc_mode, start_rip, temp_rip,
		    prefixes, rex_byte, opcode, Mk_modr_m(modr_m));
	          true
              }
	  } else {
	      false
	  }
      },
      0x25 => {
          if in_64bit_mode(proc_mode) then {
	      if 0xf0 == prefixes[lck] then {
                  throw(Emsg("A fault occurred.  X86-ILLEGAL-INSTRUCTION \"#UD Encountered!\""))
	      } else {
	          let (flg1, modr_m) = rme08(proc_mode,
		    select_address_size(proc_mode, Some(prefixes)),
		    sail_sign_extend(temp_rip, 64), None(), 1, ":X");
		  if is_some(flg1) then throw(Emsg("Model state error: :MODR/M-BYTE-READ-ERROR"));
		  let (flg2, temp_rip) = add_to_iptr(proc_mode,
		    temp_rip, 0x000000000001);
		  let temp_rip = truncate(temp_rip, 48);
		  if is_some(flg2) then throw(Emsg("Model state error: :INCREMENT-ERROR"));
		  /* NB: No SIB byte. */
                  x86_mov_cap_regs_op_en_rm(proc_mode, start_rip, temp_rip,
		    prefixes, rex_byte, opcode, Mk_modr_m(modr_m));
	          true
              }
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
