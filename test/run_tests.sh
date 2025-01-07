#!/bin/bash

if [ ! -d "bin" ]; then
    mkdir bin
fi
if [ ! -d "results" ]; then
    mkdir results
fi

# Compile C exes
clang -DXXH_STATIC_LINKING_ONLY -DXXH_IMPLEMENTATION -O3 test_c.c -o bin/test_c

clang -DXXH_VECTOR=XXH_SCALAR -DXXH_STATIC_LINKING_ONLY -DXXH_IMPLEMENTATION -O3 bench_c.c -o bin/bench_c_scalar
clang -march=native -DXXH_VECTOR=XXH_SSE2 -DXXH_STATIC_LINKING_ONLY -DXXH_IMPLEMENTATION -O3 bench_c.c -o bin/bench_c_sse2
clang -march=native -DXXH_VECTOR=XXH_AVX2 -DXXH_STATIC_LINKING_ONLY -DXXH_IMPLEMENTATION -O3 bench_c.c -o bin/bench_c_avx2

# Compile Jai exes
jai-linux test_scalar.jai -quiet -import_dir ../.. -output_path bin
jai-linux test_sse2.jai -quiet -import_dir ../.. -output_path bin
jai-linux test_avx2.jai -quiet -import_dir ../.. -output_path bin
jai-linux test_check_results.jai -quiet -import_dir ../.. -output_path bin

jai-linux bench_scalar.jai -release -quiet -import_dir ../.. -output_path bin
jai-linux bench_sse2.jai -release -quiet -import_dir ../.. -output_path bin
jai-linux bench_avx2.jai -release -quiet -import_dir ../.. -output_path bin
jai-linux bench_tabulate.jai -release -quiet -import_dir ../.. -output_path bin

# Run tests and benchmarks, logging to file
bin/test_c >results/test_c.log
bin/test_scalar >results/test_scalar.log
bin/test_sse2 >results/test_sse2.log
bin/test_avx2 >results/test_avx2.log
bin/test_check_results

bin/bench_scalar >results/bench_scalar.log
bin/bench_sse2 >results/bench_sse2.log
bin/bench_avx2 >results/bench_avx2.log
bin/bench_c_scalar >results/bench_c_scalar.log
bin/bench_c_sse2 >results/bench_c_sse2.log
bin/bench_c_avx2 >results/bench_c_avx2.log
bin/bench_tabulate