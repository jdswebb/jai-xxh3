// SPDX-FileCopyrightText: 2024 James Webb
// SPDX-License-Identifier: MIT

// Based on the original C implementation: https://github.com/Cyan4973/xxHash

// It probably makes most sense to set the vector mode based on the CPU at the point of import
#module_parameters ()(ENABLE_ASSERT := false, VECTOR_MODE := XXH3_VECTOR_MODE.AVX2) {
    XXH3_VECTOR_MODE :: enum {
        Scalar;
        SSE2;
        AVX2;
    }
};

#if ENABLE_ASSERT {
    #run print ("XXH3 mode is: %\n", VECTOR_MODE);
}

XXH64_hash :: u64;
XXH128_hash :: struct {
    low64: XXH64_hash;
    high64: XXH64_hash;
};

XXH3_128bits :: (input: *void, len: u64) -> XXH128_hash #no_context
{
    return XXH3_128bits_internal(input, len, 0,
                                 XXH3_kSecret.data, size_of(type_of(XXH3_kSecret)),
                                 XXH3_hashLong_128b_default);
}

XXH3_128bits_withSecret :: (input: *void, len: u64, secret: *void, secretSize: u64) -> XXH128_hash #no_context
{
    return XXH3_128bits_internal(input, len, 0, c_cast(*u8, secret), secretSize, XXH3_hashLong_128b_withSecret);
}

XXH3_128bits_withSeed :: (input: *void, len: u64, seed: XXH64_hash) -> XXH128_hash #no_context
{
    return XXH3_128bits_internal(input, len, seed, XXH3_kSecret.data, size_of(type_of(XXH3_kSecret)), XXH3_hashLong_128b_withSeed);
}

XXH3_128bits_withSecretandSeed :: (input: *void, len: u64, secret: *void, secretSize: u64, seed: XXH64_hash) -> XXH128_hash #no_context
{
    if (len <= XXH3_MIDSIZE_MAX) {
        return XXH3_128bits_internal(input, len, seed, XXH3_kSecret.data, size_of(type_of(XXH3_kSecret)), null);
    }
    return XXH3_hashLong_128b_withSecret(input, len, seed, secret, secretSize);
}

XXH3_64bits :: (input: *void, length: u64) -> XXH64_hash #no_context
{
    return XXH3_64bits_internal(input, length, 0, XXH3_kSecret.data,
                                size_of(type_of(XXH3_kSecret)), XXH3_hashLong_64b_default);
}

XXH3_64bits_withSecret :: (input: *void, length: u64, secret: *void, secretSize: u64) -> XXH64_hash #no_context
{
    return XXH3_64bits_internal(input, length, 0, secret, secretSize, XXH3_hashLong_64b_withSecret);
}

XXH3_64bits_withSeed :: (input: *void, length: u64, seed: u64) -> XXH64_hash #no_context
{
    return XXH3_64bits_internal(input, length, seed, XXH3_kSecret.data, size_of(type_of(XXH3_kSecret)), XXH3_hashLong_64b_withSeed);
}

XXH3_64bits_withSecretandSeed :: (input: *void, length: u64, secret: *void, secretSize: u64, seed: u64) -> XXH64_hash #no_context
{
    if (length <= XXH3_MIDSIZE_MAX) {
        return XXH3_64bits_internal(input, length, seed, XXH3_kSecret.data, size_of(type_of(XXH3_kSecret)), null);
    }
    return XXH3_hashLong_64b_withSecret(input, length, seed, secret, secretSize);
}

#scope_file

XXH_VERSION_MAJOR   :: 0;
XXH_VERSION_MINOR   :: 8;
XXH_VERSION_RELEASE :: 3;
XXH_VERSION_NUMBER :: (XXH_VERSION_MAJOR *100*100 + XXH_VERSION_MINOR *100 + XXH_VERSION_RELEASE);

c_cast :: ($T: Type, from: $U) -> T #expand #no_context
{
    return cast,no_check(T, from);
}

// Jai doesn't support branch prediction hints, maybe it will eventually - dummy function for now
XXH_likely :: (code: Code) -> bool #expand {
    return #insert code;
}

XXH_swap :: byte_swap;

#if VECTOR_MODE == .Scalar {
    XXH_ACC_ALIGN :: 8;
    XXH_SEC_ALIGN :: 8;
} else #if VECTOR_MODE == .SSE2 {
    XXH_ACC_ALIGN :: 16;
    XXH_SEC_ALIGN :: XXH_ACC_ALIGN;
} else #if VECTOR_MODE == .AVX2 {
    XXH_ACC_ALIGN :: 32;
    XXH_SEC_ALIGN :: XXH_ACC_ALIGN;
}

XXH3_SECRET_SIZE_MIN :: 136;
XXH_SECRET_DEFAULT_SIZE :: 192;
XXH3_MIDSIZE_MAX :: 240;
XXH_PREFETCH_DIST :: 320;

XXH_STRIPE_LEN :: 64;
XXH_SECRET_CONSUME_RATE :: 8;
XXH_SECRET_MERGEACCS_START :: 11;
XXH_ACC_NB :: (XXH_STRIPE_LEN / size_of(u64));
#assert(XXH_ACC_NB > 0);

// Assuming LE CPU, just need to byteswap after the copy to support BE so adding it would be trivial
XXH_readLE64 :: XXH_read64;
XXH_readLE32 :: XXH_read32;
XXH_writeLE64 :: XXH_write64;

XXH_PRIME32_1: u32 : 0x9E3779B1;
XXH_PRIME32_2: u32 : 0x85EBCA77;
XXH_PRIME32_3: u32 : 0xC2B2AE3D;
XXH_PRIME32_4: u32 : 0x27D4EB2F;
XXH_PRIME32_5: u32 : 0x165667B1;

XXH_PRIME64_1: u64 : 0x9E3779B185EBCA87;
XXH_PRIME64_2: u64 : 0xC2B2AE3D27D4EB4F;
XXH_PRIME64_3: u64 : 0x165667B19E3779F9;
XXH_PRIME64_4: u64 : 0x85EBCA77C2B2AE63;
XXH_PRIME64_5: u64 : 0x27D4EB2F165667C5;

XXH_PRIME_MX1 :: 0x165667919E3779F9;
XXH_PRIME_MX2 :: 0x9FB21C651E98DF25;

XXH3_INIT_ACC :: u64.[ XXH_PRIME32_3, XXH_PRIME64_1, XXH_PRIME64_2, XXH_PRIME64_3, XXH_PRIME64_4, XXH_PRIME32_2, XXH_PRIME64_5, XXH_PRIME32_1 ] #align 64;
XXH_PRIME32_1_SPLAT_128 :: u32.[XXH_PRIME32_1, XXH_PRIME32_1, XXH_PRIME32_1, XXH_PRIME32_1] #align 64;
XXH_PRIME32_1_SPLAT_256 :: u32.[XXH_PRIME32_1, XXH_PRIME32_1, XXH_PRIME32_1, XXH_PRIME32_1, XXH_PRIME32_1, XXH_PRIME32_1, XXH_PRIME32_1, XXH_PRIME32_1] #align 64;

XXH3_kSecret :: u8.[
    0xb8, 0xfe, 0x6c, 0x39, 0x23, 0xa4, 0x4b, 0xbe, 0x7c, 0x01, 0x81, 0x2c, 0xf7, 0x21, 0xad, 0x1c,
    0xde, 0xd4, 0x6d, 0xe9, 0x83, 0x90, 0x97, 0xdb, 0x72, 0x40, 0xa4, 0xa4, 0xb7, 0xb3, 0x67, 0x1f,
    0xcb, 0x79, 0xe6, 0x4e, 0xcc, 0xc0, 0xe5, 0x78, 0x82, 0x5a, 0xd0, 0x7d, 0xcc, 0xff, 0x72, 0x21,
    0xb8, 0x08, 0x46, 0x74, 0xf7, 0x43, 0x24, 0x8e, 0xe0, 0x35, 0x90, 0xe6, 0x81, 0x3a, 0x26, 0x4c,
    0x3c, 0x28, 0x52, 0xbb, 0x91, 0xc3, 0x00, 0xcb, 0x88, 0xd0, 0x65, 0x8b, 0x1b, 0x53, 0x2e, 0xa3,
    0x71, 0x64, 0x48, 0x97, 0xa2, 0x0d, 0xf9, 0x4e, 0x38, 0x19, 0xef, 0x46, 0xa9, 0xde, 0xac, 0xd8,
    0xa8, 0xfa, 0x76, 0x3f, 0xe3, 0x9c, 0x34, 0x3f, 0xf9, 0xdc, 0xbb, 0xc7, 0xc7, 0x0b, 0x4f, 0x1d,
    0x8a, 0x51, 0xe0, 0x4b, 0xcd, 0xb4, 0x59, 0x31, 0xc8, 0x9f, 0x7e, 0xc9, 0xd9, 0x78, 0x73, 0x64,
    0xea, 0xc5, 0xac, 0x83, 0x34, 0xd3, 0xeb, 0xc3, 0xc5, 0x81, 0xa0, 0xff, 0xfa, 0x13, 0x63, 0xeb,
    0x17, 0x0d, 0xdd, 0x51, 0xb7, 0xf0, 0xda, 0x49, 0xd3, 0x16, 0x55, 0x26, 0x29, 0xd4, 0x68, 0x9e,
    0x2b, 0x16, 0xbe, 0x58, 0x7d, 0x47, 0xa1, 0xfc, 0x8f, 0xf8, 0xb8, 0xd1, 0x7a, 0xd0, 0x31, 0xce,
    0x45, 0xcb, 0x3a, 0x8f, 0x95, 0x16, 0x04, 0x28, 0xaf, 0xd7, 0xfb, 0xca, 0xbb, 0x4b, 0x40, 0x7e,
] #align 64;

#if ENABLE_ASSERT {
    XXH_assert :: (arg: bool, loc := #caller_location) #no_debug #no_context #expand {
        if !arg then debug_break();
    }
} else {
    XXH_assert :: (#discard arg: bool, #discard loc := #caller_location) #no_context #expand {}
}

XXH3_hashLong64_f :: #type (*void, u64, XXH64_hash, *u8, u64) -> XXH64_hash #no_context;
XXH3_hashLong128_f :: #type (*void, u64, XXH64_hash, *void, u64) -> XXH128_hash #no_context;

XXH3_f_accumulate :: #type(*u64, *u8, *u8, u64) #no_context;
XXH3_f_scrambleAcc :: #type(*void , *void) #no_context;
XXH3_f_initCustomSecret :: #type(*void , u64) #no_context;

#if VECTOR_MODE == .Scalar {
    XXH3_scrambleAcc :: XXH3_scrambleAcc_scalar;
    XXH3_accumulate_512 :: XXH3_accumulate_512_scalar;
    XXH3_initCustomSecret :: XXH3_initCustomSecret_scalar;
} else #if VECTOR_MODE == .SSE2 {
    XXH3_scrambleAcc :: XXH3_scrambleAcc_sse2;
    XXH3_accumulate_512 :: XXH3_accumulate_512_sse2;
    XXH3_initCustomSecret :: XXH3_initCustomSecret_scalar;
} else #if VECTOR_MODE == .AVX2 {
    XXH3_scrambleAcc :: XXH3_scrambleAcc_avx2;
    XXH3_accumulate_512 :: XXH3_accumulate_512_avx2;
    XXH3_initCustomSecret :: XXH3_initCustomSecret_scalar;
}

XXH_xorshift64 :: inline (v64: u64, shift: int) -> u64 #no_context
{
    XXH_assert(0 <= shift && shift < 64);
    return v64 ^ (v64 >> shift);
}

XXH_mult32to64 :: inline (x: u64, y: u64) -> u64 #no_context
{
    return (c_cast(u64, c_cast(u32, x)) * c_cast(u64, c_cast(u32, y)));
}

XXH_mult32to64_add64 :: inline (lhs: u64, rhs: u64, acc: u64) -> u64 #no_context
{
    return XXH_mult32to64(c_cast(u32, lhs), c_cast(u32, rhs)) + acc;
}

XXH3_scalarRound :: inline (acc: *void, input: *void, secret: *void, lane: u64) #no_context
{
    xacc := c_cast(*u64, acc);
    xinput  := c_cast(*u8, input);
    xsecret := c_cast(*u8, secret);
    XXH_assert(lane < XXH_ACC_NB);
    XXH_assert((c_cast(u64, acc) & (XXH_ACC_ALIGN - 1)) == 0);

    data_val := XXH_readLE64(xinput + lane * 8);
    data_key := data_val ^ XXH_readLE64(xsecret + lane * 8);
    xacc[lane ^ 1] += data_val;
    xacc[lane] = XXH_mult32to64_add64(data_key, data_key >> 32, xacc[lane]);
}

XXH3_scalarScrambleRound :: inline (acc: *void, secret: *void, lane: u64) #no_context
{
    xacc := c_cast(*u64, acc);
    xsecret := c_cast(*u8, secret);
    XXH_assert(((c_cast(u64, acc)) & (XXH_ACC_ALIGN-1)) == 0);
    XXH_assert(lane < XXH_ACC_NB);
    
    key64 := XXH_readLE64(xsecret + lane * 8);
    acc64 := xacc[lane];
    acc64 = XXH_xorshift64(acc64, 47);
    acc64 ^= key64;
    acc64 *= XXH_PRIME32_1;
    xacc[lane] = acc64;
}

XXH_read32 :: (mem_ptr: *void) -> u32 #no_context
{
    val: u32 = ---;
    memcpy(*val, mem_ptr, size_of(u32));
    return val;
}

XXH_read64 :: (mem_ptr: *void) -> u64 #no_context
{
    val: u64 = ---;
    memcpy(*val, mem_ptr, size_of(u64));
    return val;
}

XXH_write64 :: inline (dst: *void, v64: u64) #no_context
{
    memcpy(dst, *v64, size_of(u64));
}

// @Todo - implement SSE2/AVX2 versions
XXH3_initCustomSecret_scalar :: inline (customSecret: *void, seed64: u64) #no_context
{
    kSecretPtr := XXH3_kSecret.data;
    #assert ((XXH_SECRET_DEFAULT_SIZE & 15) == 0);

    nbRounds :: XXH_SECRET_DEFAULT_SIZE / 16;
    #assert nbRounds > 0;
    for i: 0 .. nbRounds - 1 {
        lo := XXH_readLE64(kSecretPtr + 16*i)     + seed64;
        hi := XXH_readLE64(kSecretPtr + 16*i + 8) - seed64;
        XXH_writeLE64(c_cast(*u8, customSecret) + 16*i,     lo);
        XXH_writeLE64(c_cast(*u8, customSecret) + 16*i + 8, hi);
    }
}

XXH3_accumulate_512_scalar :: inline (acc: *void, input: *void, secret: *void) #no_context
{
    for i: 0 .. XXH_ACC_NB - 1 {
        XXH3_scalarRound(acc, input, secret, xx i);
    }
}

XXH3_accumulate_512_sse2 :: inline (acc: *void, input: *void, secret: *void) #no_context
{
    #asm {
        movdqu  xmm0:, [input];
        movdqu  xmm1:, [secret];
        pxor    xmm1, xmm0;
        pshufd  xmm2:, xmm1, 245;
        pmuludq xmm2, xmm1;
        pshufd  xmm0, xmm0, 78;
        paddq   xmm0, [acc];
        paddq   xmm0, xmm2;
        movdqa  [acc], xmm0;
        movdqu  xmm0, [input + 16];
        movdqu  xmm1, [secret + 16];
        pxor    xmm1, xmm0;
        pshufd  xmm2, xmm1, 245;
        pmuludq xmm2, xmm1;
        pshufd  xmm0, xmm0, 78;
        paddq   xmm0, [acc + 16];
        paddq   xmm0, xmm2;
        movdqa  [acc + 16], xmm0;
        movdqu  xmm0, [input + 32];
        movdqu  xmm1, [secret + 32];
        pxor    xmm1, xmm0;
        pshufd  xmm2, xmm1, 245;
        pmuludq xmm2, xmm1;
        pshufd  xmm0, xmm0, 78;
        paddq   xmm0, [acc + 32];
        paddq   xmm0, xmm2;
        movdqa  [acc + 32], xmm0;
        movdqu  xmm0, [input + 48];
        movdqu  xmm1, [secret + 48];
        pxor    xmm1, xmm0;
        pshufd  xmm2, xmm1, 245;
        pmuludq xmm2, xmm1;
        pshufd  xmm0, xmm0, 78;
        paddq   xmm0, [acc + 48];
        paddq   xmm0, xmm2;
        movdqa  [acc + 48], xmm0;
    }
}

XXH3_accumulate_512_avx2 :: inline (acc: *void, input: *void, secret: *void) #no_context
{
    #asm AVX, AVX2 {
        movdqu ymm0:, [input];
        pxor ymm1:, ymm0, [secret];
        pshufd ymm2:, ymm1, 245;
        pmuludq ymm1, ymm2, ymm1;
        pshufd ymm0, ymm0, 78;
        paddq ymm0, ymm0, [acc];
        paddq  ymm0, ymm0, ymm1;
        movdqu [acc], ymm0;
        movdqu ymm0, [input + 32];
        pxor ymm1, ymm0, [secret + 32];
        pshufd ymm2, ymm1, 245;
        pmuludq ymm1, ymm2, ymm1;
        pshufd ymm0, ymm0, 78;
        paddq ymm0, ymm0, [acc + 32];
        paddq  ymm0, ymm0, ymm1;
        movdqu [acc + 32], ymm0;
        zeroupper;
    }
}

XXH3_accumulate :: inline (acc: *u64, input: *u8, secret: *u8, nbStripes: u64) #no_context
{
    for n: 0 .. c_cast(s64, nbStripes) - 1 {
        in := input + n * XXH_STRIPE_LEN;
        // Doesn't seem to help, so leaving commented
        // #asm {
        //     prefetcht0 [in + XXH_PREFETCH_DIST];
        // }
        #if VECTOR_MODE == .Scalar {
            XXH3_accumulate_512_scalar(acc, in, secret + n * XXH_SECRET_CONSUME_RATE);
        } else #if VECTOR_MODE == .SSE2 {
            XXH3_accumulate_512_sse2(acc, in, secret + n * XXH_SECRET_CONSUME_RATE);
        } else #if VECTOR_MODE == .AVX2 {
            XXH3_accumulate_512_avx2(acc, in, secret + n * XXH_SECRET_CONSUME_RATE);
        }
    }
}

XXH3_scrambleAcc_scalar :: inline (acc: *void, secret: *void) #no_context
{
    for i: 0 .. XXH_ACC_NB - 1 {
        XXH3_scalarScrambleRound(acc, secret, xx i);
    }
}

XXH3_scrambleAcc_sse2 :: inline (acc: *void, secret: *void) #no_context
{
    ptr_prime := *XXH_PRIME32_1_SPLAT_128;
    #asm {
        movdqa  xmm4:, [acc];
        movdqa  xmm3:, [acc + 16];
        movdqa  xmm2:, [acc + 32];
        movdqa  xmm0:, [acc + 48];
        movdqu  xmm1:, [secret];
        pxor    xmm1, xmm4;
        psrlq   xmm4, 47;
        pxor    xmm4, xmm1;
        pshufd  xmm5:, xmm4, 245;
        movdqa  xmm1, [ptr_prime];
        pmuludq xmm4, xmm1;
        pmuludq xmm5, xmm1;
        psllq   xmm5, 32;
        paddq   xmm5, xmm4;
        movdqa  [acc], xmm5;
        movdqu  xmm4, [secret + 16];
        pxor    xmm4, xmm3;
        psrlq   xmm3, 47;
        pxor    xmm3, xmm4;
        pshufd  xmm4, xmm3, 245;
        pmuludq xmm3, xmm1;
        pmuludq xmm4, xmm1;
        psllq   xmm4, 32;
        paddq   xmm4, xmm3;
        movdqa  [acc + 16], xmm4;
        movdqu  xmm3, [secret + 32];
        pxor    xmm3, xmm2;
        psrlq   xmm2, 47;
        pxor    xmm2, xmm3;
        pshufd  xmm3, xmm2, 245;
        pmuludq xmm2, xmm1;
        pmuludq xmm3, xmm1;
        psllq   xmm3, 32;
        paddq   xmm3, xmm2;
        movdqa  [acc + 32], xmm3;
        movdqu  xmm2, [secret + 48];
        pxor    xmm2, xmm0;
        psrlq   xmm0, 47;
        pxor    xmm0, xmm2;
        pshufd  xmm2, xmm0, 245;
        pmuludq xmm0, xmm1;
        pmuludq xmm2, xmm1;
        psllq   xmm2, 32;
        paddq   xmm2, xmm0;
        movdqa  [acc + 48], xmm2;
    }
}

XXH3_scrambleAcc_avx2 :: inline (acc: *void, secret: *void) #no_context
{
    ptr_prime := *XXH_PRIME32_1_SPLAT_256;
    #asm AVX, AVX2 {
        movdqa  ymm0:, [acc];
        movdqa  ymm1:, [acc + 32];
        psrlq   ymm2:, ymm0, 47;
        pxor    ymm0, ymm2, ymm0;
        pxor    ymm0, ymm0, [secret];
        pbroadcastq ymm2, [ptr_prime];
        pmuludq ymm3:, ymm0, ymm2;
        pshufd  ymm0, ymm0, 245;
        pmuludq ymm0, ymm0, ymm2;
        psllq   ymm0, ymm0, 32;
        paddq   ymm0, ymm0, ymm3;
        movdqa  [acc], ymm0;
        psrlq   ymm0, ymm1, 47;
        pxor    ymm0, ymm0, ymm1;
        pxor    ymm0, ymm0, [secret + 32];
        pmuludq ymm1, ymm0, ymm2;
        pshufd  ymm0, ymm0, 245;
        pmuludq ymm0, ymm0, ymm2;
        psllq   ymm0, ymm0, 32;
        paddq   ymm0, ymm0, ymm1;
        movdqa  [acc + 32], ymm0;
        zeroupper;
    }
}

XXH_mult64to128 :: (lhs: u64, rhs: u64) -> XXH128_hash #no_context
{
    lo_lo := XXH_mult32to64(lhs & 0xFFFFFFFF, rhs & 0xFFFFFFFF);
    hi_lo := XXH_mult32to64(lhs >> 32,        rhs & 0xFFFFFFFF);
    lo_hi := XXH_mult32to64(lhs & 0xFFFFFFFF, rhs >> 32);
    hi_hi := XXH_mult32to64(lhs >> 32,        rhs >> 32);

    cross := (lo_lo >> 32) + (hi_lo & 0xFFFFFFFF) + lo_hi;
    upper := (hi_lo >> 32) + (cross >> 32)        + hi_hi;
    lower := (cross << 32) | (lo_lo & 0xFFFFFFFF);

    r128: XXH128_hash = ---;
    r128.low64  = lower;
    r128.high64 = upper;
    return r128;
}

XXH3_mul128_fold64 :: (lhs: u64, rhs: u64) -> u64 #no_context
{
    product := XXH_mult64to128(lhs, rhs);
    return product.low64 ^ product.high64;
}

XXH3_mix2Accs :: inline (acc: *u64, secret: *u8) -> u64 #no_context
{
    return XXH3_mul128_fold64(
               acc[0] ^ XXH_readLE64(secret),
               acc[1] ^ XXH_readLE64(secret+8) );
}

XXH3_mix16B :: inline (input: *u8, secret: *u8, seed64: u64) -> u64 #no_context
{
    input_lo := XXH_readLE64(input);
    input_hi := XXH_readLE64(input+8);
    return XXH3_mul128_fold64(
        input_lo ^ (XXH_readLE64(secret)   + seed64),
        input_hi ^ (XXH_readLE64(secret+8) - seed64)
    );    
}

XXH3_avalanche :: (h64: u64) -> XXH64_hash #no_context
{
    h64 = XXH_xorshift64(h64, 37);
    h64 *= XXH_PRIME_MX1;
    h64 = XXH_xorshift64(h64, 32);
    return h64;
}

XXH64_avalanche :: inline (hash: u64) -> XXH64_hash #no_context
{
    hash ^= hash >> 33;
    hash *= XXH_PRIME64_2;
    hash ^= hash >> 29;
    hash *= XXH_PRIME64_3;
    hash ^= hash >> 32;
    return hash;
}

XXH_rotl32 :: inline (x: u32, r: u32) -> u32 #expand #no_context
{
    return (((x) << (r)) | ((x) >> (32 - (r))));
}

XXH_rotl64 :: inline (x: u64, r: u64) -> u64 #expand #no_context
{
    return (((x) << (r)) | ((x) >> (64 - (r))));
}

XXH3_rrmxmx :: inline (h64: u64, len: u64) -> XXH64_hash #no_context
{
    h64 ^= XXH_rotl64(h64, 49) ^ XXH_rotl64(h64, 24);
    h64 *= XXH_PRIME_MX2;
    h64 ^= (h64 >> 35) + len ;
    h64 *= XXH_PRIME_MX2;
    return XXH_xorshift64(h64, 28);
}

XXH3_mergeAccs :: (acc: *u64, secret: *u8, start: u64) -> XXH64_hash #no_context
{
    result64 := start;
    i: u64 = 0;
    for i: 0 .. 3 {
        result64 += XXH3_mix2Accs(acc+2*i, secret + 16*i);
    }
    return XXH3_avalanche(result64);
}

XXH3_finalizeLong_64b :: (acc: *u64, secret: *u8, len: u64) -> XXH64_hash #no_context
{
    return XXH3_mergeAccs(acc, secret + XXH_SECRET_MERGEACCS_START, len * XXH_PRIME64_1);
}

XXH3_hashLong_64b_internal :: inline (input: *void, len: u64, secret: *void, secretSize: u64, 
    f_acc: XXH3_f_accumulate, f_scramble: XXH3_f_scrambleAcc) -> XXH64_hash #no_context 
{
    acc: [XXH_ACC_NB]u64 #align XXH_ACC_ALIGN;
    acc = XXH3_INIT_ACC;
    XXH3_hashLong_internal_loop(acc.data, c_cast(*u8, input), len, c_cast(*u8, secret), 
        secretSize, f_acc, f_scramble);

    #assert(size_of(type_of(acc)) == 64);
    XXH_assert(secretSize >= size_of(type_of(acc)) + XXH_SECRET_MERGEACCS_START);
    return XXH3_finalizeLong_64b(acc.data, c_cast(*u8, secret), c_cast(u64, len));
}

XXH3_hashLong_64b_withSeed_internal :: inline (input: *void, len: u64, seed: XXH64_hash, f_acc: XXH3_f_accumulate,
                                               f_scramble: XXH3_f_scrambleAcc, f_initSec:XXH3_f_initCustomSecret) -> XXH64_hash #no_context
{
    if (seed == 0) {
        return XXH3_hashLong_64b_internal(input, len, XXH3_kSecret.data, size_of(type_of(XXH3_kSecret)), f_acc, f_scramble);
    }
    secret: [XXH_SECRET_DEFAULT_SIZE]u8 #align XXH_SEC_ALIGN;
    f_initSec(secret.data, seed);
    return XXH3_hashLong_64b_internal(input, len, secret.data, size_of(type_of(secret)), f_acc, f_scramble);
}

XXH3_hashLong_64b_withSeed :: no_inline (input: *void, len: u64, seed64: XXH64_hash,
    secret: *u8, secretLen: u64) -> XXH64_hash #no_context
{
    return XXH3_hashLong_64b_withSeed_internal(input, len, seed64, XXH3_accumulate, XXH3_scrambleAcc, XXH3_initCustomSecret);
}

XXH3_hashLong_64b_default :: no_inline (input: *void, len: u64, seed64: XXH64_hash, secret: *u8, secretLen: u64) -> XXH64_hash #no_context
{
    return XXH3_hashLong_64b_internal(input, len, XXH3_kSecret.data, size_of(type_of(XXH3_kSecret)), XXH3_accumulate, XXH3_scrambleAcc);
}

XXH3_hashLong_64b_withSecret :: inline (input: *void, len: u64, seed64: XXH64_hash,
    secret: *u8, secretLen: u64) -> XXH64_hash #no_context
{
    return XXH3_hashLong_64b_internal(input, len, secret, secretLen, XXH3_accumulate, XXH3_scrambleAcc);
}

XXH3_hashLong_internal_loop :: inline (acc: *u64, input: *u8, len: u64, secret: *u8, secretSize: u64,
                            f_acc: XXH3_f_accumulate, f_scramble: XXH3_f_scrambleAcc) #no_context
{
    nbStripesPerBlock := (secretSize - XXH_STRIPE_LEN) / XXH_SECRET_CONSUME_RATE;
    block_len := XXH_STRIPE_LEN * nbStripesPerBlock;
    nb_blocks := (len - 1) / block_len;

    XXH_assert(secretSize >= XXH3_SECRET_SIZE_MIN);

    for n: 0 .. c_cast(s64, nb_blocks) - 1 {
        f_acc(acc, input + c_cast(u64, n) * block_len, secret, nbStripesPerBlock);
        f_scramble(acc, secret + secretSize - XXH_STRIPE_LEN);
    }
    XXH_assert(len > XXH_STRIPE_LEN);
    
    nbStripes := ((len - 1) - (block_len * nb_blocks)) / XXH_STRIPE_LEN;
    XXH_assert(nbStripes <= (secretSize / XXH_SECRET_CONSUME_RATE));
    f_acc(acc, input + nb_blocks*block_len, secret, nbStripes);

    p := input + len - XXH_STRIPE_LEN;
    XXH_SECRET_LASTACC_START :: 7;
    XXH3_accumulate_512(acc, p, secret + secretSize - XXH_STRIPE_LEN - XXH_SECRET_LASTACC_START);
}

//////////////
/// 64-bit ///
//////////////

XXH3_len_1to3_64b :: inline (input: *u8, len: u64, secret: *u8, seed: XXH64_hash) -> XXH64_hash #no_context
{
    XXH_assert(input != null);
    XXH_assert(1 <= len && len <= 3);
    XXH_assert(secret != null);

    c1: u8 = input[0];
    c2: u8 = input[len >> 1];
    c3: u8 = input[len - 1];
    combined: u32 = (c_cast(u32, c1) << 16) | (c_cast(u32, c2) << 24) | (c_cast(u32, c3) << 0) | (c_cast(u32, len) << 8);
    bitflip:  u64 = (XXH_readLE32(secret) ^ XXH_readLE32(secret+4)) + seed;
    keyed:    u64 = c_cast(u64, combined) ^ bitflip;
    return XXH64_avalanche(keyed);
}

XXH3_len_4to8_64b :: inline (input: *u8, len: u64, secret: *u8, seed: XXH64_hash) -> XXH64_hash #no_context
{
    XXH_assert(input != null);
    XXH_assert(secret != null);
    XXH_assert(4 <= len && len <= 8);
    seed ^= c_cast(u64, XXH_swap(c_cast(u32, seed))) << 32;
    
    input1: u32 = XXH_readLE32(input);
    input2: u32 = XXH_readLE32(input + len - 4);
    bitflip: u64 = (XXH_readLE64(secret+8) ^ XXH_readLE64(secret+16)) - seed;
    input64: u64 = input2 + ((c_cast(u64, input1)) << 32);
    keyed: u64 = input64 ^ bitflip;
    return XXH3_rrmxmx(keyed, len);
}

XXH3_len_9to16_64b :: inline (input: *u8, len: u64, secret: *u8, seed: XXH64_hash) -> XXH64_hash #no_context
{
    XXH_assert(input != null);
    XXH_assert(secret != null);
    XXH_assert(9 <= len && len <= 16);
    
    bitflip1 :u64 = (XXH_readLE64(secret+24) ^ XXH_readLE64(secret+32)) + seed;
    bitflip2 :u64 = (XXH_readLE64(secret+40) ^ XXH_readLE64(secret+48)) - seed;
    input_lo :u64 = XXH_readLE64(input)           ^ bitflip1;
    input_hi :u64 = XXH_readLE64(input + len - 8) ^ bitflip2;
    acc      :u64 = len + XXH_swap(input_lo) + input_hi
                        + XXH3_mul128_fold64(input_lo, input_hi);
    return XXH3_avalanche(acc);
}

XXH3_len_0to16_64b :: inline (input: *u8, len: u64, secret: *u8, seed: XXH64_hash) -> XXH64_hash #no_context
{
    XXH_assert(len <= 16);
    if (XXH_likely(len >  8)) return XXH3_len_9to16_64b(input, len, secret, seed);
    if (XXH_likely(len >= 4)) return XXH3_len_4to8_64b(input, len, secret, seed);
    if (len) return XXH3_len_1to3_64b(input, len, secret, seed);
    return XXH64_avalanche(seed ^ (XXH_readLE64(secret+56) ^ XXH_readLE64(secret+64)));
}

XXH3_len_17to128_64b :: inline (input: *u8, len: u64, secret: *u8, secretSize: u64, seed: XXH64_hash) -> XXH64_hash #no_context
{
    XXH_assert(secretSize >= XXH3_SECRET_SIZE_MIN);
    XXH_assert(16 < len && len <= 128);
    
    acc: u64 = len * XXH_PRIME64_1;

    if (len > 32) {
        if (len > 64) {
            if (len > 96) {
                acc += XXH3_mix16B(input+48, secret+96, seed);
                acc += XXH3_mix16B(input+len-64, secret+112, seed);
            }
            acc += XXH3_mix16B(input+32, secret+64, seed);
            acc += XXH3_mix16B(input+len-48, secret+80, seed);
        }
        acc += XXH3_mix16B(input+16, secret+32, seed);
        acc += XXH3_mix16B(input+len-32, secret+48, seed);
    }
    acc += XXH3_mix16B(input+0, secret+0, seed);
    acc += XXH3_mix16B(input+len-16, secret+16, seed);

    return XXH3_avalanche(acc);
}

XXH3_len_129to240_64b :: no_inline (input: *u8, len: u64, 
    secret: *u8, secretSize: u64, seed: XXH64_hash) -> XXH64_hash #no_context
{
    XXH_assert(secretSize >= XXH3_SECRET_SIZE_MIN);
    XXH_assert(128 < len && len <= XXH3_MIDSIZE_MAX);

    XXH3_MIDSIZE_STARTOFFSET :: 3;
    XXH3_MIDSIZE_LASTOFFSET :: 17;

    acc: u64 = len * XXH_PRIME64_1;
    nbRounds : s32 = c_cast(s32, len / 16);
    XXH_assert(128 < len && len <= XXH3_MIDSIZE_MAX);
    for i: 0 .. 7 {
        acc += XXH3_mix16B(input+(16*i), secret+(16*i), seed);
    }
    acc_end: u64 = XXH3_mix16B(input + len - 16,
        secret + XXH3_SECRET_SIZE_MIN - XXH3_MIDSIZE_LASTOFFSET, seed);
    XXH_assert(nbRounds >= 8);
    acc = XXH3_avalanche(acc);
    for i: 8 .. nbRounds - 1 {
        acc_end += XXH3_mix16B(input+(16*i), secret+(16*(i-8)) + XXH3_MIDSIZE_STARTOFFSET, seed);
    }
    return XXH3_avalanche(acc + acc_end);
}

XXH3_64bits_internal :: inline (input: *void, len: u64,
                     seed64: XXH64_hash, secret: *void, secretLen: u64,
                     f_hashLong: XXH3_hashLong64_f) -> u64 #no_context
{
    XXH_assert(secretLen >= XXH3_SECRET_SIZE_MIN);
    secret_u8 := c_cast(*u8, secret);
    input_u8 := c_cast(*u8, input);

    if (len <= 16) {
        return XXH3_len_0to16_64b(input_u8, len, secret_u8, seed64);
    }
    if (len <= 128) {
        return XXH3_len_17to128_64b(input_u8, len, secret_u8, secretLen, seed64);
    }
    if (len <= XXH3_MIDSIZE_MAX) {
        return XXH3_len_129to240_64b(input_u8, len, secret_u8, secretLen, seed64);
    }
    return f_hashLong(input, len, seed64, secret_u8, secretLen);
}

///////////////
/// 128-bit ///
///////////////

XXH3_len_1to3_128b :: inline (input: *u8, len: u64, secret: *u8, seed: XXH64_hash) -> XXH128_hash #no_context
{
    XXH_assert(input != null);
    XXH_assert(1 <= len && len <= 3);
    XXH_assert(secret != null);
    
    c1: u8 = input[0];
    c2: u8 = input[len >> 1];
    c3: u8 = input[len - 1];
    combinedl: u32 = (c_cast(u32, c1) <<16) | (c_cast(u32, c2) << 24) | (c_cast(u32, c3) << 0) | (c_cast(u32, len) << 8);
    combinedh: u32 = XXH_rotl32(XXH_swap(combinedl), 13);
    bitflipl: u64 = (XXH_readLE32(secret) ^ XXH_readLE32(secret+4)) + seed;
    bitfliph: u64 = (XXH_readLE32(secret+8) ^ XXH_readLE32(secret+12)) - seed;
    keyed_lo: u64 = c_cast(u64, combinedl) ^ bitflipl;
    keyed_hi: u64 = c_cast(u64, combinedh) ^ bitfliph;
    h128: XXH128_hash = ---;
    h128.low64  = XXH64_avalanche(keyed_lo);
    h128.high64 = XXH64_avalanche(keyed_hi);
    return h128;
}

XXH3_len_4to8_128b :: inline (input: *u8, len: u64, secret: *u8, seed: XXH64_hash) -> XXH128_hash #no_context
{
    XXH_assert(input != null);
    XXH_assert(secret != null);
    XXH_assert(4 <= len && len <= 8);
    seed ^= c_cast(u64, XXH_swap(c_cast(u32, seed))) << 32;
    
    input_lo: u32 = XXH_readLE32(input);
    input_hi: u32 = XXH_readLE32(input + len - 4);
    input_64: u64 = input_lo + (c_cast(u64, input_hi) << 32);
    bitflip: u64 = (XXH_readLE64(secret+16) ^ XXH_readLE64(secret+24)) + seed;
    keyed: u64 = input_64 ^ bitflip;

    m128: XXH128_hash = XXH_mult64to128(keyed, XXH_PRIME64_1 + (len << 2));

    m128.high64 += (m128.low64 << 1);
    m128.low64  ^= (m128.high64 >> 3);

    m128.low64   = XXH_xorshift64(m128.low64, 35);
    m128.low64  *= XXH_PRIME_MX2;
    m128.low64   = XXH_xorshift64(m128.low64, 28);
    m128.high64  = XXH3_avalanche(m128.high64);
    return m128;
}

XXH3_len_9to16_128b :: inline (input: *u8, len: u64, secret: *u8, seed: XXH64_hash) -> XXH128_hash #no_context
{
    XXH_assert(input != null);
    XXH_assert(secret != null);
    XXH_assert(9 <= len && len <= 16);
    
    bitflipl: u64 = (XXH_readLE64(secret+32) ^ XXH_readLE64(secret+40)) - seed;
    bitfliph: u64 = (XXH_readLE64(secret+48) ^ XXH_readLE64(secret+56)) + seed;
    input_lo: u64 = XXH_readLE64(input);
    input_hi: u64 = XXH_readLE64(input + len - 8);
    m128: XXH128_hash = XXH_mult64to128(input_lo ^ input_hi ^ bitflipl, XXH_PRIME64_1);
    m128.low64 += c_cast(u64, (len - 1)) << 54;
    input_hi   ^= bitfliph;
    if (size_of(*void) < size_of(u64)) {
        m128.high64 += (input_hi & 0xFFFFFFFF00000000) + XXH_mult32to64(c_cast(u32, input_hi), XXH_PRIME32_2);
    } 
    else {
        m128.high64 += input_hi + XXH_mult32to64(c_cast(u32, input_hi), XXH_PRIME32_2 - 1);
    }
    m128.low64 ^= XXH_swap(m128.high64);
    
    h128: XXH128_hash = XXH_mult64to128(m128.low64, XXH_PRIME64_2);
    h128.high64 += m128.high64 * XXH_PRIME64_2;

    h128.low64   = XXH3_avalanche(h128.low64);
    h128.high64  = XXH3_avalanche(h128.high64);
    return h128;
}

XXH3_len_0to16_128b :: inline (input: *u8, len: u64, secret: *u8, seed: XXH64_hash) -> XXH128_hash #no_context
{
    XXH_assert(len <= 16);

    if (len > 8) return XXH3_len_9to16_128b(input, len, secret, seed);
    if (len >= 4) return XXH3_len_4to8_128b(input, len, secret, seed);
    if (len) return XXH3_len_1to3_128b(input, len, secret, seed);

    h128: XXH128_hash = ---;
    bitflipl: u64 = XXH_readLE64(secret+64) ^ XXH_readLE64(secret+72);
    bitfliph: u64 = XXH_readLE64(secret+80) ^ XXH_readLE64(secret+88);
    h128.low64 = XXH64_avalanche(seed ^ bitflipl);
    h128.high64 = XXH64_avalanche( seed ^ bitfliph);
    return h128;
}

XXH128_mix32B :: inline (acc_in: XXH128_hash, input_1: *u8, input_2: *u8, secret: *u8, seed: XXH64_hash) -> XXH128_hash #no_context
{
    acc := acc_in;
    acc.low64  += XXH3_mix16B (input_1, secret+0, seed);
    acc.low64  ^= XXH_readLE64(input_2) + XXH_readLE64(input_2 + 8);
    acc.high64 += XXH3_mix16B (input_2, secret+16, seed);
    acc.high64 ^= XXH_readLE64(input_1) + XXH_readLE64(input_1 + 8);
    return acc;
}

XXH3_len_17to128_128b :: inline (input: *u8, len: u64, secret: *u8, secretSize: u64, seed: XXH64_hash) -> XXH128_hash #no_context
{
    XXH_assert(secretSize >= XXH3_SECRET_SIZE_MIN);
    XXH_assert(16 < len && len <= 128);
    
    acc: XXH128_hash = ---;
    acc.low64 = len * XXH_PRIME64_1;
    acc.high64 = 0;

    if (len > 32) {
        if (len > 64) {
            if (len > 96) {
                acc = XXH128_mix32B(acc, input+48, input+len-64, secret+96, seed);
            }
            acc = XXH128_mix32B(acc, input+32, input+len-48, secret+64, seed);
        }
        acc = XXH128_mix32B(acc, input+16, input+len-32, secret+32, seed);
    }
    acc = XXH128_mix32B(acc, input, input+len-16, secret, seed);

    h128: XXH128_hash = ---;
    h128.low64  = acc.low64 + acc.high64;
    h128.high64 = (acc.low64    * XXH_PRIME64_1)
                + (acc.high64   * XXH_PRIME64_4)
                + ((len - seed) * XXH_PRIME64_2);
    h128.low64  = XXH3_avalanche(h128.low64);
    h128.high64 = c_cast(XXH64_hash, 0) - XXH3_avalanche(h128.high64);
    return h128;
}

XXH3_len_129to240_128b :: no_inline (input: *u8, len: u64, secret: *u8, secretSize: u64, seed: XXH64_hash) -> XXH128_hash #no_context
{
    XXH_assert(secretSize >= XXH3_SECRET_SIZE_MIN);
    XXH_assert(128 < len && len <= XXH3_MIDSIZE_MAX);

    XXH3_MIDSIZE_STARTOFFSET :: 3;
    XXH3_MIDSIZE_LASTOFFSET :: 17;

    acc: XXH128_hash = ---;
    acc.low64 = len * XXH_PRIME64_1;
    acc.high64 = 0;

    i: u32 = 32;
    while i < 160 {
        acc = XXH128_mix32B(acc,
                            input  + i - 32,
                            input  + i - 16,
                            secret + i - 32,
                            seed);
        i += 32;
    }
    acc.low64 = XXH3_avalanche(acc.low64);
    acc.high64 = XXH3_avalanche(acc.high64);
    i = 160;
    while i <= len {
        acc = XXH128_mix32B(acc,
                            input + i - 32,
                            input + i - 16,
                            secret + XXH3_MIDSIZE_STARTOFFSET + i - 160,
                            seed);
        i += 32;
    }
    acc = XXH128_mix32B(acc,
                        input + len - 16,
                        input + len - 32,
                        secret + XXH3_SECRET_SIZE_MIN - XXH3_MIDSIZE_LASTOFFSET - 16,
                        c_cast(XXH64_hash, 0) - seed);


    h128: XXH128_hash = ---;
    h128.low64  = acc.low64 + acc.high64;
    h128.high64 = (acc.low64    * XXH_PRIME64_1)
                + (acc.high64   * XXH_PRIME64_4)
                + ((len - seed) * XXH_PRIME64_2);
    h128.low64  = XXH3_avalanche(h128.low64);
    h128.high64 = c_cast(XXH64_hash, 0) - XXH3_avalanche(h128.high64);
    return h128;
}

XXH3_finalizeLong_128b :: (acc: *u64, secret: *u8, secretSize: u64, len: u64) -> XXH128_hash #no_context
{
    h128: XXH128_hash = ---;
    h128.low64 = XXH3_finalizeLong_64b(acc, secret, len);
    h128.high64 = XXH3_mergeAccs(acc, secret + secretSize
                                             - XXH_STRIPE_LEN - XXH_SECRET_MERGEACCS_START,
                                             ~(len * XXH_PRIME64_2));
    return h128;
}

XXH3_hashLong_128b_internal :: inline (input: *void, len: u64,
                            secret: *u8, secretSize: u64,
                            f_acc: XXH3_f_accumulate,
                            f_scramble: XXH3_f_scrambleAcc) -> XXH128_hash #no_context
{
    acc: [XXH_ACC_NB]u64 #align XXH_ACC_ALIGN;
    acc = XXH3_INIT_ACC;
    XXH3_hashLong_internal_loop(acc.data, c_cast(*u8, input), len, secret, secretSize, f_acc, f_scramble);
    #assert(size_of(type_of(acc)) == 64);
    XXH_assert(secretSize >= size_of(type_of(acc)) + XXH_SECRET_MERGEACCS_START);
    return XXH3_finalizeLong_128b(acc.data, secret, secretSize, len);
}

XXH3_hashLong_128b_default :: no_inline (input: *void, len: u64, seed64: XXH64_hash, secret: *void, secretLen: u64) -> XXH128_hash #no_context
{
    return XXH3_hashLong_128b_internal(input, len, XXH3_kSecret.data, size_of(type_of(XXH3_kSecret)), XXH3_accumulate, XXH3_scrambleAcc);
}

XXH3_hashLong_128b_withSecret :: inline(input: *void, len: u64, seed64: XXH64_hash,
                              secret: *void, secretLen: u64) -> XXH128_hash #no_context
{
    return XXH3_hashLong_128b_internal(input, len, c_cast(*u8, secret), secretLen, XXH3_accumulate, XXH3_scrambleAcc);
}

XXH3_hashLong_128b_withSeed_internal :: inline(input: *void, len: u64,
                                seed64: XXH64_hash,
                                f_acc: XXH3_f_accumulate,
                                f_scramble: XXH3_f_scrambleAcc,
                                f_initSec: XXH3_f_initCustomSecret) -> XXH128_hash #no_context
{
    if (seed64 == 0) {
        return XXH3_hashLong_128b_internal(input, len, XXH3_kSecret.data, size_of(type_of(XXH3_kSecret)), f_acc, f_scramble);
    }
    secret: [XXH_SECRET_DEFAULT_SIZE]u8 #align XXH_SEC_ALIGN;
    f_initSec(secret.data, seed64);
    return XXH3_hashLong_128b_internal(input, len, secret.data, size_of(type_of(secret)), f_acc, f_scramble);
}
 
XXH3_hashLong_128b_withSeed :: no_inline (input: *void, len: u64,
                            seed64: XXH64_hash, secret: *void, secretLen: u64) -> XXH128_hash #no_context
{
    return XXH3_hashLong_128b_withSeed_internal(input, len, seed64,
                XXH3_accumulate, XXH3_scrambleAcc, XXH3_initCustomSecret);
}

XXH3_128bits_internal :: inline (input: *void, len: u64, seed64: XXH64_hash, secret: *void, secretLen: u64, f_hl128: XXH3_hashLong128_f) -> XXH128_hash #no_context
{
    XXH_assert(secretLen >= XXH3_SECRET_SIZE_MIN);
    secret_u8 := c_cast(*u8, secret);
    input_u8 := c_cast(*u8, input);
    if (len <= 16) {
        return XXH3_len_0to16_128b(input_u8, len, secret_u8, seed64);
    }
    if (len <= 128) {
        return XXH3_len_17to128_128b(input_u8, len, secret_u8, secretLen, seed64);
    }
    if (len <= XXH3_MIDSIZE_MAX) {
        return XXH3_len_129to240_128b(input_u8, len, secret_u8, secretLen, seed64);
    }
    return f_hl128(input, len, seed64, secret, secretLen);
}

#import "Basic";
#import "Bit_Operations";