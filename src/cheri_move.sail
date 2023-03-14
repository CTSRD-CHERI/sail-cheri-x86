/* MOVC r/mc, rc */
val x86_movc_op_en_mr : (proc_mode, sbits(48), sbits(48), prefixes, bits(8), bits(8), modr_m, sib) -> unit

function x86_movc_op_en_mr (proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib) = {
    let r_m : bits(3) = modr_m[r_m];
    let mod_var : bits(2) = modr_m[mod];
    let reg : bits(3) = modr_m[reg];
    let register_var : Capability = read_gpr(unsigned(reg_index(reg, rex_byte, 0b10)));
    let (addr, increment_rip_by) : (sbits(64), {|0, 1, 2, 4|}) = {
        if mod_var == 0b11 then {
            (0x0000000000000000, 0)
        } else {
            x86_effective_addr(proc_mode, prefixes, temp_rip, rex_byte, r_m, mod_var, sib, 0b000)
        }
    };
    let increment_rip_by : bits(3) = bits_of_int(increment_rip_by, 3);
    let seg_reg : seg_reg_idx = select_segment_register(proc_mode, prefixes, mod_var, r_m, sib);
    let temp_rip : sbits(48) = add_to_iptr(proc_mode, temp_rip, sail_zero_extend(increment_rip_by, 48));
    let badlength? : option(int) = check_instruction_length(start_rip, temp_rip, 0b000);
    if is_some(badlength?) then x86_fault("(!!FAULT-FRESH :GP 0 :INSTRUCTION-LENGTH BADLENGTH?)");
    x86_cap_to_reg_mem(proc_mode, false, register_var, seg_reg, addr, prefixes, rex_byte, r_m, mod_var, sib);
    write_iptr(proc_mode, temp_rip)
}

/* MOVC rc, r/mc */
val x86_movc_op_en_rm : (proc_mode, sbits(48), sbits(48), prefixes, bits(8), bits(8), modr_m, sib) -> unit

function x86_movc_op_en_rm (proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib) = {
    let r_m : bits(3) = modr_m[r_m];
    let mod_var : bits(2) = modr_m[mod];
    let reg : bits(3) = modr_m[reg];
    let seg_reg : seg_reg_idx = select_segment_register(proc_mode, prefixes, mod_var, r_m, sib);
    let (reg_mem, increment_rip_by, addr) : (Capability, {|0, 1, 2, 4|}, sbits(64)) = x86_cap_from_modr_m_and_sib_bytes(proc_mode, false, seg_reg, prefixes, temp_rip, rex_byte, r_m, mod_var, sib, 0b000);
    let increment_rip_by : bits(3) = bits_of_int(increment_rip_by, 3);
    let temp_rip : sbits(48) = add_to_iptr(proc_mode, temp_rip, sail_zero_extend(increment_rip_by, 48));
    let badlength? : option(int) = check_instruction_length(start_rip, temp_rip, 0b000);
    if is_some(badlength?) then x86_fault("(!!FAULT-FRESH :GP 0 :INSTRUCTION-LENGTH BADLENGTH?)");
    write_gpr(unsigned(reg_index(reg, rex_byte, 0b10)), reg_mem);
    write_iptr(proc_mode, temp_rip)
}

/* MOVC rc, imm32 */
val x86_movc_op_en_mi : (proc_mode, sbits(48), sbits(48), prefixes, bits(8), bits(8), modr_m, sib) -> unit

function x86_movc_op_en_mi (proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib) = {
    let r_m : bits(3) = modr_m[r_m];
    let mod_var : bits(2) = modr_m[mod];
    let imm_size = 4;
    let (addr, increment_rip_by) : (sbits(64), {|0, 1, 2, 4|}) = {
        if mod_var == 0b11 then {
            (0x0000000000000000, 0)
        } else {
            x86_effective_addr(proc_mode, prefixes, temp_rip, rex_byte, r_m, mod_var, sib, bits_of_int(imm_size, 3))
        }
    };
    let increment_rip_by : bits(3) = bits_of_int(increment_rip_by, 3);
    let seg_reg : seg_reg_idx = select_segment_register(proc_mode, prefixes, mod_var, r_m, sib);
    let temp_rip : sbits(48) = add_to_iptr(proc_mode, temp_rip, sail_zero_extend(increment_rip_by, 48));
    let imm : bits(64) = rime_size(proc_mode, select_address_size(proc_mode, Some(prefixes)), imm_size, sail_sign_extend(temp_rip, 64), None(), 1, ":X", false, false);
    let temp_rip : sbits(48) = add_to_iptr(proc_mode, temp_rip, bits_of_int(imm_size, 48));
    let badlength? : option(int) = check_instruction_length(start_rip, temp_rip, 0b000);
    if is_some(badlength?) then x86_fault("(!!FAULT-FRESH :GP 0 :INSTRUCTION-LENGTH BADLENGTH?)");
    let cap : Capability = {null_cap with address=imm};
    x86_cap_to_reg_mem(proc_mode, false, cap, seg_reg, addr, prefixes, rex_byte, r_m, mod_var, sib);
    write_iptr(proc_mode, temp_rip)
}

/* MOVC rc, additional cap reg */
val x86_mov_cap_regs_op_en_mr : (proc_mode, sbits(48), sbits(48), prefixes, bits(8), bits(8), modr_m) -> unit

function x86_mov_cap_regs_op_en_mr (proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m) = {
    let r_m : bits(3) = modr_m[r_m];
    let reg : bits(3) = modr_m[reg];
    let capreg = unsigned(reg_index(reg, rex_byte, 0b10));
    let gprreg = unsigned(reg_index(r_m, rex_byte, 0b00));
    if capreg > 2 then {
        x86_fault("#UD")
    } else {
        write_gpr(gprreg, read_capr(capreg))
    };
    write_iptr(proc_mode, temp_rip)
}

/* MOVC additional cap reg, rc */
val x86_mov_cap_regs_op_en_rm : (proc_mode, sbits(48), sbits(48), prefixes, bits(8), bits(8), modr_m) -> unit

function x86_mov_cap_regs_op_en_rm (proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m) = {
    let r_m : bits(3) = modr_m[r_m];
    let reg : bits(3) = modr_m[reg];
    let capreg = unsigned(reg_index(reg, rex_byte, 0b10));
    let gprreg = unsigned(reg_index(r_m, rex_byte, 0b00));
    if capreg > 2 then {
        x86_fault("#UD")
    } else {
        write_capr(capreg, read_gpr(gprreg))
    };
    write_iptr(proc_mode, temp_rip)
}

/* LEAC rc, ea */
val x86_leac : (proc_mode, sbits(48), sbits(48), prefixes, bits(8), bits(8), modr_m, sib) -> unit

function x86_leac (proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib) = {
    let r_m : bits(3) = modr_m[r_m];
    let mod_var : bits(2) = modr_m[mod];
    let reg : bits(3) = modr_m[reg];
    let (m, increment_rip_by) : (sbits(64), {|0, 1, 2, 4|}) = x86_effective_addr(proc_mode, prefixes, temp_rip, rex_byte, r_m, mod_var, sib, 0b000);
    let increment_rip_by : bits(3) = bits_of_int(increment_rip_by, 3);
    let temp_rip : sbits(48) = add_to_iptr(proc_mode, temp_rip, sail_zero_extend(increment_rip_by, 48));
    let badlength? : option(int) = check_instruction_length(start_rip, temp_rip, 0b000);
    if is_some(badlength?) then x86_fault("(!!FAULT-FRESH :GP 0 :INSTRUCTION-LENGTH BADLENGTH?)");
    let base_reg = select_base_register(proc_mode, rex_byte, r_m, mod_var, sib);
    let seg_reg : seg_reg_idx = select_segment_register(proc_mode, prefixes, mod_var, r_m, sib);
    let cap = cap_base_reg(cap_reg_index(16, base_reg, seg_reg, ":R"));
    let (representable, cap) = setCapAddr(cap, m);
    let cap = clearTagIf(cap, not_bool(representable));
    write_gpr(unsigned(reg_index(reg, rex_byte, 0b10)), cap);
    write_iptr(proc_mode, temp_rip)
}
