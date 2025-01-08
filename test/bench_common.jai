bench_xxh3 :: (file: string, N: u64, file_out: *File)
{
    s, success := read_entire_file(file);
    assert(success);
    defer free(s);
    
    print("Benchmark: %\n",  file);
    
    repeats :: 2;
    
    sum : u64 = 0;
    avg : float64 = 0;
    for j: 0 .. repeats - 1 {
        start_time := current_time_monotonic();
        for i: 0 .. N - 1 {
            sum += XXH3_64bits(s.data, xx s.count);
        }
        elapsed := cast (float) to_float64_seconds (current_time_monotonic() - start_time);
        avg += elapsed;
    }
    print("    XXH3_64bits: % ms\n", (avg / repeats) * 1000);
    result := tprint("%\n", (avg / repeats) * 1000);
    file_write(file_out, result);
    
    sum = 0;
    avg = 0;
    for j: 0 .. repeats - 1 {
        start_time := current_time_monotonic();
        for i: 0 .. N - 1 {
            hash_128 := XXH3_128bits(s.data, xx s.count);
            sum += hash_128.high64 + hash_128.low64;
        }
        elapsed := cast (float) to_float64_seconds (current_time_monotonic() - start_time);
        avg += elapsed;
    }
    print("    XXH3_128bits: % ms\n", (avg / repeats) * 1000);
    result = tprint("%\n", (avg / repeats) * 1000);
    file_write(file_out, result);
}

main :: ()
{
    file, success := file_open(BENCH_DATA_FILE_NAME, for_writing=true, keep_existing_content=false);
    assert(success);
    defer file_close(*file);
    
    bench_xxh3("data/test_1b",    10000000, *file);
    bench_xxh3("data/test_4b",    10000000, *file);
    bench_xxh3("data/test_9b",    10000000, *file);
    bench_xxh3("data/test_10b",   10000000, *file);
    bench_xxh3("data/test_17b",   10000000, *file);
    bench_xxh3("data/test_32b",   10000000, *file);
    bench_xxh3("data/test_33b",   10000000, *file);
    bench_xxh3("data/test_64b",   10000000, *file);
    bench_xxh3("data/test_65b",   10000000, *file);
    bench_xxh3("data/test_100b",  10000000, *file);
    bench_xxh3("data/test_250b",  10000000, *file);
    bench_xxh3("data/test_1kb",   10000000, *file);
    bench_xxh3("data/test_10kb",  1000000,  *file);
    bench_xxh3("data/test_100kb", 100000,   *file);
    bench_xxh3("data/test_1mb",   10000,    *file);
    bench_xxh3("data/test_10mb",  1000,     *file);
}

#import "Basic";
#import "File";