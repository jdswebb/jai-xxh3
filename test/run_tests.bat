@echo off
if not exist "bin" (
    mkdir bin
)
if not exist "results" (
    mkdir results
)

:: Compile C exes
clang -D_CRT_SECURE_NO_WARNINGS -DXXH_STATIC_LINKING_ONLY -DXXH_IMPLEMENTATION -O3 test_c.c -o bin/test_c.exe

clang -DXXH_VECTOR=XXH_SCALAR -D_CRT_SECURE_NO_WARNINGS -DXXH_STATIC_LINKING_ONLY -DXXH_IMPLEMENTATION -O3 bench_c.c -o bin/bench_c_scalar.exe
clang -march=native -DXXH_VECTOR=XXH_SSE2 -D_CRT_SECURE_NO_WARNINGS -DXXH_STATIC_LINKING_ONLY -DXXH_IMPLEMENTATION -O3 bench_c.c -o bin/bench_c_sse2.exe
clang -march=native -DXXH_VECTOR=XXH_AVX2 -D_CRT_SECURE_NO_WARNINGS -DXXH_STATIC_LINKING_ONLY -DXXH_IMPLEMENTATION -O3 bench_c.c -o bin/bench_c_avx2.exe

:: Compile Jai exes
jai test_scalar.jai -quiet -import_dir ../.. -output_path bin
jai test_sse2.jai -quiet -import_dir ../.. -output_path bin
jai test_avx2.jai -quiet -import_dir ../.. -output_path bin
jai test_check_results.jai -quiet -import_dir ../.. -output_path bin

jai bench_scalar.jai -release -quiet -import_dir ../.. -output_path bin
jai bench_sse2.jai -release -quiet -import_dir ../.. -output_path bin
jai bench_avx2.jai -release -quiet -import_dir ../.. -output_path bin
jai bench_tabulate.jai -release -quiet -import_dir ../.. -output_path bin

:: Run tests and benchmarks, logging to file
bin\\test_c.exe >results/test_c.log
bin\\test_scalar.exe >results/test_scalar.log
bin\\test_sse2.exe >results/test_sse2.log
bin\\test_avx2.exe >results/test_avx2.log
bin\\test_check_results.exe

bin\\bench_scalar.exe >results/bench_scalar.log
bin\\bench_sse2.exe >results/bench_sse2.log
bin\\bench_avx2.exe >results/bench_avx2.log
bin\\bench_c_scalar.exe >results/bench_c_scalar.log
bin\\bench_c_sse2.exe >results/bench_c_sse2.log
bin\\bench_c_avx2.exe >results/bench_c_avx2.log
bin\\bench_tabulate.exe