Tests the scalar/SSE2/AVX2 non-streaming XXH3 implementations on inputs
of various sizes.

In all cases the output is logged to a file, and compared
against reference output from the equivalent C code using
the 'official' xxhash implementation.

The benchmarks similarly compare the non-streaming XXH3 functions
against their C equivalents (built with clang -O3). The results are
tabulated by "bench_tabulate.jai" and saved to "results/bench_table.txt".