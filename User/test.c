#include <stdint.h>

uint32_t test(void) {
    volatile uint32_t *a;
    volatile uint32_t c;
    a = (uint32_t *) 0x00000000;
    c = *(a) + 1;
    return c;
}