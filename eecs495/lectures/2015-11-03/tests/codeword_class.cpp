#include "codeword_class/codeword.hpp"
#include <UnitTest++/UnitTest++.h>

namespace codeword_class
{

TEST(Initialize)
{
    codeword cw;
    (void) cw;
}

TEST(InitList)
{
    codeword cw{4, 12};
    CHECK_EQUAL(4ul, cw.length());
    CHECK_EQUAL(12ul, cw.bits());
}

TEST(Equals)
{
    codeword cw1{4, 12};
    codeword cw2{4, 12};
    CHECK(cw1 == cw2);
}

TEST(LengthNotEquals)
{
    codeword cw1{4, 12};
    codeword cw2{5, 12};
    CHECK(cw1 != cw2);
}

TEST(BitsNotEquals)
{
    codeword cw1{5, 13};
    codeword cw2{5, 12};
    CHECK(cw1 != cw2);
}

TEST(IsFullFalse)
{
    codeword cw{12, 8};
    CHECK(!is_full(cw));
}

TEST(IsFullTrue)
{
    codeword cw{CHAR_BIT * sizeof cw.bits(), 8};
    CHECK(is_full(cw));
}

TEST(FormatLeading0)
{
    codeword cw{12, 5};
    CHECK_EQUAL("000000000101", format(cw));
}

TEST(FormatLeading1)
{
    codeword cw{12, 2048 + 256 + 4};
    CHECK_EQUAL("100100000100", format(cw));
}

TEST(FormatEmpty)
{
    codeword cw;
    CHECK_EQUAL("", format(cw));
}

TEST(ExtendEmptyWith0)
{
    auto cw = extend(codeword{}, false);
    CHECK_EQUAL(1ul, cw.length());
    CHECK_EQUAL(0ul, cw.bits());
}

TEST(ExtendEmptyWith1)
{
    auto cw = extend(codeword{}, true);
    CHECK_EQUAL(1ul, cw.length());
    CHECK_EQUAL(1ul, cw.bits());
}

TEST(ExtendLeading0With0)
{
    auto cw = extend(codeword{8, 3}, false);
    CHECK_EQUAL(9ul, cw.length());
    CHECK_EQUAL(6ul, cw.bits());
}

TEST(ExtendLeading0With1)
{
    auto cw = extend(codeword{8, 3}, true);
    CHECK_EQUAL(9ul, cw.length());
    CHECK_EQUAL(7ul, cw.bits());
}

TEST(ExtendLeading1With0)
{
    auto cw = extend(codeword{8, 131}, false); // 10000011
    CHECK_EQUAL(9ul, cw.length());
    CHECK_EQUAL(262ul, cw.bits());
}

TEST(ExtendLeading1With1)
{
    auto cw = extend(codeword{8, 131}, true); // 10000011
    CHECK_EQUAL(9ul, cw.length());
    CHECK_EQUAL(263ul, cw.bits());
}

} // namespace codeword_class

int main(int, const char*[])
{
    return UnitTest::RunAllTests();
}
