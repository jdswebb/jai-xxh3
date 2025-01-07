#import "Basic";
#import "String";
#import "File";

main :: ()
{
    c_results := replace(read_entire_file("results/test_c.log"), "\r", "");
    jai_scalar_results := replace(read_entire_file("results/test_scalar.log"), "\r", "");
    jai_sse2_results := replace(read_entire_file("results/test_sse2.log"), "\r", "");
    jai_avx2_results := replace(read_entire_file("results/test_avx2.log"), "\r", "");
    
    match := equal(c_results, jai_scalar_results);
    match &= equal(c_results, jai_sse2_results);
    match &= equal(c_results, jai_avx2_results);
    
    if (match) {
        print("SUCCESS: All test results match the C reference values\n");
    } else {
        print("FAIL: Not all test results match the C reference values\n");
    }
}