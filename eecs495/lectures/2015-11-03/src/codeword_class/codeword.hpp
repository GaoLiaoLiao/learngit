#pragma once

#include <cstddef>
#include <string>

namespace codeword_class
{

// Represents a variable-length binary codeword.
//
// Interpretation: the sequence of `length` bits stored in the
// low-order bits of `bits`.
class codeword {
public:
    // Constructs a codeword from the length and bits.
    //
    // Precondition:
    //  - length <= CHAR_BIT * sizeof bits
    //  - if (length != CHAR_BIT * sizeof bits)
    //      bits < (1 << length)
    codeword(size_t length, unsigned long bits);

    // Constructs an empty codeword.
    codeword() : codeword{0, 0}
    { }

    size_t length() { return length_; }
    unsigned long bits() { return bits_; }

private:
    size_t length_;
    unsigned long bits_;
};

// Extends a codeword by a bit on the right.
// Expects: codeword is not full
//
// Examples:
//  - extend(1001, false) => 10010
//  - extend(1001, true)  => 10011
codeword extend(codeword, bool);

// Checks whether a codeword is full.
//
// Examples:
//  - is_full(0110)  => false
//  - is_full(w) whose length is the number of bits
//    in unsigned long => true
bool is_full(codeword);

// Checks whether two codewords are equal.
bool operator==(codeword, codeword);

// Checks whether two codewords are not equal.
bool operator!=(codeword, codeword);

// Formats a codeword as a string of '0' and '1'.
//
// Example:
//  - format(01101) => "01101"
std::string format(codeword);

} // namespace codeword_class
