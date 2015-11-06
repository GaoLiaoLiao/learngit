#include "binheap_template.hpp"

namespace binheap_template
{
    
  idx parent(idx n)
  {
    return (n - 1) / 2;
  }

  idx left(idx n)
  {
    return 2*n + 1;
  }

  idx right(idx n)
  {
    return 2*n + 2;
  }
   
} 
