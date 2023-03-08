/* NOP */
val x86_one_byte_nop : (proc_mode, sbits(48), sbits(48), prefixes, bits(8), bits(8), modr_m, sib) -> unit

function x86_one_byte_nop (proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib) = {
    let increment_rip_by = 0;
    let increment_rip_by : bits(3) = bits_of_int(increment_rip_by, 3);
    let temp_rip : sbits(49) = add_to_iptr(proc_mode, temp_rip, sail_zero_extend(increment_rip_by, 48));
    let badlength? : option(int) = check_instruction_length(start_rip, truncate(temp_rip, 48), 0b000);
    if is_some(badlength?) then x86_fault("(!!FAULT-FRESH :GP 0 :INSTRUCTION-LENGTH BADLENGTH?)");
    write_iptr(proc_mode, truncate(temp_rip, 48))
}

function ext_one_byte_opcode_execute(proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib) = {
    if 0x06 == prefixes[opr] & logbitp(3, rex_byte) then {
        x86_fault("#UD")
    };
    match opcode {
      0x01 => {
          if 0x06 != prefixes[opr] then false else {
              /* ADD r/mc,r64 */
              if modr_m[mod] == 0b11 & 0xf0 == prefixes[lck] then {
                  x86_fault("#UD")
              };
              x86_addc_subc_orc_andc_xorc_e_g(0, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib);
              true
          }
      },
      0x03 => {
          if 0x06 != prefixes[opr] then false else {
              /* ADD rc,r/m64 */
              if modr_m[mod] == 0b11 & 0xf0 == prefixes[lck] then {
                  x86_fault("#UD")
              };
              x86_addc_subc_orc_andc_xorc_g_e(0, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib);
              true
          }
      },
      0x05 => {
          if 0x06 != prefixes[opr] then false else {
              /* ADD CAX,imm32 */
              if 0xf0 == prefixes[lck] then {
                  x86_fault("#UD")
              };
              x86_addc_subc_orc_andc_xorc_cax_i(0, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib);
              true
          }
      },
      0x09 => {
          if 0x06 != prefixes[opr] then false else {
              /* OR r/mc,r64 */
              if modr_m[mod] == 0b11 & 0xf0 == prefixes[lck] then {
                  x86_fault("#UD")
              };
              x86_addc_subc_orc_andc_xorc_e_g(1, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib);
              true
          }
      },
      0x0b => {
          if 0x06 != prefixes[opr] then false else {
              /* OR rc,r/m64 */
              if modr_m[mod] == 0b11 & 0xf0 == prefixes[lck] then {
                  x86_fault("#UD")
              };
              x86_addc_subc_orc_andc_xorc_g_e(1, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib);
              true
          }
      },
      0x0d => {
          if 0x06 != prefixes[opr] then false else {
              /* OR CAX,imm32 */
              if 0xf0 == prefixes[lck] then {
                  x86_fault("#UD")
              };
              x86_addc_subc_orc_andc_xorc_cax_i(1, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib);
              true
          }
      },
      0x21 => {
          if 0x06 != prefixes[opr] then false else {
              /* AND r/mc,r64 */
              if modr_m[mod] == 0b11 & 0xf0 == prefixes[lck] then {
                  x86_fault("#UD")
              };
              x86_addc_subc_orc_andc_xorc_e_g(3, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib);
              true
          }
      },
      0x23 => {
          if 0x06 != prefixes[opr] then false else {
              /* AND rc,r/m64 */
              if modr_m[mod] == 0b11 & 0xf0 == prefixes[lck] then {
                  x86_fault("#UD")
              };
              x86_addc_subc_orc_andc_xorc_g_e(3, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib);
              true
          }
      },
      0x25 => {
          if 0x06 != prefixes[opr] then false else {
              /* AND CAX,imm32 */
              if 0xf0 == prefixes[lck] then {
                  x86_fault("#UD")
              };
              x86_addc_subc_orc_andc_xorc_cax_i(3, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib);
              true
          }
      },
      0x29 => {
          if 0x06 != prefixes[opr] then false else {
              /* SUB r/mc,r64 */
              if modr_m[mod] == 0b11 & 0xf0 == prefixes[lck] then {
                  x86_fault("#UD")
              };
              x86_addc_subc_orc_andc_xorc_e_g(4, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib);
              true
          }
      },
      0x2b => {
          if 0x06 != prefixes[opr] then false else {
              /* SUB rc,r/m64 */
              if modr_m[mod] == 0b11 & 0xf0 == prefixes[lck] then {
                  x86_fault("#UD")
              };
              x86_addc_subc_orc_andc_xorc_g_e(4, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib);
              true
          }
      },
      0x2d => {
          if 0x06 != prefixes[opr] then false else {
              /* SUB CAX,imm32 */
              if 0xf0 == prefixes[lck] then {
                  x86_fault("#UD")
              };
              x86_addc_subc_orc_andc_xorc_cax_i(4, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib);
              true
          }
      },
      0x31 => {
          if 0x06 != prefixes[opr] then false else {
              /* XOR r/mc,r64 */
              if modr_m[mod] == 0b11 & 0xf0 == prefixes[lck] then {
                  x86_fault("#UD")
              };
              x86_addc_subc_orc_andc_xorc_e_g(5, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib);
              true
          }
      },
      0x33 => {
          if 0x06 != prefixes[opr] then false else {
              /* XOR rc,r/m64 */
              if modr_m[mod] == 0b11 & 0xf0 == prefixes[lck] then {
                  x86_fault("#UD")
              };
              x86_addc_subc_orc_andc_xorc_g_e(5, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib);
              true
          }
      },
      0x35 => {
          if 0x06 != prefixes[opr] then false else {
              /* XOR CAX,imm32 */
              if 0xf0 == prefixes[lck] then {
                  x86_fault("#UD")
              };
              x86_addc_subc_orc_andc_xorc_cax_i(5, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib);
              true
          }
      },
      0x81 => {
          if 0x06 != prefixes[opr] then false else {
              if 0xf0 == prefixes[lck] & modr_m[mod] == 0b11 then {
                  x86_fault("#UD")
              };
              match modr_m[reg] {
                /* /0 ADD r/mc,imm32 */
                0b000 => x86_addc_subc_orc_andc_xorc_e_i(0, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib),
                /* /1 OR r/mc,imm32 */
                0b001 => x86_addc_subc_orc_andc_xorc_e_i(1, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib),
                /* /4 AND r/mc,imm32 */
                0b100 => x86_addc_subc_orc_andc_xorc_e_i(3, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib),
                /* /5 SUB r/mc,imm32 */
                0b101 => x86_addc_subc_orc_andc_xorc_e_i(4, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib),
                /* /6 XOR r/mc,imm32 */
                0b110 => x86_addc_subc_orc_andc_xorc_e_i(5, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib),
                _ => x86_fault("#UD")
              };
              true
          }
      },
      0x83 => {
          if 0x06 != prefixes[opr] then false else {
              if 0xf0 == prefixes[lck] & modr_m[mod] == 0b11 then {
                  x86_fault("#UD")
              };
              match modr_m[reg] {
                /* /0 ADD r/mc,imm8 */
                0b000 => x86_addc_subc_orc_andc_xorc_e_i(0, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib),
                /* /1 OR r/mc,imm8 */
                0b001 => x86_addc_subc_orc_andc_xorc_e_i(1, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib),
                /* /4 AND r/mc,imm8 */
                0b100 => x86_addc_subc_orc_andc_xorc_e_i(3, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib),
                /* /5 SUB r/mc,imm8 */
                0b101 => x86_addc_subc_orc_andc_xorc_e_i(4, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib),
                /* /6 XOR r/mc,imm8 */
                0b110 => x86_addc_subc_orc_andc_xorc_e_i(5, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib),
                _ => x86_fault("#UD")
              };
              true
          }
      },
      0x89 => {
          if 0x06 != prefixes[opr] then false else {
              if 0xf0 == prefixes[lck] then {
                  x86_fault("#UD")
              };
              x86_movc_op_en_mr(proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib);
              true
          }
      },
      0x8b => {
          if 0x06 != prefixes[opr] then false else {
              if 0xf0 == prefixes[lck] then {
                  x86_fault("#UD")
              };
              x86_movc_op_en_rm(proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib);
              true
          }
      },
      0x8d => {
          // LEA should never be used with the 07 prefix
          if 0x07 == prefixes[adr] then {
              x86_fault("(:UD)")
          };
          if 0x06 != prefixes[opr] then false else {
              if modr_m[mod] == 0b11 | 0xf0 == prefixes[lck] then {
                  x86_fault("(:UD)")
              };
              x86_leac(proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib);
              true
          }
      },
      0x90 => {
          if 0xf0 == prefixes[lck] then {
              x86_fault("#UD")
          };
          x86_one_byte_nop(proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib);
          true
      },
      0xc7 => {
          if 0x06 != prefixes[opr] then false else {
              if modr_m[reg] == 0b000 then {
                  if 0xf0 == prefixes[lck] then {
                      x86_fault("#UD")
                  };
                  x86_movc_op_en_mi(proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib);
                  true
              } else {
                  x86_fault("#UD")
              }
          }
      },
      m if unsigned(m) >= unsigned(0xa0) & unsigned(m) <= unsigned(0xa3) => {
          if in_capability_mode(proc_mode) | 0x06 == prefixes[opr] |
            0x07 == prefixes[adr] then {
              x86_fault("#UD")
          };
          false
      },
      _ => {
          if 0x06 == prefixes[opr] then {
              x86_fault("#UD")
          };
          false
      }
    }
}
