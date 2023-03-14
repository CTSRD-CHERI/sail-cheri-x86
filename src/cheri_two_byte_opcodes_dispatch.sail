function ext_two_byte_opcode_execute(proc_mode, start_rip, temp_rip, prefixes, mandatory_prefix, rex_byte, opcode, modr_m, sib) = {
    if 0x06 == prefixes[opr] & logbitp(3, rex_byte) then {
        x86_fault("#UD")
    };
    match opcode {
      0x24 => {
          if in_64bit_mode(proc_mode) then {
              if 0xf0 == prefixes[lck] then {
                  x86_fault("#UD")
              };
              let modr_m = rme08(proc_mode, 
                select_address_size(proc_mode, Some(prefixes)),
                sail_sign_extend(temp_rip, 64), None(), 1, ":X");
              let temp_rip = add_to_iptr(proc_mode, temp_rip, 0x000000000001);
              /* NB: No SIB byte. */
              x86_mov_cap_regs_op_en_mr(proc_mode, start_rip, temp_rip,
                prefixes, rex_byte, opcode, Mk_modr_m(modr_m));
              true
          } else {
              false
          }
      },
      0x25 => {
          if in_64bit_mode(proc_mode) then {
              if 0xf0 == prefixes[lck] then {
                  x86_fault("#UD")
              };
              let modr_m = rme08(proc_mode,
                select_address_size(proc_mode, Some(prefixes)),
                sail_sign_extend(temp_rip, 64), None(), 1, ":X");
              let temp_rip = add_to_iptr(proc_mode, temp_rip, 0x000000000001);
              /* NB: No SIB byte. */
              x86_mov_cap_regs_op_en_rm(proc_mode, start_rip, temp_rip,
                prefixes, rex_byte, opcode, Mk_modr_m(modr_m));
              true
          } else {
              false
          }
      },
      _ => {
          if 0x06 == prefixes[opr] then {
              x86_fault("#UD")
          };
          false
      }
    }
}
