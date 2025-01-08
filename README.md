# jai-xxh3

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE.txt)

Native Jai implementation of XXH3.

Based on the original C implementation: https://github.com/Cyan4973/xxHash.

### Features

 - Supports all non-streaming 64-bit and 128-bit hash functions.
 - Supports scalar/SSE2/AVX2 modes via a module parameter.
 - `test` directory contains tests and benchmarks which compare against the equivalent C implementations.

### Usage

 - Import the module, then use any of the public functions:
    - XXH3_64bits
    - XXH3_64bits_withSecret
    - XXH3_64bits_withSeed
    - XXH3_64bits_withSecretandSeed
    - XXH3_128bits
    - XXH3_128bits_withSecret
    - XXH3_128bits_withSeed
    - XXH3_128bits_withSecretandSeed
 - To run tests and benchmarks run test/run_tests.bat on Windows or test/run_tests.sh on Linux. Note: clang is required to build the C versions.

### Performance

The C implementation uses many clever tricks to squeeze out every bit of performance and this version is unlikely to ever match it. The SSE2 variant is performing in-line with what I'd hope, AVX2 seems a bit slow but it's proving harder to optimize with how Jai does inline ASM.

### Benchmark results

Notes on the results:

- Times are for 1k-10m iterations depending on input length, so do not try to compare the times between different lengths. The same input lengths can however be compared between modes.
- Vector modes do nothing for very small inputs (and these results should probably be removed for clarity).

### Benchmark results

XXH3-64bit **[Scalar]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| test_1b | 17.0 | 12.5 | 0.73 |
| test_4b | 18.6 | 12.5 | 0.67 |
| test_9b | 18.7 | 13.0 | 0.70 |
| test_10b | 18.7 | 13.1 | 0.70 |
| test_17b | 20.9 | 14.2 | 0.68 |
| test_32b | 20.9 | 13.4 | 0.64 |
| test_33b | 29.5 | 20.9 | 0.71 |
| test_64b | 28.5 | 21.1 | 0.74 |
| test_65b | 36.2 | 28.5 | 0.79 |
| test_100b | 43.6 | 36.3 | 0.83 |
| test_250b | 152.0 | 130.8 | 0.86 |
| test_1kb | 472.1 | 373.4 | 0.79 |
| test_10kb | 461.5 | 372.9 | 0.81 |
| test_100kb | 457.8 | 386.4 | 0.84 |
| test_1mb | 475.3 | 385.1 | 0.81 |
| test_10mb | 480.5 | 387.5 | 0.81 |

XXH3-128bit **[Scalar]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| test_1b | 24.9 | 21.0 | 0.84 |
| test_4b | 22.7 | 19.1 | 0.84 |
| test_9b | 26.7 | 25.1 | 0.94 |
| test_10b | 26.6 | 24.9 | 0.94 |
| test_17b | 33.9 | 26.7 | 0.79 |
| test_32b | 32.7 | 27.6 | 0.84 |
| test_33b | 42.3 | 36.2 | 0.86 |
| test_64b | 41.9 | 36.2 | 0.87 |
| test_65b | 50.8 | 45.8 | 0.90 |
| test_100b | 59.1 | 54.7 | 0.93 |
| test_250b | 185.4 | 160.5 | 0.87 |
| test_1kb | 507.9 | 430.0 | 0.85 |
| test_10kb | 459.1 | 379.2 | 0.83 |
| test_100kb | 459.0 | 379.6 | 0.83 |
| test_1mb | 470.6 | 388.9 | 0.83 |
| test_10mb | 470.6 | 385.2 | 0.82 |

XXH3-64bit **[SSE2]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| test_250b | 114.0 | 85.9 | 0.75 |
| test_1kb | 290.3 | 267.7 | 0.92 |
| test_10kb | 282.3 | 271.7 | 0.96 |
| test_100kb | 283.8 | 275.3 | 0.97 |
| test_1mb | 303.4 | 279.0 | 0.92 |
| test_10mb | 304.6 | 282.1 | 0.93 |

XXH3-128bit **[SSE2]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| test_250b | 138.3 | 118.3 | 0.86 |
| test_1kb | 327.6 | 300.8 | 0.92 |
| test_10kb | 285.4 | 278.7 | 0.98 |
| test_100kb | 284.0 | 279.9 | 0.99 |
| test_1mb | 330.9 | 278.3 | 0.84 |
| test_10mb | 295.9 | 283.3 | 0.96 |

XXH3-64bit **[AVX2]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| test_250b | 148.0 | 76.1 | 0.51 |
| test_1kb | 262.0 | 165.4 | 0.63 |
| test_10kb | 195.5 | 138.8 | 0.71 |
| test_100kb | 192.4 | 136.8 | 0.71 |
| test_1mb | 201.4 | 138.8 | 0.69 |
| test_10mb | 200.8 | 157.1 | 0.78 |

XXH3-128bit **[AVX2]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| test_250b | 163.7 | 90.9 | 0.56 |
| test_1kb | 281.0 | 183.8 | 0.65 |
| test_10kb | 198.7 | 139.2 | 0.70 |
| test_100kb | 192.7 | 137.4 | 0.71 |
| test_1mb | 210.3 | 145.0 | 0.69 |
| test_10mb | 220.2 | 151.8 | 0.69 |
