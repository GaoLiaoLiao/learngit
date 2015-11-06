#pragma once

#include <cstddef>
#include <string>

namespace codeword_struct
{

struct codeword {
    size_t length      = 0;
    unsigned long bits = 0;
};

codeword
extend(codeword, bool);

bool
is_full(codeword);
    
bool
operator==(codeword, codeword);

std::string
format(codeword);

}  // namespace codeword_struct
