/* MOVC r/mc, rc */
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

/* MOVC rc, r/mc */
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

/* MOVC rc, imm32 */
val x86_movc_op_en_mi : (proc_mode, sbits(48), sbits(48), prefixes, bits(8), bits(8), modr_m, sib) -> unit

function x86_movc_op_en_mi (proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib) = {
    let r_m : bits(3) = modr_m[r_m];
    let mod_var : bits(2) = modr_m[mod];
    let imm_size = 4;
    let (flg0, addr, increment_rip_by) : (option(string), sbits(64), {|0, 1, 2, 4|}) = {
        if mod_var == 0b11 then {
            (None() : option(string), 0x0000000000000000, 0)
        } else {
            x86_effective_addr(proc_mode, prefixes, temp_rip, rex_byte, r_m, mod_var, sib, bits_of_int(imm_size, 3))
        }
    };
    let increment_rip_by : bits(3) = bits_of_int(increment_rip_by, 3);
    if is_some(flg0) then throw(Emsg("Model state error: :X86-EFFECTIVE-ADDR-ERROR"));
    let seg_reg : seg_reg_idx = select_segment_register(proc_mode, prefixes, mod_var, r_m, sib);
    let (flg, temp_rip) : (option(string), sbits(49)) = add_to_iptr(proc_mode, temp_rip, sail_zero_extend(increment_rip_by, 48));
    let temp_rip : sbits(48) = truncate(temp_rip, 48);
    if is_some(flg) then throw(Emsg("Model state error: :RIP-INCREMENT-ERROR"));
    let (flg2, imm) : (option(string), bits(64)) = rime_size(proc_mode, select_address_size(proc_mode, Some(prefixes)), imm_size, sail_sign_extend(temp_rip, 64), None(), 1, ":X", false, false);
    if is_some(flg2) then throw(Emsg("Model state error: :IMM-RME-SIZE-ERROR"));
    let (flg, temp_rip) : (option(string), sbits(49)) = add_to_iptr(proc_mode, temp_rip, bits_of_int(imm_size, 48));
    let temp_rip : sbits(48) = truncate(temp_rip, 48);
    if is_some(flg) then throw(Emsg("Model state error: :RIP-INCREMENT-ERROR"));
    let badlength? : option(int) = check_instruction_length(start_rip, temp_rip, 0b000);
    if is_some(badlength?) then throw(Emsg("A fault occurred.  Original ACL2 AST: (!!FAULT-FRESH :GP 0 :INSTRUCTION-LENGTH BADLENGTH?)"));
    let cap : Capability = {null_cap with address=imm};
    let flg3 : option (string) = x86_cap_to_reg_mem(proc_mode, false, cap, seg_reg, addr, prefixes, rex_byte, r_m, mod_var, sib);
    if is_some(flg3) then throw(Emsg("Model state error: :X86-CAP-TO-REG/MEM"));
    write_iptr(proc_mode, temp_rip)
}

/* MOVC rc, additional cap reg */
val x86_mov_cap_regs_op_en_mr : (proc_mode, sbits(48), sbits(48), prefixes, bits(8), bits(8), modr_m) -> unit

function x86_mov_cap_regs_op_en_mr (proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m) = {
    let r_m : bits(3) = modr_m[r_m];
    let reg : bits(3) = modr_m[reg];
    let capreg = unsigned(reg_index(reg, rex_byte, 0b10));
    if capreg > 2 then throw(Emsg("A fault occurred.  X86-ILLEGAL-INSTRUCTION \"#UD Encountered!\""));
    let gprreg = unsigned(reg_index(r_m, rex_byte, 0b00));
    write_gpr(gprreg, read_capr(capreg));
    write_iptr(proc_mode, temp_rip)
}

/* MOVC additional cap reg, rc */
val x86_mov_cap_regs_op_en_rm : (proc_mode, sbits(48), sbits(48), prefixes, bits(8), bits(8), modr_m) -> unit

function x86_mov_cap_regs_op_en_rm (proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m) = {
    let r_m : bits(3) = modr_m[r_m];
    let reg : bits(3) = modr_m[reg];
    let capreg = unsigned(reg_index(reg, rex_byte, 0b10));
    if capreg > 2 then throw(Emsg("A fault occurred.  X86-ILLEGAL-INSTRUCTION \"#UD Encountered!\""));
    let gprreg = unsigned(reg_index(r_m, rex_byte, 0b00));
    write_capr(capreg, read_gpr(gprreg));
    write_iptr(proc_mode, temp_rip)
}
