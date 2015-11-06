#include "codeword.hpp"

#include <climits>

#include "gsl/gsl.h"

namespace codeword_struct
{

codeword
extend(codeword old, bool bit)
{
    Expects(!is_full(old));

    return codeword{old.length + 1, (old.bits << 1) + bit};
}

bool
is_full(codeword word)
{
    return word.length == CHAR_BIT * sizeof word.bits;
}

bool
operator==(codeword word1, codeword word2)
{
    return word1.length == word2.length
        && word1.bits == word2.bits;
}

std::string
format(codeword word)
{
    std::string result;
    
    for (size_t index = 0; index < word.length; ++index)
    {
        auto mask = 1 << (word.length - index - 1);
        
        if (word.bits & mask)
            result += '1';
        else
            result += '0';
    }
    
    return result;
}

}  // namespace codeword_struct
