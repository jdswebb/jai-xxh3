#include "xxhash.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>

void run_xxh3_test(const char *file)
{
    FILE *f = fopen(file, "rb");
    fseek(f, 0, SEEK_END);
    long fsize = ftell(f);
    fseek(f, 0, SEEK_SET);

    char *data = malloc(fsize);
    fread(data, fsize, 1, f);
    fclose(f);
    
    XXH64_hash_t hash_64;
    XXH128_hash_t hash_128;

    hash_64 = XXH3_64bits(data, fsize);
    hash_128 = XXH3_128bits(data, fsize);
    printf("Raw: %s\n",  file);
    printf("    XXH3_64bits:  [%" PRIuPTR "]\n", hash_64);
    printf("    XXH3_128bits: [%" PRIuPTR ", %" PRIuPTR "]\n", hash_128.low64, hash_128.high64);

    hash_64 = XXH3_64bits_withSeed(data, fsize, 0xDEADBEEF);
    hash_128 = XXH3_128bits_withSeed(data, fsize, 0xDEADBEEF);
    printf("With seed: %s\n", file);
    printf("    XXH3_64bits:  [%" PRIuPTR "]\n", hash_64);
    printf("    XXH3_128bits: [%" PRIuPTR ", %" PRIuPTR "]\n", hash_128.low64, hash_128.high64);

    const char* secret = "DEADBEEF_DEADBEEF_DEADBEEF_DEADBEEF_DEADBEEF_DEADBEEF_DEADBEEF_"
        "DEADBEEF_DEADBEEF_DEADBEEFDEADBEEF_DEADBEEDEADBEEF_DEADBEEFDEADBEEF_DEADBEEFFDEADBEEF_DEADBEEF_DEADBEEF_DEADBEEF_DEADBEEFDEADBEEF";
    hash_64 = XXH3_64bits_withSecret(data, fsize, secret, strlen(secret));
    hash_128 = XXH3_128bits_withSecret(data, fsize, secret, strlen(secret));
    printf("With secret: %s\n", file);
    printf("    XXH3_64bits:  [%" PRIuPTR "]\n", hash_64);
    printf("    XXH3_128bits: [%" PRIuPTR ", %" PRIuPTR "]\n", hash_128.low64, hash_128.high64);

    hash_64 = XXH3_64bits_withSecretandSeed(data, fsize, secret, strlen(secret), 0xBEEFBEEF);
    hash_128 = XXH3_128bits_withSecretandSeed(data, fsize, secret, strlen(secret), 0xBEEFBEEF);
    printf("With seed and secret: %s\n", file);
    printf("    XXH3_64bits:  [%" PRIuPTR "]\n", hash_64);
    printf("    XXH3_128bits: [%" PRIuPTR ", %" PRIuPTR "]\n", hash_128.low64, hash_128.high64);

    free(data);
}

int main(int argc, char** argv)
{
    run_xxh3_test("data/test_1b");
    run_xxh3_test("data/test_10b");
    run_xxh3_test("data/test_100b");
    run_xxh3_test("data/test_1kb");
    run_xxh3_test("data/test_10kb");
    run_xxh3_test("data/test_100kb");
    run_xxh3_test("data/test_1mb");
    run_xxh3_test("data/test_10mb");
}