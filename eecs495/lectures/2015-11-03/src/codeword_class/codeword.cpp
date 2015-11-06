#include "codeword.hpp"

#include <climits>

#include "gsl/gsl.h"

namespace codeword_class
{

// Invariant for class codeword:
//  - length <= CHAR_BIT * sizeof bits
//  - if length != CHAR_BIT * sizeof bits
//      then bits < (1 << length)

codeword::codeword(size_t length, unsigned long bits)
    : length_{length}, bits_{bits}
{
    Expects(length <= CHAR_BIT * sizeof bits);

    if (length != CHAR_BIT * sizeof bits)
        Expects(bits < (1 << length));
}

// Strategy: structural decomposition
bool operator==(codeword cw1, codeword cw2)
{
    return cw1.length() == cw2.length() && cw1.bits() == cw2.bits();
}

// Strategy: function composition
bool operator!=(codeword cw1, codeword cw2)
{
    return !(cw1 == cw2);
}

// Strategy: structural decomposition
bool is_full(codeword cw)
{
    return cw.length() == CHAR_BIT * sizeof(cw.bits());
}

// Strategy: structural decomposition
std::string format(codeword cw)
{
    std::string result;

    auto mask = 1 << (cw.length() - 1);

    for (size_t index = 0; index < cw.length(); ++index) {
        if (cw.bits() & mask)
            result += '1';
        else
            result += '0';

        mask >>= 1;
    }

    return result;
}

codeword extend(codeword old, bool bit)
{
    Expects(!is_full(old));

    return codeword{old.length() + 1, (old.bits() << 1) + bit};
}

} // namespace codeword_class
