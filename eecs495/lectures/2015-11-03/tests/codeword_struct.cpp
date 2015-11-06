#include "codeword_struct/codeword.hpp"
#include <UnitTest++/UnitTest++.h>

namespace codeword_struct
{

// These define types length_t and bits_t to be the types of the length
// and bits fields of codeword, so that we don't have to hardcode those
// types in this file (and don't just assume they're unsigned long).
using length_t = decltype(codeword{}.length);
using bits_t   = decltype(codeword{}.bits);

// Lets us write length_t literals like 5_L.
constexpr length_t operator""_L(unsigned long long size)
{ return static_cast<length_t>(size); }

// Lets us write bits_t literals like 5_B or 0b101_B
constexpr bits_t operator""_B(unsigned long long bits)
{ return static_cast<bits_t>(bits); }

TEST(Create)
{
    codeword cw;
    (void) cw;
}

TEST(DefaultInit)
{
    codeword cw;
    CHECK_EQUAL(0_L, cw.length);
    CHECK_EQUAL(0_B, cw.bits);
}

TEST(InitList)
{
    codeword cw{4, 9};
    CHECK_EQUAL(4_L, cw.length);
    CHECK_EQUAL(0b1001_B, cw.bits);
}

TEST(Equals)
{
    codeword cw1{4, 0b101};
    codeword cw2{4, 0b101};
    CHECK(cw1 == cw2);
}

TEST(Extend0Leading1)
{
    auto cw = extend(codeword{4, 0b1001}, false);
    CHECK_EQUAL(5_L, cw.length);
    CHECK_EQUAL(0b10010_B, cw.bits);
}

TEST(Extend1Leading1)
{
    auto cw = extend(codeword{4, 9}, true);
    CHECK_EQUAL(5_L, cw.length);
    CHECK_EQUAL(0b10011_B, cw.bits);
}

TEST(Extend0Leading0)
{
    auto cw = extend(codeword{5, 9}, false);
    CHECK_EQUAL(6_L, cw.length);
    CHECK_EQUAL(0b10010_B, cw.bits);
}

TEST(Extend1Leading0)
{
    auto cw = extend(codeword{5, 9}, true);
    CHECK_EQUAL(6_L, cw.length);
    CHECK_EQUAL(0b10011_B, cw.bits);
}

TEST(ExtendEmpty0)
{
    auto cw = extend(codeword{}, false);
    CHECK_EQUAL(1_L, cw.length);
    CHECK_EQUAL(0b0_B, cw.bits);
}

TEST(ExtendEmpty1)
{
    auto cw = extend(codeword{}, true);
    CHECK_EQUAL(1_L, cw.length);
    CHECK_EQUAL(0b1_B, cw.bits);
}

TEST(FormatEmpty)
{
    CHECK_EQUAL("", format(codeword{}));
}

TEST(FormatLeading1)
{
    CHECK_EQUAL("10000011", format(codeword{8, 0b10000011}));
}

TEST(FormatLeading0)
{
    CHECK_EQUAL("01000010", format(codeword{8, 0b1000010}));
}

} // namespace codeword_struct

int
main(int, const char*[])
{
    return UnitTest::RunAllTests();
}
