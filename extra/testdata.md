# Library test results

This file documents the library testing results, from which precision and performance data was derived, as well as the
raw testing data available in the repository for further perusal and analysis.

- [Tests executed](#tests-executed)
- [Input bits](#input-bits)
- [Precision metrics](#precision-metrics)
- [Performance metrics](#performance-metrics)
- [Raw test output](#raw-test-output)
    - [Data description](#data-description)
    - [Data columns](#data-columns)
    - [Rating categories](#rating-categories)

## Tests executed

Besides the obvious functional testing, the library was tested via a simulation of the CPU by iterating over all
possible inputs.
This test was instrumented to count cycles, thus allowing performance data to also be extracted.
All 2<sup>40</sup> possible inputs were tested and their corresponding outputs compared against expected values.

Since the tests were run in a CPU simulator, they were unaffected by other parts of the GB/GBC hardware: the simulator
will never raise interrupts, it does not simulate banking or memory inaccesibility, it has no I/O, and it treats the
entire addressing space as read/write.
However, as the code under test is purely mathematical code that doesn't interact with the rest of the Game Boy
hardware, these limitations simply ensure that the tests run without interference.

All tests were run using code built in GBC mode: that is, allowing `inc` over 16-bit registers with arbitrary values.
In DMG mode, these operations are replaced by a small routine that is two cycles slower.
These operations are executed once on each negative input and output and twice on internal data.
Therefore, in DMG mode, execution is 4 cycles slower, plus an additional 4 cycles for each negative input.

## Input bits

Coordinate inputs are grouped by the number of bits in them.
The number of bits in the input is the number of bits in the widest of the two coordinates.

The number of bits in a value is the number of non-zero trailing bits it has in its absolute value.
For example, `$0022` and `$0030` both have 6 bits, and so does `$FFE0` (since its absolute value is `$0020`).

Since both inputs are normalized to 10 significant bits before processing, wider inputs will result in rounding.
For instance, an input of `bc` = `$1234`, `de` = `$FFDD` is 13 bits wide (because the widest value is 13 bits long),
and thus it will be rounded and shifted down by 3 bits to `$0247`, `$FFFC` (which is equivalent to an unshifted input
of `$1238`, `$FFE0`).

This rounding is the most significant cause of errors for values over 10 bits long.
However, the rounding will only affect values that actually have more than 10 significant bits: for example, an input
of `bc` = `$0003`, `de` = `$FFFC` will be unaffected, since it's only 3 bits long; likewise, an input of `bc` =
`$3000`, `de` = `$C000` will be unaffected and will behave identically to the former case, since it won't be modified
by rounding it to 10 significant bits.

## Precision metrics

WIP

## Performance metrics

WIP

## Raw test output

Test output is available in the [`testdata.csv`](testdata.csv) file, in a format described here.

### Data description

The test data contains summarized test results for each size value; while all possible inputs are tested, they are
grouped by size since it would take an inordinate amount of space to store all results.
Inputs are further grouped by their [input bits](#input-bits); inputs narrower than 5 bits are grouped together with
5-bit inputs for simplicity, since they have similar output characteristics and they represent a very small portion of
the input space.

For each combination of input bits and size, a number of different [ratings](#rating-categories) are measured.
The data set contains both the average value for each rating and the worst case for that combination of size and bits.

Averages are cumulative over smaller number of bits: for instance, the average angular error for 9 bits for a specific
size includes all test cases below 9 bits as well.
On the other hand, worst cases only include test cases with exactly the specified number of bits (with the caveat that
the 5 bits category will include smaller inputs, as explained above).
This is simply because including smaller cases as well can only result in duplicate rows; the actual worst value for
some combination of bits and size can be found merely by filtering and sorting the output.

The output columns can be grouped into two groups.
The first few columns indicate the category (size, bits, rating) and the average value measured for that category; the
rest of the columns indicate all the measured values for the single worst value in that category.
(The `size` column naturally belongs to both, since it's both an input value and part of the grouping criteria;
therefore, this column appears in the middle of the dataset.)

Some columns contain hexadecimal values; those are noted by "(hex)" below.
Those values are always preceded with `0x` to ensure they aren't accidentally parsed as decimal integers.
Other columns contain floating point values or integers; those are respectively indicated by "(float)" or "(int)".
The `rating` column contains a string, which is one of the [rating categories](#rating-categories) listed below.

### Data columns

The category-wide columns are:

- `bits` (int): number of bits in the inputs considered for this row.
- `rating`: [rating category](#rating-categories) being measured; the average is measured for this value, and the rest
  of the columns represent the worst case for this category.
- `average` (float): average value measured for the indicated rating.
- `size` (hex): input value for the normalized vector size.

The worst case columns represent the worst case measured for that category, if any; all measurements are indicated for
that case, even though it is only the worst for the specified [rating](#rating-categories).
These columns (without repeating the `size` column) are:

- `inX`, `inY` (hex): input vector.
- `outX`, `outY` (hex): normalized output vector, as computed by the library.
- `expX`, `expY` (hex): expected output vector, i.e., the ideal value that would be computed by an exact calculation
  at this accuracy.
- `exactX`, `exactY` (float): the exact, unrounded normalized vector as a floating point value.
  This value will be different from `expX`, `expY` because the latter will have been rounded to 8.8 fixed point (and,
  for larger size values, occasionally truncated to fit).
- `diff` (int): overall difference between the output values and the expected values, i.e., the sum of the absolute
  differences between `expX` and `outX` and between `expY` and `outY`.
  A value of zero indicates an all-bits-correct output.
- `errsize` (float): relative size error of the output vector, as a percentage.
  This is calculated as the percentage difference between the actual size of the vector indicated by `outX`, `outY`
  (after adjusting the values for overflow when necessary) and the intended size as indicated in `size`.
- `errangle` (float): angular error of the output vector, in arcseconds (i.e., 1/3600 of a degree).
  This is the angle formed between the input vector and the output vector.
  A value of zero indicates that the vectors align perfectly (as expected, because normalizing a vector should only
  change its length).
- `errscore` (float): sum of size and angular errors, as a percentage.
  Calculated as `errsize + errangle / 12960`.
  This value is only intended to be used to compare test cases with different size and angular errors in order to find
  a single "worst" case.
- `cycles` (int): number of CPU cycles spent computing the normalized vector.
  This is measured for the entire function, up to and including the final `ret` instruction.

### Rating categories

Average and worst values are calculated for the following categories, each corresponding to one of the columns
detailed above (which is the value being averaged or maximized):

|Category|Column     |
|:-------|:----------|
|`score` |`errscore` |
|`size`  |`errsize`  |
|`angle` |`errangle` |
|`diff`  |`diff`     |
|`cycles`|`cycles`   |
|`exact` |(see below)|

The `exact` category is special, because it measures the number of cases that give all-bits-correct results.
The average value for that category is the percentage of test cases that resulted in an all-bits-correct result (i.e.,
cases where `diff` = 0).
The worst case for that category is the highest-scoring test case that still results in an all-bits-correct output;
this can be used to measure the amount of fractional error concealed by rounding the output to the nearest 8.8 fixed
point value.

If all test cases for a certain category result in all-bits-correct results, there will be no worst case for the
`diff` category.
In that case, the data for the worst case for that row will be set to all zeros.
