#import "Basic";
#import "String";
#import "File";

// This whole process is fairly rudimentary for now and not very flexible.

INPUT_LENGTHS :: string.[ 
    "test_1b",
    "test_4b",
    "test_9b",
    "test_10b",
    "test_17b",
    "test_32b",
    "test_33b",
    "test_64b",
    "test_65b",
    "test_100b",
    "test_250b",
    "test_1kb",
    "test_10kb",
    "test_100kb",
    "test_1mb",
    "test_10mb"
    ];

tabulate :: (file_out: *File, name: string, jai_results: []string, c_results: [] string)
{
    // 64-bit rows
    i := 0;
    idx := 0;
    file_write(file_out, tprint("XXH3-64bit **[%]**:\n\n", name));
    file_write(file_out, "| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |\n");
    file_write(file_out, "| ------ | ------------- | ----------- | -------- |\n");
    while i < c_results.count {
        if (equal(jai_results[i], "")) {
            break;
        }
        // Skip vector results for small values
        if !(!equal(name, "Scalar") && (idx < 10)) {
            file_write(file_out, tprint("| % | % | % | % |\n",
                INPUT_LENGTHS[idx],
                FormatFloat.{ value=string_to_float64(jai_results[i]), trailing_width=1, zero_removal=.NO },
                FormatFloat.{ value=string_to_float64(c_results[i]), trailing_width=1, zero_removal=.NO },
                FormatFloat.{ value=string_to_float64(c_results[i]) / string_to_float64(jai_results[i]), trailing_width=2, zero_removal=.NO }
                ));
        }
        i += 2;
        idx += 1;
    }
    
    file_write(file_out, "\n");
    // 128-bit rows
    i = 1;
    idx = 0;
    file_write(file_out, tprint("XXH3-128bit **[%]**:\n\n", name));
    file_write(file_out, "| Length | jai-xxh3 (ms) | xxhash (ms) | Multiple |\n");
    file_write(file_out, "| ------ | ------------- | ----------- | -------- |\n");
    while i < c_results.count {
        if (equal(jai_results[i], "")) {
            break;
        }
        // Skip vector results for small values
        if !(!equal(name, "Scalar") && (idx < 10)) {
            file_write(file_out, tprint("| % | % | % | % |\n",
                INPUT_LENGTHS[idx],
                FormatFloat.{ value=string_to_float64(jai_results[i]), trailing_width=1, zero_removal=.NO },
                FormatFloat.{ value=string_to_float64(c_results[i]), trailing_width=1, zero_removal=.NO },
                FormatFloat.{ value=string_to_float64(c_results[i]) / string_to_float64(jai_results[i]), trailing_width=2, zero_removal=.NO }
                ));
        }
        i += 2;
        idx += 1;
    }
}

main :: ()
{
    c_scalar_data := split(read_entire_file("results/bench_data_c_scalar.txt"), "\n");
    jai_scalar_data := split(read_entire_file("results/bench_data_scalar.txt"), "\n");
    c_sse2_data := split(read_entire_file("results/bench_data_c_sse2.txt"), "\n");
    jai_sse2_data := split(read_entire_file("results/bench_data_sse2.txt"), "\n");
    c_avx2_data := split(read_entire_file("results/bench_data_c_avx2.txt"), "\n");
    jai_avx2_data := split(read_entire_file("results/bench_data_avx2.txt"), "\n");
    
    assert(c_scalar_data.count == jai_scalar_data.count);
    assert(c_sse2_data.count == jai_sse2_data.count);
    assert(c_avx2_data.count == jai_avx2_data.count);
    
    file_out, success := file_open("results/bench_table.txt", for_writing=true, keep_existing_content=false);
    file_write(*file_out, "### Benchmark results\n\n");
    assert(success);
    defer file_close(*file_out);
    tabulate(*file_out, "Scalar", jai_scalar_data, c_scalar_data);
    file_write(*file_out, "\n");
    tabulate(*file_out, "SSE2", jai_sse2_data, c_sse2_data);
    file_write(*file_out, "\n");
    tabulate(*file_out, "AVX2", jai_avx2_data, c_avx2_data);
}