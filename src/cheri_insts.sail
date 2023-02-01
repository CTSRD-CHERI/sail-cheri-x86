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
