#include <iostream>

int main(void) {
#pragma omp parallel
  {
    unsigned long long x=0, y=1;
    std::cout << "Entering while loop" << std::endl;
    while (x++ || y++) 
    {
        x++;
        if(x == 10000000000){
            break;
            return 0;
        }
    };
    std::cout << "After while loop success." << std::endl;
  }
  return 0;
}
