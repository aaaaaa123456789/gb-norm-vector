#include <stdio.h>
#include <math.h>

int main (void) {
  for (double high = 0x20; high < 0x41; high ++) {
    double low = 0;
    while (low < 0x40) {
      if ((unsigned) (low ++) & 7)
        putchar(',');
      else
        fputs("\tdw", stdout);
      double denom = sqrt(high * high + low * low);
      unsigned first = round(ldexp(high / denom, 16)), second = round(ldexp(low / denom, 16));
      printf(" $%04x, $%04x", first, second);
      if (!((unsigned) low & 7)) putchar('\n');
    }
  }
  return 0;
}
