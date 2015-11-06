#include "binheap_template/binheap_template.hpp"
#include "binheap_template/key_val.hpp"
#include <UnitTest++/UnitTest++.h>
#include <cstdlib>
#include <iostream>
#include <string>

namespace binheap_template
{

   TEST(Create)
  {
    binheap<int> bh;
    (void) bh;
  }
  
  TEST(AddRemove)
  {
    binheap<int> bh;
    CHECK(bh.isEmpty());
    bh.add(1);
    CHECK(!bh.isEmpty());
    CHECK_EQUAL(bh.getMin(), 1);
    bh.removeMin();
    CHECK(bh.isEmpty());
  }

  TEST(AddRemove2)
  {
    binheap<int> bh;
    CHECK(bh.isEmpty());
    bh.add(1);
    CHECK(!bh.isEmpty());
    CHECK_EQUAL(bh.getMin(), 1);
    bh.add(2);
    bh.add(-1);
    CHECK_EQUAL(bh.getMin(), -1);
    bh.removeMin();
    CHECK_EQUAL(bh.getMin(), 1);
    bh.removeMin();
    CHECK_EQUAL(bh.getMin(), 2);
    bh.removeMin();
    CHECK(bh.isEmpty());
  } 

  TEST(AddRemove3)
  {
    binheap<int> bh;
    for(int i = 100; i >= 0; i -= 2) {
      bh.add(i);
      CHECK_EQUAL(bh.getMin(), i);
    }
    for(int i = 1; i < 100; i += 2) {
      bh.add(i);
    }
    for(int i = 0; i <= 100; i++) {
      CHECK_EQUAL(bh.getMin(), i);
      bh.removeMin();
    }
    CHECK(bh.isEmpty());
  }
  
  
  TEST(RandAddRemove)
  {

    binheap<int> bh;
    for(int i = 0; i < 100; i++) {
      int next = rand();
      bh.add(next);
    }

    int last = bh.getMin();
    while (!bh.isEmpty()) {
      CHECK(bh.getMin() >= last);
      last = bh.getMin();
      bh.removeMin();
    }

  }

  TEST(Strings)
  {
    binheap<std::string> bh;
    bh.add("abc");
    bh.add("aaa");
    bh.add("b");
    CHECK(bh.getMin() == "aaa");
    bh.removeMin();
    CHECK(bh.getMin() == "abc");
    bh.removeMin();
    CHECK(bh.getMin() == "b");
    bh.removeMin();
    CHECK(bh.isEmpty());
  }

  TEST(PAIRS)
  {
    typedef pair<int,std::string> isp;
    binheap<isp> bh;
    isp p1{1, "one"};
    isp p2{2, "two"};
    isp pn1{-1, "negative one"};
    isp p5{5, "five"};
    bh.add(p1);
    bh.add(p2);
    bh.add(pn1);
    bh.add(p5);
    CHECK(bh.getMin() == pn1);
    bh.removeMin();
    CHECK(bh.getMin() == p1);
    bh.removeMin();
    CHECK(bh.getMin() == p2);
    bh.removeMin();
    CHECK(bh.getMin() == p5);
    bh.removeMin();    
    CHECK(bh.isEmpty());
  }
  
    TEST(Sort)
  {
    std::vector<int> v1{3, 2, 5, 4, 1};
    std::vector<int> v2{5, 4, 3, 2, 1};
    CHECK(heapsort<int>(v1) == v2);
  }

  TEST(Sort2)
  {
    
    std::vector<int> v1{-1, -1, -10, 22, 7};
    std::vector<int> v2{22, 7, -1, -1, -10};
    CHECK(heapsort<int>(v1) == v2);
  }

  TEST(Sort3)
  {
    
    std::vector<int> v1{1, 7, 7, 7, 3, 3};
    std::vector<int> v2{7, 7, 7, 3, 3, 1};
    CHECK(heapsort<int>(v1) == v2);
  }

} // namespace binheap_template

int
main(int, const char*[])
{
    return UnitTest::RunAllTests();
}
