#include "binheap/binheap.hpp"
#include <UnitTest++/UnitTest++.h>
#include <cstdlib>
#include <iostream>

namespace binheap
{

  TEST(Vector0)
  {
    std::vector<int> v;
    CHECK(v.empty());
    v.push_back(0);
    CHECK(!v.empty());
  }

  TEST(Vector1)
  {
    std::vector<int> v1{1, 2};
    std::vector<int> v2{1, 2, 3};
    v1.push_back(3);
    CHECK(v1 == v2);
  }
  
  TEST(Vector2)
  {
    std::vector<int> v1{1, 2};
    std::vector<int> v2{1, 2, 3};
    v2.pop_back();
    CHECK(v1 == v2);
  }

   TEST(Create)
  {
    binheap bh;
    (void) bh;
  }

  TEST(AddRemove)
  {
    binheap bh;
    CHECK(bh.isEmpty());
    bh.add(1);
    CHECK(!bh.isEmpty());
    CHECK_EQUAL(bh.getMin(), 1);
    bh.removeMin();
    CHECK(bh.isEmpty());
  }

  TEST(AddRemove2)
  {
    binheap bh;
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
    binheap bh;
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

    binheap bh;
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

  TEST(Sort)
  {
    std::vector<int> v1{3, 2, 5, 4, 1};
    std::vector<int> v2{5, 4, 3, 2, 1};
    /*
    for (std::vector<int>::const_iterator i = v1.begin(); i != v1.end(); ++i)
      std::cout << *i << ' ';
    std::cout << "\n";
    std::vector<int> v3 = heapsort(v1);
    for (std::vector<int>::const_iterator i = v3.begin(); i != v3.end(); ++i)
      std::cout << *i << ' ';
    std::cout << "\n";
    */
    CHECK(heapsort(v1) == v2);
  }

  TEST(Sort2)
  {
    
    std::vector<int> v1{-1, -1, -10, 22, 7};
    std::vector<int> v2{22, 7, -1, -1, -10};
    CHECK(heapsort(v1) == v2);
  }

  TEST(Sort3)
  {
    
    std::vector<int> v1{1, 7, 7, 7, 3, 3};
    std::vector<int> v2{7, 7, 7, 3, 3, 1};
    CHECK(heapsort(v1) == v2);
  }


} // namespace binheap

int
main(int, const char*[])
{
    return UnitTest::RunAllTests();
}
