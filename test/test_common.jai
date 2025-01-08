run_xxh3_test :: (file: string)
{
    s, success := read_entire_file(file);
    assert(success);
    defer free(s);
    
    hash_64: XXH64_hash;
    hash_128: XXH128_hash;

    hash_64 = XXH3_64bits(s.data, xx s.count);
    hash_128 = XXH3_128bits(s.data, xx s.count);
    print("Raw: %\n",  file);
    print("    XXH3_64bits:  [%]\n", hash_64);
    print("    XXH3_128bits: [%, %]\n", hash_128.low64, hash_128.high64);
    
    hash_64 = XXH3_64bits_withSeed(s.data, xx s.count, 0xDEADBEEF);
    hash_128 = XXH3_128bits_withSeed(s.data, xx s.count, 0xDEADBEEF);
    print("With seed: %\n",  file);
    print("    XXH3_64bits:  [%]\n", hash_64);
    print("    XXH3_128bits: [%, %]\n", hash_128.low64, hash_128.high64);
    
    secret :: "DEADBEEF_DEADBEEF_DEADBEEF_DEADBEEF_DEADBEEF_DEADBEEF_DEADBEEF_DEADBEEF_DEADBEEF_DEADBEEFDEADBEEF_DEADBEEDEADBEEF_DEADBEEFDEADBEEF_DEADBEEFFDEADBEEF_DEADBEEF_DEADBEEF_DEADBEEF_DEADBEEFDEADBEEF";
    hash_64 = XXH3_64bits_withSecret(s.data, xx s.count, secret.data, xx secret.count);
    hash_128 = XXH3_128bits_withSecret(s.data, xx s.count, secret.data, xx secret.count);
    print("With secret: %\n",  file);
    print("    XXH3_64bits:  [%]\n", hash_64);
    print("    XXH3_128bits: [%, %]\n", hash_128.low64, hash_128.high64);
    
    hash_64 = XXH3_64bits_withSecretandSeed(s.data, xx s.count, secret.data, xx secret.count, 0xBEEFBEEF);
    hash_128 = XXH3_128bits_withSecretandSeed(s.data, xx s.count, secret.data, xx secret.count, 0xBEEFBEEF);
    print("With seed and secret: %\n",  file);
    print("    XXH3_64bits:  [%]\n", hash_64);
    print("    XXH3_128bits: [%, %]\n", hash_128.low64, hash_128.high64);
}

main :: ()
{
    run_xxh3_test("data/test_1b");
    run_xxh3_test("data/test_4b");
    run_xxh3_test("data/test_9b");
    run_xxh3_test("data/test_10b");
    run_xxh3_test("data/test_17b");
    run_xxh3_test("data/test_32b");
    run_xxh3_test("data/test_33b");
    run_xxh3_test("data/test_64b");
    run_xxh3_test("data/test_65b");
    run_xxh3_test("data/test_100b");
    run_xxh3_test("data/test_250b");
    run_xxh3_test("data/test_1kb");
    run_xxh3_test("data/test_10kb");
    run_xxh3_test("data/test_100kb");
    run_xxh3_test("data/test_1mb");
    run_xxh3_test("data/test_10mb");
}

#import "Basic";
#import "File";