#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

uint32_t xorshift32() {
	static uint32_t x32 = 314159265;
	x32 ^= x32 << 13;
	x32 ^= x32 >> 17;
	x32 ^= x32 << 5;
	return x32;
}

void setpixel(int x, int y, uint8_t r, uint8_t g, uint8_t b)
{
	if (0 <= x && x < 32 && 0 <= y && y < 32) {
		uint32_t rgb = (r << 16) | (g << 8) | b;
		uint32_t addr = 4*x + 32*4*y + 0x10000000;
		*(volatile uint32_t*)addr = rgb;
	}
}

void randpixel()
{
	uint8_t x = xorshift32() % 32;
	uint8_t y = xorshift32() % 32;
	uint8_t r = xorshift32();
	uint8_t g = xorshift32();
	uint8_t b = xorshift32();
	setpixel(x, y, r, g, b);
}

#define MAX_PRIMES 1000000
unsigned char p[MAX_PRIMES/16+1]; /* zero-initialized */

int primes_lt_100 = 0;
int primes_lt_1000 = 0;
int primes_lt_10000 = 0;
int primes_lt_100000 = 0;
int primes_lt_1000000 = 0;

void print_primes()
{
	int a, b, k = 1;

	printf("%6d", 2);
	for (a = 3; a < MAX_PRIMES; a += 2)
	{
		if (p[a >> 4] & (1 << ((a >> 1) & 7)))
			continue;

		for (b = a + a; b < MAX_PRIMES; b += a)
			if (b & 1)
				p[b >> 4] = p[b >> 4] | (1 << ((b >> 1) & 7));

		k++;
		if (a < 100) primes_lt_100 = k;
		if (a < 1000) primes_lt_1000 = k;
		if (a < 10000) primes_lt_10000 = k;
		if (a < 100000) primes_lt_100000 = k;
		if (a < 1000000) primes_lt_1000000 = k;

		printf("%c%6d", (k-1) % 8 == 0 ? '\n' : ' ', a);
		fflush(stdout);
		randpixel();
	}

	printf("\n");
	printf("#primes <     100: %5d\n", primes_lt_100);
	printf("#primes <    1000: %5d\n", primes_lt_1000);
	printf("#primes <   10000: %5d\n", primes_lt_10000);
	printf("#primes <  100000: %5d\n", primes_lt_100000);
	printf("#primes < 1000000: %5d\n", primes_lt_1000000);

	bool got_error = false;
	if (primes_lt_100     !=    25) got_error = true;
	if (primes_lt_1000    !=   168) got_error = true;
	if (primes_lt_10000   !=  1229) got_error = true;
	if (primes_lt_100000  !=  9592) got_error = true;
	if (primes_lt_1000000 != 78498) got_error = true;

	printf(got_error ? "ERROR!!!\n" : "OK.\n");

	putchar(0);
	fflush(stdout);
}

void main()
{
	for (int x = 0; x < 32; x++)
	for (int y = 0; y < 32; y++) {
		uint8_t r = xorshift32();
		uint8_t g = xorshift32();
		uint8_t b = xorshift32();
		setpixel(x, y, r, g, b);
	}

	print_primes();

	while (1)
		randpixel();
}
