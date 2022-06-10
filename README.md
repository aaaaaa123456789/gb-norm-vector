# GB Vector Normalization Library

This repository provides an assembly library for the Game Boy and Game Boy Color that will normalize an input vector
to a user-defined length.

The library is available in the [`normvector.asm`](normvector.asm) file, and it requires [RGBDS] version 0.5.0 or
newer (0.5.1 required for the test ROM).
Other files of interest in the repository are:

- [`test.asm`](test.asm): TPP1-based test ROM that will generate a 2 MB save file containing results for a large
  number of executions.
  Used to test the library.
  The test ROM will also execute the `NormalizeVector` function early on during initialization (discarding the result)
  to facilitate quick debugging.
- [`Makefile`](Makefile): makefile to build the test ROM.
- [`generator.c`](generator.c): C program used to generate the unit vectors lookup table in the library; included for
  completeness and ease of verification.
- (test results TBD)

Everything in this repository is released to the public domain under [the Unlicense](LICENSE).

## Usage

The library exposes a single function, `NormalizeVector`, in its own section in a ROMX bank.
In order to use it, add the [`normvector.asm`](normvector.asm) file to your project.

`NormalizeVector` takes in a vector in (`bc`, `de`), which is a pair of 16-bit signed values (integers or any fixed
point: it makes no difference), and a desired length in `a` (with 0 meaning `$100`).
The function returns the normalized vector in (`bc`, `de`), in 8.8 signed fixed point; coordinates will have the same
sign as their respective inputs.
If the input vector is the null vector (i.e., `bc` = `de` = 0), the function returns a null vector and the zero flag
set, as the null vector cannot be normalized; otherwise, the zero flag will be cleared.
The function will preserve the value of `hl`.

Note that overflow may occur if `a` is greater than `$7F`.
However, if both inputs are non-negative, the output can be treated as unsigned, which solves the overflow problem:
the only way unsigned overflow can occur is if `a` is zero and one of the coordinates is also zero (because the
normalized vector would be (`$10000`, `$0000`) in that case).

## Performance and accuracy

(TBD, pending test results)

## Motivation

It is often necessary to move an object towards a target with a specific speed: for instance, a projectile might begin
travelling towards its target at a certain speed, requiring computation of its velocity vector.
A similar use case is drawing a short line aiming towards a target: that line's length will often be constant and
independent of how far away the target is, which requires normalizing the distance vector in order to calculate the
line's end point.

Many similar use cases depend on being able to normalize a vector, that is, compute a unit vector pointing in the same
direction.
But the computation for that is norm(x, y) = (x / √(x² + y²), y / √(x² + y²)).
This calculation is not easy for the GB to perform, which is why this library uses a numerical approximation.
Numerical approximations for this calculation are generally complex to perform accurately, which is what motivated the
creation of this library; the library will handle that complexity and return a reasonably precise result.

Vector normalization, in principle, returns a unit vector: a vector of length 1.
A vector of any other length can be obtained from there via multiplication; however, that approach loses a lot of
precision.
Therefore, this library allows the user to choose the desired length, and performs the multiplication internally at a
higher precision before reducing and returning the normalized vector.

[RGBDS]: https://github.com/gbdev/rgbds
