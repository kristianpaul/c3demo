#include <stdint.h>
#include <stdbool.h>

const uint32_t splash_screen[] = {
	0b00000000000000000000000000000000,
	0b01111111111111111111111111100000,
	0b01000011111100000000000010010000,
	0b01000011111100000011110010001000,
	0b01000011111100000011110010000100,
	0b01000011111100000011110010000010,
	0b01000011111100000011110010000010,
	0b01000011111100000011110010000010,
	0b01000011111100000011110010000010,
	0b01000011111100000011110010000010,
	0b01000011111100000011110010000010,
	0b01000011111100000000000010000010,
	0b01000011111111111111111110000010,
	0b01000000000000000000000000000010,
	0b01000000000000000000000000000010,
	0b01000000000000000000000000000010,
	0b01000000000000000000000000000010,
	0b01000000000000000000000000000010,
	0b01000111111111111111111111100010,
	0b01000100000000000000000000100010,
	0b01000100000000000000000000100010,
	0b01000100101010101010101000100010,
	0b01000100000000000000000000100010,
	0b01000100000000000000000000100010,
	0b01000100010101010101010100100010,
	0b01000100000000000000000000100010,
	0b01000100000000000000000000100010,
	0b01110100101010101010101000100010,
	0b01110100000000000000000000100010,
	0b01000100000000000000000000100010,
	0b01111111111111111111111111111110,
	0b00000000000000000000000000000000
};

static int console_getc()
{
	while (1) {
		int c = *(volatile uint32_t*)0x30000000;
		if (c >= 0) return c;
	}
}

static void console_putc(int c)
{
	*(volatile uint32_t*)0x30000000 = c;
}

static void console_puth(uint32_t v)
{
	for (int i = 0; i < 8; i++) {
		int d = v >> 28;
		console_putc(d < 10 ? '0' + d : 'a' + d - 10);
		v = v << 4;
	}
}

static void console_puts(const char *s)
{
	while (*s)
		*(volatile uint32_t*)0x30000000 = *(s++);
}

void setpixel(int x, int y, uint8_t r, uint8_t g, uint8_t b)
{
	if (0 <= x && x < 32 && 0 <= y && y < 32) {
		uint32_t rgb = (r << 16) | (g << 8) | b;
		uint32_t addr = 4*x + 32*4*y + 0x10000000;
		*(volatile uint32_t*)addr = rgb;
	}
}

bool ishex(char ch)
{
	if ('0' <= ch && ch <= '9') return true;
	if ('a' <= ch && ch <= 'f') return true;
	if ('A' <= ch && ch <= 'F') return true;
	return false;
}

int hex2int(char ch)
{
	if ('0' <= ch && ch <= '9') return ch - '0';
	if ('a' <= ch && ch <= 'f') return ch - 'a' + 10;
	if ('A' <= ch && ch <= 'F') return ch - 'A' + 10;
	return -1;
}

void main()
{
	*(volatile uint32_t*)0x20000000 = 7; // LEDs On

	for (int x = 0; x < 32; x++)
	for (int y = 0; y < 32; y++)
		if (splash_screen[y] & (1 << (31-x)))
			setpixel(x, y, 0, 0, 255);
		else
			setpixel(x, y, 6*(x+1), 6*(y+1), 0);

	*(volatile uint32_t*)0x20000000 = 0; // LEDs Off

	console_puts(".\nBootloader> " + 2);
	uint8_t *memcursor = (uint8_t*)(64 * 1024);
	int bytecount = 0;

	while (1)
	{
		char ch = console_getc();

		if (ch == 0 || ch == '@')
		{
			if (bytecount) {
				console_puts("Written 0x");
				console_puth(bytecount);
				console_puts(" bytes at 0x");
				console_puth((uint32_t)memcursor);
				console_puts(".\nBootloader> ");
			}

			if (ch == 0) {
				console_puts("RUN\n");
				break;
			}

			int newaddr = 0;
			while (1) {
				ch = console_getc();
				if (!ishex(ch)) break;
				newaddr = (newaddr << 4) | hex2int(ch);
			}

			memcursor = (uint8_t*)newaddr;
			bytecount = 0;
			continue;
		}

		if (ishex(ch))
		{
			char ch2 = console_getc();

			if (ishex(ch2)) {
				memcursor[bytecount++] = (hex2int(ch) << 4) | hex2int(ch2);
				continue;
			}

			console_putc(ch);
			ch = ch2;
			goto prompt;
		}

		if (ch == ' ' || ch == '\t' || ch == '\r' || ch == '\n')
			continue;

	prompt:
		console_putc(ch);
		console_puts(".\nBootloader> " + 1);
	}
}
