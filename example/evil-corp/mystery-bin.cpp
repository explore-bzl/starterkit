#include "mystery-bin.hpp"

void printOpenSslInfo(void) {
  std::cout << OPENSSL_info(1001) << std::endl; 
}

int main(void) {
  printOpenSslInfo();
  return 0;
}
