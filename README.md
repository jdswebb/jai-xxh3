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

### Benchmark results

XXH3-64bit **[Scalar]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| 1b | 17.2 | 12.5 | 0.73 |
| 4b | 18.5 | 12.4 | 0.67 |
| 9b | 19.4 | 13.1 | 0.67 |
| 10b | 18.9 | 13.1 | 0.69 |
| 17b | 21.1 | 14.1 | 0.67 |
| 32b | 21.0 | 13.6 | 0.65 |
| 33b | 29.1 | 21.2 | 0.73 |
| 64b | 28.8 | 21.2 | 0.74 |
| 65b | 36.1 | 28.5 | 0.79 |
| 100b | 43.8 | 36.6 | 0.84 |
| 250b | 157.4 | 121.0 | 0.77 |
| 1kb | 468.9 | 373.2 | 0.80 |
| 10kb | 457.2 | 373.6 | 0.82 |
| 100kb | 455.7 | 373.5 | 0.82 |
| 1mb | 470.5 | 386.3 | 0.82 |
| 10mb | 473.4 | 384.8 | 0.81 |

XXH3-128bit **[Scalar]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| 1b | 24.8 | 21.5 | 0.87 |
| 4b | 23.2 | 19.2 | 0.83 |
| 9b | 29.1 | 24.9 | 0.86 |
| 10b | 26.8 | 25.1 | 0.94 |
| 17b | 32.9 | 26.8 | 0.82 |
| 32b | 32.7 | 26.7 | 0.82 |
| 33b | 41.9 | 36.3 | 0.87 |
| 64b | 42.8 | 36.6 | 0.85 |
| 65b | 50.9 | 45.2 | 0.89 |
| 100b | 61.3 | 54.3 | 0.88 |
| 250b | 186.4 | 161.5 | 0.87 |
| 1kb | 505.8 | 428.7 | 0.85 |
| 10kb | 459.1 | 379.0 | 0.83 |
| 100kb | 455.7 | 376.3 | 0.83 |
| 1mb | 470.1 | 386.7 | 0.82 |
| 10mb | 523.2 | 387.5 | 0.74 |

XXH3-64bit **[SSE2]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| 250b | 101.4 | 85.1 | 0.84 |
| 1kb | 285.2 | 278.9 | 0.98 |
| 10kb | 281.9 | 268.4 | 0.95 |
| 100kb | 284.8 | 268.8 | 0.94 |
| 1mb | 304.4 | 276.6 | 0.91 |
| 10mb | 321.2 | 278.9 | 0.87 |

XXH3-128bit **[SSE2]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| 250b | 139.8 | 119.1 | 0.85 |
| 1kb | 326.5 | 300.6 | 0.92 |
| 10kb | 285.8 | 271.6 | 0.95 |
| 100kb | 286.3 | 270.3 | 0.94 |
| 1mb | 293.5 | 277.9 | 0.95 |
| 10mb | 294.7 | 281.3 | 0.95 |

XXH3-64bit **[AVX2]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| 250b | 147.9 | 75.4 | 0.51 |
| 1kb | 263.4 | 166.7 | 0.63 |
| 10kb | 199.3 | 140.2 | 0.70 |
| 100kb | 192.2 | 136.5 | 0.71 |
| 1mb | 195.2 | 140.5 | 0.72 |
| 10mb | 197.6 | 153.5 | 0.78 |

XXH3-128bit **[AVX2]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| 250b | 164.0 | 92.5 | 0.56 |
| 1kb | 281.1 | 183.2 | 0.65 |
| 10kb | 199.1 | 139.9 | 0.70 |
| 100kb | 190.8 | 136.8 | 0.72 |
| 1mb | 196.4 | 138.7 | 0.71 |
| 10mb | 198.3 | 152.5 | 0.77 |

