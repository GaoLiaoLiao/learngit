#pragma once

#include<cstddef>
#include<vector>
#include<utility>

namespace binheap_template
{ 
  
  using idx = std::size_t;

  template<class T>
  class binheap {
  
  public:
    
    bool isEmpty();
    T getMin();
    void removeMin();
    void add(T);
    
  private:

    std::vector<T> heap;
    void bubbleUp(idx);
    void bubbleDown(idx, idx);
    void bubbleDown(idx);
    idx size();
    
    template<typename U>
    friend std::vector<U> heapsort(std::vector<U>);

  };

  idx parent(idx);
  idx left(idx);
  idx right(idx);
  
  template<typename T>
  T binheap<T>::getMin()
  {
    return heap[0];
  }

  template<typename T>
  void binheap<T>::add(T newValue)
  {
    heap.push_back(newValue);
    bubbleUp(heap.size() - 1);
  }

  template<typename T>
  bool binheap<T>::isEmpty()
  {
    return heap.empty();
  }

  template<typename T>
  idx binheap<T>::size() 
  {
    return heap.size();
  }

  template<typename T>
  void binheap<T>::removeMin()
  {
    heap[0] = heap[heap.size() - 1];
    heap.pop_back();
    bubbleDown(0);
  }

  template<typename T>
  void binheap<T>::bubbleUp(idx i) 
  {
    idx par_i = parent(i);
    if (i != 0 && !(heap[par_i] < heap[i])) {
      std::swap(heap[par_i], heap[i]);
      bubbleUp(par_i);
    }
  }

  template<typename T>
  void binheap<T>::bubbleDown(idx i, idx size) {
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

  template<typename T>
  void binheap<T>::bubbleDown(idx i) {
    bubbleDown(i, size());
  }
   
  template<typename T>
  std::vector<T> heapsort(std::vector<T> vec) 
  {
    binheap<T> bh;
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

} // namespace binheap_template
