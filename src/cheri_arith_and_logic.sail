/*! Operand Fetch and Execute for ADD, SUB, OR, AND,
 XOR: Addressing Mode = ( E, G )
<h3>Op/En = MR: [OP R/M, REG] or [OP E, G]</h3> 
 
 <p>where @ ( ' E ' ) is the destination operand and @ ( ' G ' ) is the source 
 operand. Note that @ ( ' E ' ) stands for a general-purpose register or 
 memory operand specified by the @ ( ' ModRM.r/m ' ) field, and @ ( ' G ' ) 
 stands for a general-purpose register specified by the 
 @ ( ' ModRM.reg ' ) field.</p> 
 
 [OP R/M, REG] Flags Affected<br/> 
 01: ADD c p a z s o<br/> 
 09: OR p z s ( o and c cleared, a undefined ) <br/> 
 21: AND p z s ( o and c cleared, a undefined ) <br/> 
 29: SUB c p a z s o<br/> 
 31: XOR p z s ( o and c cleared, a undefined ) <br/> */
val x86_addc_subc_orc_andc_xorc_e_g : (range(0, 8), proc_mode, sbits(48), sbits(48), prefixes, bits(8), bits(8), modr_m, sib) -> unit

function x86_addc_subc_orc_andc_xorc_e_g (operation, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib) = {
    let r_m : bits(3) = modr_m[r_m];
    let mod_var : bits(2) = modr_m[mod];
    let reg : bits(3) = modr_m[reg];
    let operand_size = 8;
    let g : bits(64) = rgfi_size(bits_of_int(operand_size, 4), reg_index(reg, rex_byte, 0b10), rex_byte);
    let seg_reg : seg_reg_idx = select_segment_register(proc_mode, prefixes, mod_var, r_m, sib);
    let (e, increment_rip_by, e_addr) : (Capability, {|0, 1, 2, 4|}, sbits(64)) = x86_cap_from_modr_m_and_sib_bytes(proc_mode, false, seg_reg, prefixes, temp_rip, rex_byte, r_m, mod_var, sib, 0b000);
    let increment_rip_by : bits(3) = bits_of_int(increment_rip_by, 3);
    let temp_rip : sbits(48) = add_to_iptr(proc_mode, temp_rip, sail_zero_extend(increment_rip_by, 48));
    let badlength? : option(int) = check_instruction_length(start_rip, temp_rip, 0b000);
    if is_some(badlength?) then x86_fault("(!!FAULT-FRESH :GP 0 :INSTRUCTION-LENGTH BADLENGTH?)");
    let input_rflags : rflagsbits = rflags;
    let (result_addr, output_rflags, undefined_flags) : (bits(64), rflagsbits, rflagsbits) = gpr_arith_logic_spec(operand_size, operation, e.address, g, input_rflags);
    let (representable, result) = setCapAddr(e, result_addr);
    let result = clearTagIf(result, not_bool(representable));
    x86_cap_to_reg_mem(proc_mode, false, result, seg_reg, e_addr, prefixes,
      rex_byte, r_m, mod_var, sib);
    write_user_rflags(output_rflags, undefined_flags);
    write_iptr(proc_mode, temp_rip)
}

/*! Operand Fetch and Execute for ADD, SUB, OR, AND,
 XOR: Addressing Mode = ( G, E )
<h3>Op/En = RM: [OP REG, R/M] or [OP G, E]</h3> 
 
 <p>where @ ( ' G ' ) is the destination operand and @ ( ' E ' ) is the source 
 operand. Note that @ ( ' G ' ) stands for a general-purpose register 
 specified by the @ ( ' ModRM.reg ' ) field, and @ ( ' E ' ) stands for a 
 general-purpose register or memory operand specified by the 
 @ ( ' ModRM.r/m ' ) field.</p> 
 
 [OP REG, R/M] Flags Affected<br/> 
 03: ADD c p a z s o<br/> 
 0B: OR p z s ( o and c cleared, a undefined ) <br/> 
 23: AND p z s ( o and c cleared, a undefined ) <br/> 
 2B: SUB c p a z s o<br/> 
 33: XOR p z s ( o and c cleared, a undefined ) <br/> */
val x86_addc_subc_orc_andc_xorc_g_e : (range(0, 8), proc_mode, sbits(48), sbits(48), prefixes, bits(8), bits(8), modr_m, sib) -> unit

function x86_addc_subc_orc_andc_xorc_g_e (operation, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib) = {
    let r_m : bits(3) = modr_m[r_m];
    let mod_var : bits(2) = modr_m[mod];
    let reg : bits(3) = modr_m[reg];
    let operand_size = 8;
    let g : Capability = read_gpr(unsigned(reg_index(reg, rex_byte, 0b10)));
    let seg_reg : seg_reg_idx = select_segment_register(proc_mode, prefixes, mod_var, r_m, sib);
    let inst_ac? : bool = true;
    let (e, increment_rip_by, e_addr) : (bits(128), {|0, 1, 2, 4|}, sbits(64)) = x86_operand_from_modr_m_and_sib_bytes(proc_mode, 0b0, operand_size, inst_ac?, false, seg_reg, prefixes, temp_rip, rex_byte, r_m, mod_var, sib, 0b000);
    let increment_rip_by : bits(3) = bits_of_int(increment_rip_by, 3);
    let temp_rip : sbits(48) = add_to_iptr(proc_mode, temp_rip, sail_zero_extend(increment_rip_by, 48));
    let badlength? : option(int) = check_instruction_length(start_rip, temp_rip, 0b000);
    if is_some(badlength?) then x86_fault("(!!FAULT-FRESH :GP 0 :INSTRUCTION-LENGTH BADLENGTH?)");
    let input_rflags : rflagsbits = rflags;
    let (result_addr, output_rflags, undefined_flags) : (bits(64), rflagsbits, rflagsbits) = gpr_arith_logic_spec(operand_size, operation, g.address, truncate(e, 64), input_rflags);
    let (representable, result) = setCapAddr(g, result_addr);
    let result = clearTagIf(result, not_bool(representable));
    write_gpr(unsigned(reg_index(reg, rex_byte, 0b10)), result);
    write_user_rflags(output_rflags, undefined_flags);
    write_iptr(proc_mode, temp_rip)
}

/*! Operand Fetch and Execute for ADD, SUB, OR, AND, 
 XOR: Addressing Mode = ( E, I )
<h3>Op/En = MI: [OP R/M, IMM] or [OP E, I]</h3> 
 
 <p>where @ ( ' E ' ) is the destination operand and @ ( ' I ' ) is the source 
 operand. Note that @ ( ' E ' ) stands for a general-purpose register or 
 memory operand specified by the @ ( ' ModRM.r/m ' ) field, and @ ( ' I ' ) 
 stands for immediate data. All opcodes except those of TEST fall 
 under Group 1, and have opcode extensions ( ModR/M.reg field ) , as 
 per Table A-6 of the Intel Manuals, Vol. 2. The opcodes for TEST 
 fall under Unary Group 3, and also have opcode extensions.</p> 
 
 [OP R/M, IMM] Flags Affected<br/> 
 81,83 ( 000 ) : ADD c p a z s o<br/> 
 81,83 ( 001 ) : OR p z s ( o and c cleared, a undefined ) <br/> 
 81,83 ( 100 ) : AND p z s ( o and c cleared, a undefined ) <br/> 
 81,83 ( 101 ) : SUB c p a z s o<br/> 
 81,83 ( 110 ) : XOR p z s ( o and c cleared, a undefined ) <br/> */
val x86_addc_subc_orc_andc_xorc_e_i : (range(0, 8), proc_mode, sbits(48), sbits(48), prefixes, bits(8), bits(8), modr_m, sib) -> unit

function x86_addc_subc_orc_andc_xorc_e_i (operation, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib) = {
    let r_m : bits(3) = modr_m[r_m];
    let mod_var : bits(2) = modr_m[mod];
    let reg : bits(3) = modr_m[reg];
    let e_size = 8;
    let imm_size : {|1, 4|} = { if opcode == 0x83 then 1 else 4 };
    let seg_reg : seg_reg_idx = select_segment_register(proc_mode, prefixes, mod_var, r_m, sib);
    let (e, increment_rip_by, e_addr) : (Capability, {|0, 1, 2, 4|}, sbits(64)) = x86_cap_from_modr_m_and_sib_bytes(proc_mode, false, seg_reg, prefixes, temp_rip, rex_byte, r_m, mod_var, sib, bits_of_int(imm_size, 3));
    let temp_rip : sbits(48) = add_to_iptr(proc_mode, temp_rip, bits_of_int(increment_rip_by, 48));
    let imm : bits(128) = rme_size(proc_mode, select_address_size(proc_mode, Some(prefixes)), imm_size, sail_sign_extend(temp_rip, 64), None(), 1, ":X", false, false);
    let imm : bits(32) = truncate(imm, 32);
    let imm : int = loghead(ash(e_size, 3), binary_logext(ash(imm_size, 3), unsigned(imm)));
    let temp_rip : sbits(48) = add_to_iptr(proc_mode, temp_rip, bits_of_int(imm_size, 48));
    let badlength? : option(int) = check_instruction_length(start_rip, temp_rip, 0b000);
    if is_some(badlength?) then x86_fault("(!!FAULT-FRESH :GP 0 :INSTRUCTION-LENGTH BADLENGTH?)");
    let input_rflags : rflagsbits = rflags;
    let (result_addr, output_rflags, undefined_flags) : (bits(64), rflagsbits, rflagsbits) = gpr_arith_logic_spec(e_size, operation, e.address, bits_of_int(imm, 64), input_rflags);
    let (representable, result) = setCapAddr(e, result_addr);
    let result = clearTagIf(result, not_bool(representable));
    x86_cap_to_reg_mem(proc_mode, false, result, seg_reg, e_addr, prefixes,
      rex_byte, r_m, mod_var, sib);
    write_user_rflags(output_rflags, undefined_flags);
    write_iptr(proc_mode, truncate(temp_rip, 48))
}

/*! Operand Fetch and Execute for ADD, SUB, OR, AND,
 XOR: Addressing Mode = ( CAX, I )
<h3>Op/En = I: [OP CAX, IMM] or [OP CAX, I]</h3> 
 
 <p>where @ ( ' CAX ' ) is the destination operand and @ ( ' I ' ) is the 
 source operand. Note that @ ( ' I ' ) stands for immediate 
 data.</p> 
 
 [OP rAX, IMM] Flags Affected<br/> 
 05: ADD c p a z s o<br/> 
 0D: OR p z s ( o and c cleared, a undefined ) <br/> 
 25: AND p z s ( o and c cleared, a undefined ) <br/> 
 2D: SUB c p a z s o<br/> 
 35: XOR p z s ( o and c cleared, a undefined ) <br/> */
val x86_addc_subc_orc_andc_xorc_cax_i : (range(0, 8), proc_mode, sbits(48), sbits(48), prefixes, bits(8), bits(8), modr_m, sib) -> unit

function x86_addc_subc_orc_andc_xorc_cax_i (operation, proc_mode, start_rip, temp_rip, prefixes, rex_byte, opcode, modr_m, sib) = {
    let operand_size  = 4;
    let cax_var = read_gpr(0);
    let imm : bits(128) = rme_size(proc_mode, select_address_size(proc_mode, Some(prefixes)), operand_size, sail_sign_extend(temp_rip, 64), None(), 1, ":X", false, false);
    let imm : bits(64) = sail_sign_extend(truncate(imm, 32), 64);
    let temp_rip : sbits(48) = add_to_iptr(proc_mode, temp_rip, bits_of_int(operand_size, 48));
    let badlength? : option(int) = check_instruction_length(start_rip, temp_rip, 0b000);
    if is_some(badlength?) then x86_fault("(!!FAULT-FRESH :GP 0 :INSTRUCTION-LENGTH BADLENGTH?)");
    let input_rflags : rflagsbits = rflags;
    let (result_addr, output_rflags, undefined_flags) : (bits(64), rflagsbits, rflagsbits) = gpr_arith_logic_spec(8, operation, cax_var.address, imm, input_rflags);
    let (representable, result) = setCapAddr(cax_var, result_addr);
    let result = clearTagIf(result, not_bool(representable));
    write_gpr(0, result);
    write_user_rflags(output_rflags, undefined_flags);
    write_iptr(proc_mode, truncate(temp_rip, 48))
}
