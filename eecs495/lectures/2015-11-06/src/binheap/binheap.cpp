#include "binheap.hpp"

namespace binheap
{

  bool binheap::isEmpty()
  {
    return heap.empty();
  }

  int binheap::getMin()
  {
    return heap[0];
  }

  idx binheap::size() 
  {
    return heap.size();
  }

  void binheap::add(int newValue)
  {
    heap.push_back(newValue);
    bubbleUp(heap.size() - 1);
  }

  void binheap::removeMin()
  {
    heap[0] = heap[heap.size() - 1];
    heap.pop_back();
    bubbleDown(0);
  }

  // preserve the heap invariant, by moving a violating
  // child upward
  void binheap::bubbleUp(idx i) 
  {
    idx par_i = parent(i);
    if (i != 0 && heap[par_i] > heap[i]) {
      std::swap(heap[par_i], heap[i]);
      bubbleUp(par_i);
    }
  }

  // preserve the heap invariant, by moving a violating
  // parent downward
  void binheap::bubbleDown(idx i, idx size) {
    idx left_i = left(i);
    idx right_i = right(i);
    if (right_i < size && heap[right_i] < heap[i]) {
      if (heap[left_i] < heap[right_i]) {
	std::swap(heap[left_i], heap[i]);
	bubbleDown(left_i, size); 
      } else {
	std::swap(heap[right_i], heap[i]);
	bubbleDown(right_i, size); 
      }
    } else if (left_i < size && heap[left_i] < heap[i]) {
      std::swap(heap[left_i], heap[i]);
      bubbleDown(left_i, size);
    }
  }

  void binheap::bubbleDown(idx i) {
    bubbleDown(i, size());
  }

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

  std::vector<int> heapsort(std::vector<int> vec) 
  {
    binheap bh;
    bh.heap = vec;
    // largest node that has a child:
    idx par = bh.size()/2 - 1;
    // make this a heap by bubbling down all parents
    // O(n log n)
    while (par != 0) {
      bh.bubbleDown(par--);
    }
    bh.bubbleDown(0);
    // move smallest node to end by swapping
    // decrement the size of the implicit heap
    // and bubble down the root
    // O(n log n)
    idx cur_size = bh.size();
    while (cur_size > 0) {
      std::swap(bh.heap[--cur_size], bh.heap[0]);
      bh.bubbleDown(0, cur_size);
    }
    return bh.heap;
  }

   
} 
