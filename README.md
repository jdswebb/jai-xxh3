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

XXH3-64bit **[Scalar]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| 1b | 17.1 | 12.8 | 0.75 |
| 10b | 19.3 | 13.2 | 0.68 |
| 100b | 4.3 | 3.9 | 0.91 |
| 1kb | 46.8 | 37.3 | 0.80 |
| 10kb | 45.5 | 37.2 | 0.82 |
| 100kb | 45.5 | 37.4 | 0.82 |
| 1mb | 471.9 | 388.1 | 0.82 |
| 10mb | 478.7 | 393.5 | 0.82 |

XXH3-128bit **[Scalar]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| 1b | 25.0 | 21.1 | 0.85 |
| 10b | 26.7 | 25.4 | 0.95 |
| 100b | 6.0 | 5.6 | 0.92 |
| 1kb | 50.6 | 42.8 | 0.85 |
| 10kb | 48.3 | 37.8 | 0.78 |
| 100kb | 45.5 | 37.4 | 0.82 |
| 1mb | 469.7 | 391.0 | 0.83 |
| 10mb | 470.5 | 388.7 | 0.83 |

XXH3-64bit **[SSE2]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| 1b | 17.1 | 13.4 | 0.78 |
| 10b | 18.9 | 12.8 | 0.68 |
| 100b | 4.4 | 3.6 | 0.83 |
| 1kb | 28.7 | 26.9 | 0.94 |
| 10kb | 28.1 | 26.8 | 0.95 |
| 100kb | 28.4 | 26.8 | 0.94 |
| 1mb | 296.9 | 280.8 | 0.95 |
| 10mb | 294.2 | 282.7 | 0.96 |

XXH3-128bit **[SSE2]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| 1b | 25.0 | 21.2 | 0.85 |
| 10b | 27.1 | 24.0 | 0.89 |
| 100b | 5.9 | 5.4 | 0.91 |
| 1kb | 32.6 | 30.0 | 0.92 |
| 10kb | 28.5 | 27.1 | 0.95 |
| 100kb | 28.6 | 27.0 | 0.94 |
| 1mb | 299.7 | 278.9 | 0.93 |
| 10mb | 304.0 | 281.7 | 0.93 |

XXH3-64bit **[AVX2]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| 1b | 18.1 | 12.8 | 0.71 |
| 10b | 18.9 | 12.8 | 0.68 |
| 100b | 4.6 | 3.6 | 0.78 |
| 1kb | 26.2 | 16.7 | 0.64 |
| 10kb | 20.2 | 13.9 | 0.69 |
| 100kb | 19.1 | 13.6 | 0.71 |
| 1mb | 200.2 | 139.1 | 0.69 |
| 10mb | 198.6 | 150.9 | 0.76 |

XXH3-128bit **[AVX2]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| 1b | 24.8 | 21.1 | 0.85 |
| 10b | 26.6 | 23.8 | 0.89 |
| 100b | 6.0 | 5.4 | 0.90 |
| 1kb | 28.2 | 18.3 | 0.65 |
| 10kb | 20.4 | 13.9 | 0.68 |
| 100kb | 19.1 | 13.6 | 0.71 |
| 1mb | 196.9 | 142.2 | 0.72 |
| 10mb | 199.1 | 151.3 | 0.76 |

