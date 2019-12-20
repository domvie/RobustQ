int main(void) {
#pragma omp parallel
  {
    unsigned long long x=0, y=1;
    while (x++ || y++) 
    {
        x++;
        if(x == 100000000000){
            break;
            return 0;
        }
    };
  }
  return 0;
}