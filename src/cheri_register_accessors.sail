$ifndef __X86_REGISTER_ACCESSORS
$define __X86_REGISTER_ACCESSORS

val rgfi : (int) -> sbits(64) effect {escape, rreg}
function rgfi (regNum) = {
    assert(0 <= regNum & regNum < 16);
    regval_from_reg(read_gpr(regNum))
}

val write_rgfi : (int, sbits(64)) -> unit effect {escape, wreg}
function write_rgfi (regNum, regval_to_write) = {
    assert(0 <= regNum & regNum < 16);
    write_gpr(regNum, regval_into_reg(regval_to_write))
}

val read_rip : unit -> sbits(48)
function read_rip() = truncate(regval_from_reg(rip), 48)

val write_rip : sbits(48) -> unit
function write_rip(value) = {
    let (success, newrip) = setCapAddr(rip, sail_sign_extend(value, 64));
    /* A near branch might very well become unrepresentable, so don't
       assert() success here. */
    rip = newrip;
    if log_register_writes then log_rip_write()
}

type msr_index = range(0, 6)

val read_msr : msr_index -> bits(64)
function read_msr(idx) = {
    match idx {
      1 => regval_from_reg(cfs),
      2 => regval_from_reg(cgs),
      _ => msrs[idx]
    }
}

val write_msr : (msr_index, bits(64)) -> unit
function write_msr(idx, value) = {
    match idx {
      1 => cfs = regval_into_reg(value),
      2 => cgs = regval_into_reg(value),
      _ => msrs[idx] = value
    }
}

$endif
