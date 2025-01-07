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

The C implementation uses many clever tricks to squeeze out every bit of performance and this version is unlikely to ever match it.

The SSE2 implementation is closest, only being a few % slower for longer hashes. There are some outlier bad performers to investigate:

- Small hash lengths, particularly 100b, are performing considerably worse.
- AVX2 is performing slightly worse than SSE2 (!) - it should be roughly twice as fast instead.

### Benchmark results

[Note iteration count is not equal between lengths, so they should not be comparsed against eachother]

XXH3-64bit **[Scalar]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| 1b | 16.5 | 12.4 | 0.75 |
| 10b | 21.3 | 12.8 | 0.60 |
| 100b | 9.2 | 3.6 | 0.39 |
| 1kb | 49.0 | 36.9 | 0.75 |
| 10kb | 45.3 | 36.7 | 0.81 |
| 100kb | 45.2 | 36.9 | 0.82 |
| 1mb | 464.8 | 376.9 | 0.81 |
| 10mb | 476.1 | 380.0 | 0.80 |

XXH3-128bit **[Scalar]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| 1b | 23.0 | 20.8 | 0.91 |
| 10b | 38.6 | 24.8 | 0.64 |
| 100b | 10.7 | 5.5 | 0.52 |
| 1kb | 54.4 | 43.2 | 0.79 |
| 10kb | 46.5 | 37.0 | 0.80 |
| 100kb | 45.3 | 36.7 | 0.81 |
| 1mb | 471.4 | 376.7 | 0.80 |
| 10mb | 470.4 | 381.2 | 0.81 |

XXH3-64bit **[SSE2]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| 1b | 16.8 | 12.7 | 0.76 |
| 10b | 21.3 | 13.1 | 0.61 |
| 100b | 9.0 | 3.6 | 0.40 |
| 1kb | 32.2 | 26.7 | 0.83 |
| 10kb | 28.4 | 26.3 | 0.93 |
| 100kb | 28.0 | 26.5 | 0.94 |
| 1mb | 293.8 | 271.8 | 0.93 |
| 10mb | 296.4 | 278.8 | 0.94 |

XXH3-128bit **[SSE2]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| 1b | 22.6 | 20.5 | 0.91 |
| 10b | 37.5 | 23.4 | 0.62 |
| 100b | 10.6 | 5.5 | 0.51 |
| 1kb | 37.8 | 29.7 | 0.78 |
| 10kb | 28.8 | 26.5 | 0.92 |
| 100kb | 28.4 | 26.3 | 0.93 |
| 1mb | 293.1 | 275.5 | 0.94 |
| 10mb | 300.6 | 275.7 | 0.92 |

XXH3-64bit **[AVX2]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| 1b | 17.0 | 12.7 | 0.74 |
| 10b | 21.1 | 12.5 | 0.59 |
| 100b | 9.4 | 3.8 | 0.40 |
| 1kb | 41.5 | 16.4 | 0.39 |
| 10kb | 31.0 | 13.7 | 0.44 |
| 100kb | 30.5 | 13.7 | 0.45 |
| 1mb | 315.4 | 138.4 | 0.44 |
| 10mb | 313.7 | 149.7 | 0.48 |

XXH3-128bit **[AVX2]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| 1b | 22.9 | 20.8 | 0.91 |
| 10b | 38.8 | 23.9 | 0.62 |
| 100b | 10.8 | 5.4 | 0.50 |
| 1kb | 44.4 | 18.2 | 0.41 |
| 10kb | 31.7 | 13.8 | 0.44 |
| 100kb | 30.4 | 13.5 | 0.44 |
| 1mb | 315.4 | 138.2 | 0.44 |
| 10mb | 315.1 | 146.5 | 0.46 |
