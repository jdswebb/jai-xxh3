#include "xxhash.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>

#ifdef _MSC_VER
#include "Windows.h"
#else
#include <time.h>
#endif

#ifdef _MSC_VER
static uint64_t timer_get_raw_ticks(void)
{
    LARGE_INTEGER li;
    QueryPerformanceCounter(&li);
    return (uint64_t)li.QuadPart;
}

static double timer_get_inverse_frequency(void)
{
    while (1) {
        LARGE_INTEGER li;
        QueryPerformanceFrequency(&li);
        double f = (double)li.QuadPart;
        if (f > 0.0) {
            return 1000.0 / f;
        }
    }
}

static float timer_get_elapsed_ms(uint64_t start)
{
    static double inv_freq = 0xDEAD;
    if (inv_freq == 0xDEAD)
    {
        inv_freq = timer_get_inverse_frequency();
    }
    LARGE_INTEGER li;
    QueryPerformanceCounter(&li);
    uint64_t now = (uint64_t)li.QuadPart;
    float ms = (float)(inv_freq * (now - start));
    return ms;
}

#else

static uint64_t timer_get_raw_ticks(void)
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (uint64_t)ts.tv_sec * 1000000000ull + (uint64_t)ts.tv_nsec;
}

static float timer_get_elapsed_ms(uint64_t start)
{
    uint64_t now = timer_get_raw_ticks();
    float ms = ((float)(now - start)) / 1e6;
    return ms;
}

#endif

void bench_xxh3(const char *file, uint64_t N, FILE *f_out)
{
    FILE *f = fopen(file, "rb");
    fseek(f, 0, SEEK_END);
    long fsize = ftell(f);
    fseek(f, 0, SEEK_SET);

    char *data = malloc(fsize);
    fread(data, fsize, 1, f);
    fclose(f);
    
    printf("Benchmark: %s\n", file);
    static const size_t repeats = 10;
    
    // volatile to prevent the inner loop being turned into a multiply :)
    volatile uint64_t sum = 0;
    double avg = 0;
    for (size_t j = 0; j < repeats; ++j) {
        uint64_t start_time = timer_get_raw_ticks();
        for (size_t i = 0; i < N; ++i) {
            sum += XXH3_64bits(data, fsize);
        }
        float elapsed = timer_get_elapsed_ms(start_time);
        avg += elapsed;
    }
    printf("    XXH3_64bits: %f ms\n", (avg / repeats));
    fprintf(f_out, "%f\n", (avg / repeats));

    sum = 0;
    avg = 0;
    for (size_t j = 0; j < repeats; ++j) {
        uint64_t start_time = timer_get_raw_ticks();
        for (size_t i = 0; i < N; ++i) {
            XXH128_hash_t hash_128 = XXH3_128bits(data, fsize);
            sum += hash_128.high64 + hash_128.low64;
        }
        float elapsed = timer_get_elapsed_ms(start_time);
        avg += elapsed;
    }
    printf("    XXH3_128bits: %f ms\n", (avg / repeats));
    fprintf(f_out, "%f\n", (avg / repeats));
    free(data);
}

int main(int argc, char** argv)
{
    const char* file_name = "results/bench_data_c_scalar.txt";
    if (XXH_VECTOR == XXH_SSE2) {
        file_name = "results/bench_data_c_sse2.txt";
    }
    else if (XXH_VECTOR == XXH_AVX2) {
        file_name = "results/bench_data_c_avx2.txt";
    }
    FILE *f = fopen(file_name, "wb");
    bench_xxh3("data/test_1b", 10000000, f);
    bench_xxh3("data/test_10b", 10000000, f);
    bench_xxh3("data/test_100b", 1000000, f);
    bench_xxh3("data/test_1kb", 1000000, f);
    bench_xxh3("data/test_10kb", 100000, f);
    bench_xxh3("data/test_100kb", 10000, f);
    bench_xxh3("data/test_1mb", 10000, f);
    bench_xxh3("data/test_10mb", 1000, f);
    fclose(f);
}