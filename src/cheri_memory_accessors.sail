$ifndef __X86_MEMORY_ACCESSORS
$define __X86_MEMORY_ACCESSORS

$include "../sail-x86/model/structures.sail"
$include "../sail-x86/model/segmentation_structures.sail"
$include "../sail-x86/model/linear_memory.sail"
$include "../sail-x86/model/segmentation.sail"

type address_size = {|2, 4, 8, 16|}
type moffset_size = {|2, 4, 8|}
// 0-15 : GPRs, 16 : CIP, 17: DDC, 18: CFS, 19: CGS
type base_reg_idx = range(0, 19)
type seg_reg_idx = range(0, 5)

val cap_reg_index : (address_size, option(base_reg_idx), seg_reg_idx, string) -> base_reg_idx

function cap_reg_index (addr_size, base_reg, seg_reg, access_kind) = {
    if access_kind == ":X" then 16
    else if addr_size == 16 then {
       match seg_reg {
         4 => 18, // CFS
         5 => 19, // CGS
         _ => match base_reg {
           Some(reg) => reg,
           // MOV A0-A3 may get here and should use DDC
           None() => 17
         }
       }
    } else 17
}

val cap_base_reg : (base_reg_idx) -> Capability

function cap_base_reg (base_reg) = {
    match base_reg {
      16 => rip,
      17 => ddc,
      18 => cfs,
      19 => cgs,
      _ => read_gpr(check_range(0, 15, base_reg))
    }
}

val check_linear_memory_access : (proc_mode, address_size, {|1, 2, 4, 6, 8, 10, 16|}, sbits(64), option(base_reg_idx), seg_reg_idx, string, bool, bool, bool) -> bool

function check_linear_memory_access (proc_mode, addr_size, nbytes, lin_addr, base_reg, seg_reg, access_kind, check_alignment?, mem_ptr?, check_sc?) = {
    let cap = cap_base_reg (cap_reg_index(addr_size, base_reg, seg_reg, access_kind));
    if not_bool(cap.tag) then x86_fault("#CP:INVALID-CAP");
    if isCapSealed(cap) then x86_fault("#CP:SEALED-CAP");
    if access_kind == ":R" then {
        if not_bool(cap.permit_load) then x86_fault("#CP:CAP-PERM-READ");
    } else if access_kind == ":W" then {
        if not_bool(cap.permit_store) then x86_fault("#CP:CAP-PERM-WRITE");
        if check_sc? & not_bool(cap.permit_store_cap) then
	    x86_fault("#CP:CAP-PERM-WRITE-CAP");
    } else if access_kind == ":X" then {
        if not_bool(cap.permit_execute) then
	    x86_fault("#CP:CAP-PERM-EXECUTE");
    };
    if not_bool(inCapBounds(cap, lin_addr, nbytes)) then
        x86_fault("#CP:CAP-BOUNDS");
    if not_bool(not_bool(check_alignment?) | address_aligned_p(truncate(lin_addr, 48), nbytes, mem_ptr?)) then
        x86_fault("#AC:UNALIGNED-LINEAR-ADDRESS");
    cap.permit_load_cap
}

// TODO: Move the following functions?

val select_base_register : (proc_mode, bits(8), bits(3), bits(2), sib) -> option(base_reg_idx)

function select_base_register(proc_mode, rex_byte, r_m, mod_var, sib) = {
    if in_64bit_mode(proc_mode) then {
       // Handle RIP-relative addresses
       if mod_var == 0b00 & r_m == 0b101 then Some(16)
       else if r_m == 0b100 then {
           // SIB addresses using absolute displacement always use DDC
           if mod_var == 0b00 & sib[base] == 0b101 then Some(17)
           // Use SIB base register
           else Some(unsigned(reg_index (sib[base], rex_byte, 0b00)))
       // Use R/M base register
       } else Some(unsigned(reg_index (r_m, rex_byte, 0b00)))
    } else None()
}

val select_address_size : (proc_mode, option(prefixes)) -> address_size

function select_address_size (proc_mode, prefixes) = {
    let cappfx? : bool = match prefixes {
         Some(prefixes) => 0x07 == prefixes[adr],
         None() => false
    };
    let p4? : bool = match prefixes {
         Some(prefixes) => 0x67 == prefixes[adr],
         None() => false
    };
    if in_capability_mode(proc_mode) then {
        if cappfx? then 8 else 16
    } else if in_64bit_mode(proc_mode) then {
        if cappfx? then 16
        else if p4? then 4 else 8
    } else {
        let cs_attr : bits(16) = seg_hidden_attrs[1];
        let cs_d : bits(1) = Mk_code_segment_descriptor_attributesbits(cs_attr)[d];
        if cs_d == 0b1 then {
            if p4? then 2 else 4
        } else if p4? then 4 else 2
    }
}

val select_moffset_size : (proc_mode, option(prefixes)) -> moffset_size

function select_moffset_size (proc_mode, prefixes) = {
    let p4? : bool = match prefixes {
         Some(prefixes) => 0x67 == prefixes[adr],
         None() => false
    };
    if in_64bit_mode(proc_mode) then {
        if p4? then 4 else 8
    } else {
        let cs_attr : bits(16) = seg_hidden_attrs[1];
        let cs_d : bits(1) = Mk_code_segment_descriptor_attributesbits(cs_attr)[d];
        if cs_d == 0b1 then {
            if p4? then 2 else 4
        } else if p4? then 4 else 2
    }
}

val select_segment_register : (proc_mode, prefixes, bits(2), bits(3), sib) -> seg_reg_idx

function select_segment_register (proc_mode, prefixes, mod_var, r_m, sib) = {
    match prefixes[seg] {
      46 => 1,
      54 => 2,
      62 => 3,
      38 => 0,
      100 => 4,
      101 => 5,
      _ => {
          let addr_size : {|2, 4, 8, 16|} = select_address_size(proc_mode, Some(prefixes));
          if addr_size == 2 then {
              if not_bool(mod_var == 0b11) & (r_m == 0b010 | r_m == 0b011) then 2 else 3
          } else if (mod_var == 0b01 | mod_var == 0b10) & r_m == 0b101 | not_bool(mod_var == 0b11) & r_m == 0b100 & sib[base] == 0b100 then 2 else 3
      }
    }
}

val load_bytes_from_ea : forall 'nbytes, 'nbytes in {1, 2, 4, 6, 8, 10, 16}.
  (proc_mode, address_size, int('nbytes), sbits(64), option(base_reg_idx), seg_reg_idx, string, bool, bool) -> bits(8 * 'nbytes)

function load_bytes_from_ea (proc_mode, addr_size, nbytes, eff_addr, base_reg, seg_reg, r_x, check_alignment?, mem_ptr?) = {
    let cs_attrs = Mk_code_segment_descriptor_attributesbits(seg_hidden_attrs[1]);
    if not_bool(in_64bit_mode(proc_mode)) & seg_reg == 1 & r_x == ":R" & cs_attrs[r] == 0b0 then {
        x86_fault(":EXECUTE-ONLY-CODE-SEGMENT")
    } else {
        let vaddr : sbits(64) = ea_to_la(proc_mode, eff_addr, seg_reg, nbytes);
        let load_cap? = check_linear_memory_access(proc_mode, addr_size,
	  nbytes, vaddr, base_reg, seg_reg, r_x, check_alignment?, mem_ptr?,
	  false);
        // Use rb directly instead of rml_size;  it returns a
        // bitvector of the right width and performs the same
        // checks for canonical addresses that rml_size does.
        rb(nbytes, vaddr, r_x)
    }
}

val store_bytes_to_ea : forall 'nbytes, 'nbytes in {1, 2, 4, 6, 8, 10, 16}.
  (proc_mode, address_size, int('nbytes), sbits(64), option(base_reg_idx), seg_reg_idx, bits(8 * 'nbytes), bool, bool) -> unit

function store_bytes_to_ea (proc_mode, addr_size, nbytes, eff_addr, base_reg, seg_reg, data, check_alignment?, mem_ptr?) = {
    let seg_attrs = Mk_data_segment_descriptor_attributesbits(seg_hidden_attrs[seg_reg]);
    if not_bool(in_64bit_mode(proc_mode)) & (seg_reg == 1 | seg_attrs[w] == 0b0) then {
        x86_fault(":NON-WRITABLE-SEGMENT")
    } else {
        let vaddr : sbits(64) = ea_to_la(proc_mode, eff_addr, seg_reg, nbytes);
        let load_cap? = check_linear_memory_access(proc_mode, addr_size,
	  nbytes, vaddr, base_reg, seg_reg, ":W", check_alignment?, mem_ptr?,
	  false);
        wb(nbytes, vaddr, ":W", data)
    }
}

/* Clear tags for non-capability memory writes. */

function observe_mem_write (addr, len) = {
    assert(len <= cap_size);

    write_tag_lin_addr(addr, false);

    /* If the write spans a second capability, clear that tag as well. */
    let vaddr = sail_mask_signed(52, addr);
    let tag_vaddr = addr_to_tag_addr(vaddr);
    let tag_vaddr2 = addr_to_tag_addr(vaddr + len - 1);
    if tag_vaddr2 != tag_vaddr2 then {
        write_tag_lin_addr(addr + len - 1, false);
    }
}

val rmecap : (proc_mode, address_size, sbits(64), option(base_reg_idx),
  seg_reg_idx, bool) -> Capability

function rmecap (proc_mode, addr_size, eff_addr, base_reg, seg_reg, mem_ptr?) = {
    assert(in_64bit_mode(proc_mode));
    let vaddr : sbits(64) = ea_to_la(proc_mode, eff_addr, seg_reg, 16);
    let load_cap? = check_linear_memory_access(proc_mode, addr_size,
	cap_size, vaddr, base_reg, seg_reg, ":R", true, mem_ptr?, false);
    let cap = rcap(vaddr);
    if not_bool(load_cap?) then {
       {cap with tag = false}
    } else {
       cap
    }
}

val wmecap : (proc_mode, address_size, sbits(64), option(base_reg_idx),
  seg_reg_idx, Capability, bool) -> unit

function wmecap (proc_mode, addr_size, eff_addr, base_reg, seg_reg, data,
  mem_ptr?) = {
    assert(in_64bit_mode(proc_mode));
    let vaddr : sbits(64) = ea_to_la(proc_mode, eff_addr, seg_reg, 16);
    let load_cap? = check_linear_memory_access(proc_mode, addr_size, cap_size,
	vaddr, base_reg, seg_reg, ":W", true, mem_ptr?, data.tag);
    wcap (vaddr, data)
}

$endif
