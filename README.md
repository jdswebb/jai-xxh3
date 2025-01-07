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

The SSE2 implementation is closest, only being a few % slower for longer hashes. Small hash lengths, particularly 100b, are performing considerably worse and need investigating.

### Benchmark results

[Note iteration count is not equal between lengths, so they should not be comparsed against eachother]

XXH3-64bit **[Scalar]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| 1b | 16.7 | 12.3 | 0.74 |
| 10b | 21.1 | 12.9 | 0.61 |
| 100b | 8.9 | 3.6 | 0.40 |
| 1kb | 48.3 | 36.9 | 0.76 |
| 10kb | 45.2 | 37.5 | 0.83 |
| 100kb | 44.7 | 37.4 | 0.84 |
| 1mb | 460.5 | 377.5 | 0.82 |
| 10mb | 467.5 | 381.1 | 0.82 |

XXH3-128bit **[Scalar]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| 1b | 22.5 | 21.1 | 0.94 |
| 10b | 38.1 | 24.7 | 0.65 |
| 100b | 10.4 | 6.8 | 0.66 |
| 1kb | 53.5 | 42.6 | 0.80 |
| 10kb | 46.5 | 37.7 | 0.81 |
| 100kb | 44.7 | 36.8 | 0.82 |
| 1mb | 470.9 | 376.0 | 0.80 |
| 10mb | 472.5 | 382.6 | 0.81 |

XXH3-64bit **[SSE2]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| 1b | 17.1 | 12.7 | 0.75 |
| 10b | 23.0 | 12.6 | 0.55 |
| 100b | 8.9 | 3.5 | 0.40 |
| 1kb | 32.2 | 26.4 | 0.82 |
| 10kb | 28.3 | 26.3 | 0.93 |
| 100kb | 27.8 | 26.5 | 0.96 |
| 1mb | 288.1 | 270.9 | 0.94 |
| 10mb | 293.7 | 274.0 | 0.93 |

XXH3-128bit **[SSE2]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| 1b | 22.7 | 20.8 | 0.92 |
| 10b | 37.6 | 23.4 | 0.62 |
| 100b | 11.4 | 5.3 | 0.46 |
| 1kb | 37.7 | 29.5 | 0.78 |
| 10kb | 28.5 | 26.9 | 0.94 |
| 100kb | 28.1 | 26.4 | 0.94 |
| 1mb | 290.5 | 270.1 | 0.93 |
| 10mb | 292.2 | 274.9 | 0.94 |

XXH3-64bit **[AVX2]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| 1b | 16.4 | 12.6 | 0.77 |
| 10b | 22.3 | 12.4 | 0.56 |
| 100b | 9.2 | 3.6 | 0.39 |
| 1kb | 29.7 | 16.2 | 0.54 |
| 10kb | 20.1 | 13.7 | 0.68 |
| 100kb | 18.7 | 13.2 | 0.71 |
| 1mb | 192.1 | 135.4 | 0.71 |
| 10mb | 193.0 | 150.3 | 0.78 |

XXH3-128bit **[AVX2]**:

| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |
| ------ | ------------- | ----------- | -------- |
| 1b | 22.6 | 20.8 | 0.92 |
| 10b | 38.4 | 23.4 | 0.61 |
| 100b | 10.4 | 5.4 | 0.52 |
| 1kb | 33.9 | 17.9 | 0.53 |
| 10kb | 20.3 | 13.6 | 0.67 |
| 100kb | 19.0 | 13.3 | 0.70 |
| 1mb | 190.1 | 134.9 | 0.71 |
| 10mb | 193.5 | 151.0 | 0.78 |
