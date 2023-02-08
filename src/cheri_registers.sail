register ddc: Capability
register cfs: Capability
register cgs: Capability

val __InitConfig : unit -> unit
function __InitConfig () = {
    // Default GPRs to a null capability
    rax = null_cap;
    rbx = null_cap;
    rcx = null_cap;
    rdx = null_cap;
    rsi = null_cap;
    rdi = null_cap;
    rsp = null_cap;
    rbp = null_cap;
    r8 = null_cap;
    r9 = null_cap;
    r10 = null_cap;
    r11 = null_cap;
    r12 = null_cap;
    r13 = null_cap;
    r14 = null_cap;
    r15 = null_cap;

    // CIP and DDC default to an almighty capability
    rip = default_cap;
    ddc = default_cap;

    // CFS and CGS default to a null capability
    cfs = null_cap;
    cgs = null_cap;
}

function clause __SetConfig("cax_test", value) = {
    let newBase : CapAddrBits = sail_zero_extend(0x8000, 64);
    let newTop : CapLenBits = 0b0 @ add_bits_int(newBase, unsigned(0x1000));
    let (_, cap) = setCapBounds(default_cap, newBase, newTop);
    write_gpr(0, {cap with permit_execute = false});
}
