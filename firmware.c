#include <stdint.h>
#include <stdbool.h>

uint8_t fontmem [8*128] = {
  0,  0,  0,  0,  0,  0,  0,  0, // 0
  0,  0,  0,  0,  0,  0,  0,  0, // 1
  0,  0,  0,  0,  0,  0,  0,  0, // 2
  0,  0,  0,  0,  0,  0,  0,  0, // 3
  0,  0,  0,  0,  0,  0,  0,  0, // 4
  0,  0,  0,  0,  0,  0,  0,  0, // 5
  0,  0,  0,  0,  0,  0,  0,  0, // 6
  0,  0,  0,  0,  0,  0,  0,  0, // 7
  0,  0,  0,  0,  0,  0,  0,  0, // 8
  0,  0,  0,  0,  0,  0,  0,  0, // 9
  0,  0,  0,  0,  0,  0,  0,  0, // 10
  0,  0,  0,  0,  0,  0,  0,  0, // 11
  0,  0,  0,  0,  0,  0,  0,  0, // 12
  0,  0,  0,  0,  0,  0,  0,  0, // 13
  0,  0,  0,  0,  0,  0,  0,  0, // 14
  0,  0,  0,  0,  0,  0,  0,  0, // 15
  0,  0,  0,  0,  0,  0,  0,  0, // 16
  0,  0,  0,  0,  0,  0,  0,  0, // 17
  0,  0,  0,  0,  0,  0,  0,  0, // 18
  0,  0,  0,  0,  0,  0,  0,  0, // 19
  0,  0,  0,  0,  0,  0,  0,  0, // 20
  0,  0,  0,  0,  0,  0,  0,  0, // 21
  0,  0,  0,  0,  0,  0,  0,  0, // 22
  0,  0,  0,  0,  0,  0,  0,  0, // 23
  0,  0,  0,  0,  0,  0,  0,  0, // 24
  0,  0,  0,  0,  0,  0,  0,  0, // 25
  0,  0,  0,  0,  0,  0,  0,  0, // 26
  0,  0,  0,  0,  0,  0,  0,  0, // 27
  0,  0,  0,  0,  0,  0,  0,  0, // 28
  0,  0,  0,  0,  0,  0,  0,  0, // 29
  0,  0,  0,  0,  0,  0,  0,  0, // 30
  0,  0,  0,  0,  0,  0,  0,  0, // 31
  0,  0,  0,  0,  0,  0,  0,  0, // ' '
  8,  8,  8,  8,  8,  0,  8,  0, // '!'
 20, 20,  0,  0,  0,  0,  0,  0, // '"'
 20, 20,127, 20,127, 20, 20,  0, // '#'
  8, 30, 40, 28, 10, 60,  8,  0, // '$'
  0, 50, 52,  8, 22, 38,  0,  0, // '%'
 24, 40, 16, 40, 70, 68, 58,  0, // '&'
  8,  8,  0,  0,  0,  0,  0,  0, // '''
  4,  8, 16, 16, 16,  8,  4,  0, // '('
 16,  8,  4,  4,  4,  8, 16,  0, // ')'
  8, 73, 42, 28, 42, 73,  8,  0, // '*'
  8,  8,  8,127,  8,  8,  8,  0, // '+'
  0,  0,  0,  0, 12, 12,  4,  8, // ','
  0,  0,  0,127,  0,  0,  0,  0, // '-'
  0,  0,  0,  0,  0, 12, 12,  0, // '.'
  1,  2,  4,  8, 16, 32, 64,  0, // '/'
 28, 34, 34, 42, 34, 34, 28,  0, // '0'
  8, 24,  8,  8,  8,  8, 28,  0, // '1'
 28, 34,  2,  4,  8, 16, 62,  0, // '2'
 28, 34,  2, 12,  2, 34, 28,  0, // '3'
 12, 20, 36, 62,  4,  4, 14,  0, // '4'
 62, 32, 32, 60,  2, 34, 28,  0, // '5'
 28, 34, 32, 60, 34, 34, 28,  0, // '6'
 62,  2,  4,  8, 16, 16, 16,  0, // '7'
 28, 34, 34, 28, 34, 34, 28,  0, // '8'
 28, 34, 34, 30,  2, 34, 28,  0, // '9'
  0, 12, 12,  0, 12, 12,  0,  0, // ':'
  0, 12, 12,  0, 12, 12,  4,  8, // ';'
  4,  8, 16, 32, 16,  8,  4,  0, // '<'
  0,  0,127,  0,127,  0,  0,  0, // '='
 32, 16,  8,  4,  8, 16, 32,  0, // '>'
 28, 34,  2,  4,  8,  0,  8,  0, // '?'
 28, 34, 46, 42, 46, 32, 28,  0, // '@'
 28, 34, 34, 62, 34, 34, 34,  0, // 'A'
 60, 34, 34, 60, 34, 34, 60,  0, // 'B'
 28, 34, 32, 32, 32, 34, 28,  0, // 'C'
 60, 34, 34, 34, 34, 34, 60,  0, // 'D'
 62, 32, 32, 60, 32, 32, 62,  0, // 'E'
 62, 32, 32, 62, 32, 32, 32,  0, // 'F'
 28, 34, 32, 46, 34, 34, 28,  0, // 'G'
 34, 34, 34, 62, 34, 34, 34,  0, // 'H'
 28,  8,  8,  8,  8,  8, 28,  0, // 'I'
 14,  4,  4,  4, 36, 36, 24,  0, // 'J'
 34, 34, 36, 56, 36, 34, 34,  0, // 'K'
 16, 16, 16, 16, 16, 16, 30,  0, // 'L'
 65, 99, 85, 73, 65, 65, 65,  0, // 'M'
 34, 50, 42, 42, 38, 34, 34,  0, // 'N'
 28, 34, 34, 34, 34, 34, 28,  0, // 'O'
 28, 18, 18, 28, 16, 16, 16,  0, // 'P'
 28, 34, 34, 34, 34, 34, 28,  6, // 'Q'
 60, 34, 34, 60, 40, 36, 34,  0, // 'R'
 28, 34, 32, 28,  2, 34, 28,  0, // 'S'
 62,  8,  8,  8,  8,  8,  8,  0, // 'T'
 34, 34, 34, 34, 34, 34, 28,  0, // 'U'
 34, 34, 34, 20, 20,  8,  8,  0, // 'V'
 65, 65, 65, 42, 42, 20, 20,  0, // 'W'
 34, 34, 20,  8, 20, 34, 34,  0, // 'X'
 34, 34, 20,  8,  8,  8,  8,  0, // 'Y'
 62,  2,  4,  8, 16, 32, 62,  0, // 'Z'
 28, 16, 16, 16, 16, 16, 28,  0, // '['
 64, 32, 16,  8,  4,  2,  1,  0, // '\'
 28,  4,  4,  4,  4,  4, 28,  0, // ']'
  8, 20, 34,  0,  0,  0,  0,  0, // '^'
  0,  0,  0,  0,  0,  0,  0,127, // '_'
 16,  8,  0,  0,  0,  0,  0,  0, // '`'
  0, 28,  2, 30, 34, 34, 29,  0, // 'a'
 16, 16, 28, 18, 18, 18, 44,  0, // 'b'
  0,  0, 28, 32, 32, 32, 28,  0, // 'c'
  2,  2, 14, 18, 18, 18, 13,  0, // 'd'
  0,  0, 28, 34, 62, 32, 28,  0, // 'e'
 12, 18, 16, 56, 16, 16, 16,  0, // 'f'
  0,  0, 29, 34, 34, 30,  2, 28, // 'g'
 32, 32, 44, 50, 34, 34, 34,  0, // 'h'
  0,  8,  0,  8,  8,  8,  8,  0, // 'i'
  0,  8,  0,  8,  8,  8,  8, 48, // 'j'
 32, 32, 36, 40, 48, 40, 36,  0, // 'k'
 24,  8,  8,  8,  8,  8,  8,  0, // 'l'
  0,  0,182, 73, 73, 65, 65,  0, // 'm'
  0,  0, 44, 18, 18, 18, 18,  0, // 'n'
  0,  0, 28, 34, 34, 34, 28,  0, // 'o'
  0,  0, 44, 18, 18, 28, 16, 16, // 'p'
  0,  0, 26, 36, 36, 28,  4,  4, // 'q'
  0,  0, 44, 48, 32, 32, 32,  0, // 'r'
  0,  0, 28, 32, 24,  4, 56,  0, // 's'
  0,  8, 28,  8,  8,  8,  8,  0, // 't'
  0,  0, 36, 36, 36, 36, 26,  0, // 'u'
  0,  0, 34, 34, 34, 20,  8,  0, // 'v'
  0,  0, 65, 65, 73, 85, 34,  0, // 'w'
  0,  0, 34, 20,  8, 20, 34,  0, // 'x'
  0,  0, 18, 18, 18, 14,  2, 28, // 'y'
  0,  0, 60,  4,  8, 16, 60,  0, // 'z'
 12, 16, 16, 32, 16, 16, 12,  0, // '{'
  8,  8,  8,  8,  8,  8,  8,  0, // '|'
 48,  8,  8,  4,  8,  8, 48,  0, // '}'
  0,  0, 48, 73,  6,  0,  0,  0, // '~'
  0,  0,  0,  0,  0,  0,  0,  0, // 127
};

uint8_t fontleft [128] = {
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,4,3,1,2,2,1,4,3,3,1,1,4,1,4,1,2,3,2,2,2,2,2,2,2,2,4,4,2,1,2,2,
2,2,2,2,2,2,2,2,2,3,2,2,3,1,2,2,3,2,2,2,2,2,2,1,2,2,2,3,1,3,2,1,
3,2,2,2,3,2,2,2,2,4,2,2,3,0,2,2,2,2,2,2,3,2,2,1,2,3,2,2,4,2,1,0,
};

uint8_t fontright [128] = {
4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,
4,5,6,8,7,7,7,5,6,6,8,8,6,8,6,8,7,6,7,7,7,7,7,7,7,7,6,6,6,8,6,7,
7,7,7,7,7,7,7,7,7,6,7,7,7,8,7,7,7,7,7,7,7,7,7,8,7,7,7,6,8,6,7,8,
5,8,7,6,8,7,7,8,7,5,5,6,5,8,7,7,7,7,6,6,6,7,7,8,7,7,6,6,5,6,8,4,
};

void setpixel(int x, int y, uint8_t r, uint8_t g, uint8_t b)
{
	if (0 <= x && x < 32 && 0 <= y && y < 32) {
		uint32_t rgb = (r << 16) | (g << 8) | b;
		uint32_t addr = 4*((31-y) + 32*(31-x)) + 0x10000000;
		*(volatile uint32_t*)addr = rgb;
	}
}

bool settext(int x, int y, const char *str)
{
	bool retval = false;

	for (; *str; str++)
	{
		uint8_t *f = fontmem + 8*(*str);
		uint8_t fl = fontleft[*str];
		uint8_t fr = fontright[*str];

		if (x < -8) {
			x += fr-fl+1;
			continue;
		}

		retval = true;

		if (x > 32)
			break;

		for (int oy = 0; oy < 8; oy++, f++) {
			uint8_t b = *f << fl;
			for (int ox = 0; ox <= fr-fl; ox++, b = b << 1)
				if ((b&128) != 0)
					setpixel(x+ox, y+oy, 0, 0, 255);
				else
					setpixel(x+ox, y+oy, 6*(x+ox+1), 6*(y+oy+1), 0);
		}

		x += fr-fl+1;
	}

	return retval;
}

void main()
{
	for (int x = 0; x < 32; x++)
	for (int y = 0; y < 32; y++)
		setpixel(x, y, 6*(x+1), 6*(y+1), 0);

	// for (int x = 0; x < 32; x += 2)
	// 	setpixel(x, 0, 0, 0, 128);

	while (1) {
		int x = 32;
		while (settext(x, 12, "  Yosys ** Project IceStorm ** Arachne-PNR ** RISC-V ** PicoRV32  ")) {
			for (int k = 0; k < 20000; k++)
				asm volatile ("");
			x--;
		}
	}
}
