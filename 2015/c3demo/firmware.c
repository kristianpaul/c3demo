#include <stdint.h>

void setpixel(uint8_t x, uint8_t y, uint8_t r, uint8_t g, uint8_t b)
{
	uint32_t rgb = (r << 16) | (g << 8) | b;
	uint32_t addr = 4*(x + 32*y) + 0x10000000;
	*(volatile uint32_t*)addr = rgb;
}

void main()
{
	for (int x = 0; x < 32; x++)
	for (int y = 0; y < 32; y++)
		setpixel(x, y, 8*x, 8*y, 0);
}
