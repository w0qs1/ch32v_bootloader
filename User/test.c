#include <stdint.h>

void test(void) {
    volatile uint32_t *a;
    volatile uint32_t c;
    a = (uint32_t *) 0x00000000;
    c = *(a) + 1;
    return;
}