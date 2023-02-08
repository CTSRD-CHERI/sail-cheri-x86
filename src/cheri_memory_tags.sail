/*=======================================================================================*/
/*  CHERI x86-64 Sail Model                                                              */
/*                                                                                       */
/*  Copyright (c) 2017-2021                                                              */
/*    Alasdair Armstrong                                                                 */
/*    Thomas Bauereiss                                                                   */
/*    Brian Campbell                                                                     */
/*    Jessica Clarke                                                                     */
/*    Nathaniel Wesley Filardo (contributions prior to July 2020, thereafter Microsoft)  */
/*    Alexandre Joannou                                                                  */
/*    Microsoft                                                                          */
/*    Prashanth Mundkur                                                                  */
/*    Robert Norton-Wright (contributions prior to March 2020, thereafter Microsoft)     */
/*    Alexander Richardson                                                               */
/*    Peter Rugg                                                                         */
/*    Peter Sewell                                                                       */
/*                                                                                       */
/*  All rights reserved.                                                                 */
/*                                                                                       */
/*  This software was developed by SRI International and the University of               */
/*  Cambridge Computer Laboratory (Department of Computer Science and                    */
/*  Technology) under DARPA/AFRL contract FA8650-18-C-7809 ("CIFV"), and                 */
/*  under DARPA contract HR0011-18-C-0016 ("ECATS") as part of the DARPA                 */
/*  SSITH research programme.                                                            */
/*                                                                                       */
/*  This software was developed within the Rigorous Engineering of                       */
/*  Mainstream Systems (REMS) project, partly funded by EPSRC grant                      */
/*  EP/K008528/1, at the Universities of Cambridge and Edinburgh.                        */
/*                                                                                       */
/*  This project has received funding from the European Research Council                 */
/*  (ERC) under the European Union’s Horizon 2020 research and innovation                */
/*  programme (grant agreement 789108, ELVER).                                           */
/*                                                                                       */
/*  Redistribution and use in source and binary forms, with or without                   */
/*  modification, are permitted provided that the following conditions                   */
/*  are met:                                                                             */
/*  1. Redistributions of source code must retain the above copyright                    */
/*     notice, this list of conditions and the following disclaimer.                     */
/*  2. Redistributions in binary form must reproduce the above copyright                 */
/*     notice, this list of conditions and the following disclaimer in                   */
/*     the documentation and/or other materials provided with the                        */
/*     distribution.                                                                     */
/*                                                                                       */
/*  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''                   */
/*  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED                    */
/*  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A                      */
/*  PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR                  */
/*  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,                         */
/*  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT                     */
/*  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF                     */
/*  USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND                  */
/*  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,                   */
/*  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT                   */
/*  OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF                   */
/*  SUCH DAMAGE.                                                                         */
/*=======================================================================================*/

/* Logging hooks */
val log_memtag_read : (bits(52), bool) -> unit
val log_memtag_write : (bits(52), bool) -> unit

/* address LSB truncation/extension */
type tagaddrbits = bits(52 - log2_cap_size)
function addr_to_tag_addr(addr : bits(52)) -> tagaddrbits = truncateLSB(addr, 52 - log2_cap_size)
function tag_addr_to_addr(tag_addr : tagaddrbits) -> bits(52) = tag_addr @ zeros(log2_cap_size)

val write_tag_lin_addr : (bits(48), bool) -> unit

function write_tag_lin_addr (lin_addr, tag) = {
    let phys_addr : bits(52) =
      if app_view then sail_mask_signed(52, lin_addr) else {
        let (flg, phys_addr) = ia32e_la_to_pa(lin_addr, ":W");
        if is_some(flg) then return ();
	phys_addr
      };
    let tag_addr = addr_to_tag_addr(phys_addr);
    MEMw_tag(sail_zero_extend(tag_addr, 64), tag);
    log_memtag_write(tag_addr_to_addr(tag_addr), tag);
}

val address_aligned_p : (sbits(48), {|1, 2, 4, 6, 8, 10, 16, 32, 64|}, bool) -> bool

val rcap : (sbits(64)) -> (option(string), Capability)

function rcap (addr) = {
    if not_bool(canonical_address_p(signed(addr))) then
        return (Some("rcap: non-canonical address"), null_cap);
    let lin_addr : bits(48) = sail_mask_signed(48, addr);
    if not_bool(address_aligned_p(lin_addr, cap_size, false)) then
        return (Some("rcap: misaligned address"), null_cap);
    let phys_addr : bits(52) =
      if app_view then sail_mask_signed(52, lin_addr) else {
        let (flg, phys_addr) = ia32e_la_to_pa(lin_addr, ":R");
        if is_some(flg) then return (flg, null_cap);
        phys_addr
      };
    let cap_bits : CapBits = __read_mem(Read_plain, 64,
      sail_mask(64, phys_addr), cap_size);
    log_memory_read(phys_addr, cap_size, cap_bits);
    let tag_addr = addr_to_tag_addr(phys_addr);
    let tag = MEMr_tag(sail_zero_extend(tag_addr, 64));
    log_memtag_read(tag_addr_to_addr(tag_addr), tag);
    (None(), memBitsToCapability(tag, cap_bits))
}

val wcap : (sbits(64), Capability) -> option(string)

function wcap (addr, cap) = {
    if not_bool(canonical_address_p(signed(addr))) then
        return Some("wcap: non-canonical address");
    let lin_addr : bits(48) = sail_mask_signed(48, addr);
    if not_bool(address_aligned_p(lin_addr, cap_size, false)) then
        return Some("wcap: misaligned address");
    let phys_addr : bits(52) =
      if app_view then sail_mask_signed(52, lin_addr) else {
        let (flg, phys_addr) = ia32e_la_to_pa(lin_addr, ":W");
        if is_some(flg) then return flg;
        phys_addr
      };
    let cap_bits = capToMemBits(cap);
    __write_mem_ea(Write_plain, 64, sail_mask(64, phys_addr), cap_size);
    let dummy = __write_mem(Write_plain, 64, sail_mask(64, phys_addr),
      cap_size, cap_bits);
    log_memory_write(phys_addr, cap_size, cap_bits);
    let tag_addr = addr_to_tag_addr(phys_addr);
    MEMw_tag(sail_zero_extend(tag_addr, 64), cap.tag);
    log_memtag_write(tag_addr_to_addr(tag_addr), cap.tag);
    None()
}
