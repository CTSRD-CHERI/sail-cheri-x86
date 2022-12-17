/*=======================================================================================*/
/*  CHERI x86-64 Sail Model                                                              */
/*                                                                                       */
/*  Copyright (c) 2017-2021                                                              */
/*    Prashanth Mundkur                                                                  */
/*    Rishiyur S. Nikhil and Bluespec, Inc.                                              */
/*    Jon French                                                                         */
/*    Brian Campbell                                                                     */
/*    Robert Norton-Wright                                                               */
/*    Alasdair Armstrong                                                                 */
/*    Thomas Bauereiss                                                                   */
/*    Shaked Flur                                                                        */
/*    Christopher Pulte                                                                  */
/*    Peter Sewell                                                                       */
/*    Alexander Richardson                                                               */
/*    Hesham Almatary                                                                    */
/*    Jessica Clarke                                                                     */
/*    Microsoft, for contributions by Robert Norton-Wright and Nathaniel Wesley Filardo  */
/*    Peter Rugg                                                                         */
/*    Aril Computer Corp., for contributions by Scott Johnson                            */
/*                                                                                       */
/*  All rights reserved.                                                                 */
/*                                                                                       */
/*  This software was developed by the above within the Rigorous                         */
/*  Engineering of Mainstream Systems (REMS) project, partly funded by                   */
/*  EPSRC grant EP/K008528/1, at the Universities of Cambridge and                       */
/*  Edinburgh.                                                                           */
/*                                                                                       */
/*  This software was developed by SRI International and the University of               */
/*  Cambridge Computer Laboratory (Department of Computer Science and                    */
/*  Technology) under DARPA/AFRL contract FA8650-18-C-7809 ("CIFV"), and                 */
/*  under DARPA contract HR0011-18-C-0016 ("ECATS") as part of the DARPA                 */
/*  SSITH research programme.                                                            */
/*                                                                                       */
/*  This project has received funding from the European Research Council                 */
/*  (ERC) under the European Union’s Horizon 2020 research and innovation                */
/*  programme (grant agreement 789108, ELVER).                                           */
/*                                                                                       */
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

$include <smt.sail>

val not_bit : bit -> bit

function not_bit(b) = if b == bitone then bitzero else bitone

overload ~ = {not_vec, not_bit}

val "string_of_bits" : forall 'n. bits('n) -> string

function string_of_bit(b: bit) -> string =
  match b {
    bitzero => "0b0",
    bitone => "0b1"
  }

overload BitStr = {string_of_bits, string_of_bit}

val xor_vec = {c: "xor_bits", _: "xor_vec"} : forall 'n. (bits('n), bits('n)) -> bits('n)

overload operator ^ = {xor_vec}

val sub_vec = {c: "sub_bits", _: "sub_vec"} : forall 'n. (bits('n), bits('n)) -> bits('n)

val sub_vec_int = {c: "sub_bits_int", _: "sub_vec_int"} : forall 'n. (bits('n), int) -> bits('n)

overload operator - = {sub_vec, sub_vec_int}

/* The following should get us euclidean modulus, and is compatible with pre and post 0.9 versions of sail */
overload operator % = {emod_int, mod}

val min_int = {ocaml: "min_int", interpreter: "min_int", lem: "min", coq: "min_atom", c: "min_int"} : forall 'x 'y.
  (int('x), int('y)) -> {'z, ('x <= 'y & 'z == 'x) | ('x > 'y & 'z == 'y). int('z)}

val max_int = {ocaml: "max_int", interpreter: "max_int", lem: "max", coq: "max_atom", c: "max_int"} : forall 'x 'y.
  (int('x), int('y)) -> {'z, ('x >= 'y & 'z == 'x) | ('x < 'y & 'z == 'y). int('z)}

overload min = {min_int}

overload max = {max_int}

val EXTS : forall 'n 'm, 'm >= 'n. (implicit('m), bits('n)) -> bits('m)
val EXTZ : forall 'n 'm, 'm >= 'n. (implicit('m), bits('n)) -> bits('m)

function EXTS(m, v) = sail_sign_extend(v, m)
function EXTZ(m, v) = sail_zero_extend(v, m)

val zeros_implicit : forall 'n, 'n >= 0 . implicit('n) -> bits('n)
function zeros_implicit (n) = sail_zeros(n)
overload zeros = {zeros_implicit}

val ones : forall 'n, 'n >= 0 . implicit('n) -> bits('n)
function ones (n) = sail_ones (n)

val bit_to_bool : bit -> bool
function bit_to_bool b = match b {
  bitone  => true,
  bitzero => false
}

val to_bits : forall 'l, 'l >= 0.(atom('l), int) -> bits('l)
function to_bits (l, n) = get_slice_int(l, n, 0)

infix 4 <_s
infix 4 >=_s
infix 4 <_u
infix 4 >=_u
infix 4 <=_u

val operator <_s  : forall 'n, 'n > 0. (bits('n), bits('n)) -> bool
val operator >=_s : forall 'n, 'n > 0. (bits('n), bits('n)) -> bool
val operator <_u  : forall 'n. (bits('n), bits('n)) -> bool
val operator >=_u : forall 'n. (bits('n), bits('n)) -> bool
val operator <=_u : forall 'n. (bits('n), bits('n)) -> bool

function operator <_s  (x, y) = signed(x) < signed(y)
function operator >=_s (x, y) = signed(x) >= signed(y)
function operator <_u  (x, y) = unsigned(x) < unsigned(y)
function operator >=_u (x, y) = unsigned(x) >= unsigned(y)
function operator <=_u (x, y) = unsigned(x) <= unsigned(y)

val MAX : forall 'n, 'n >= 0 . atom('n) -> atom(2 ^ 'n - 1) effect pure
function MAX(n) = pow2(n) - 1

val not = {coq:"negb", _:"not"} : bool -> bool

/* Used by cheri_cap_common */
type xlen       : Int = 64
type xlen_bytes : Int = 8
type xlenbits         = bits(xlen)

/* width of capability in bytes (excluding tag) */
type cap_size : Int = 16
let  cap_size = sizeof(cap_size)
type log2_cap_size : Int = 4
let  log2_cap_size = sizeof(log2_cap_size)
type CapBits = bits(8 * cap_size)
/* width of otype field in bits */
type cap_hperms_width : Int = 12
let  cap_hperms_width = sizeof(cap_hperms_width)
type cap_uperms_width : Int = 4
let  cap_uperms_width = sizeof(cap_uperms_width)
type cap_otype_width : Int = 18
let  cap_otype_width = sizeof(cap_otype_width)
type cap_reserved_width : Int = 2
let  cap_reserved_width = sizeof(cap_reserved_width)
type cap_flags_width : Int = 1
let  cap_flags_width = sizeof(cap_flags_width)
type cap_mantissa_width : Int = 14
let  cap_mantissa_width = sizeof(cap_mantissa_width)
type cap_E_width : Int = 6
let  cap_E_width = sizeof(cap_E_width)
type cap_addr_width : Int = 64
let  cap_addr_width = sizeof(cap_addr_width)
type cap_len_width : Int = cap_addr_width + 1
let  cap_len_width = sizeof(cap_len_width)

/* For CLoadTags and CClearTags, which operate at cache line granularity */
type caps_per_cache_line : Int = 4
let  caps_per_cache_line = sizeof(caps_per_cache_line)

type internal_E_take_bits : Int = 3
let  internal_E_take_bits = sizeof(internal_E_take_bits)

/* Capability format completely compressed. Tag is out of band */
struct EncCapability = {
  perms      : bits(cap_uperms_width + cap_hperms_width),
  otype      : bits(cap_otype_width),
  reserved   : bits(cap_reserved_width),
  flags      : bits(cap_flags_width),
  internal_E : bit,
  T          : bits(cap_mantissa_width - 2),
  B          : bits(cap_mantissa_width),
  address    : bits(cap_addr_width)
}

function capBitsToEncCapability(c) : CapBits -> EncCapability = struct {
  perms      = c[127..112],
  reserved   = c[111..110],
  flags      = c[109..109],
  otype      = c[108..91],
  internal_E = c[90],
  T          = c[89..78],
  B          = c[77..64],
  address    = c[63..0]
}

function encCapToBits(cap) : EncCapability -> CapBits =
  cap.perms @
  cap.reserved @
  cap.flags @
  cap.otype @
  [cap.internal_E] @
  cap.T @
  cap.B @
  cap.address
