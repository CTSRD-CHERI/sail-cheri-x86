register ddc: Capability

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
    r11 = null_cap;
    r12 = null_cap;
    r13 = null_cap;
    r14 = null_cap;
    r15 = null_cap;

    // CIP and DDC default to an almighty capability
    rip = default_cap;
    ddc = default_cap;
}
