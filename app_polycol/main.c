#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>

uint8_t current_map[32][32];
uint8_t neigh_y_map[32][32];
uint8_t neigh_b_map[32][32];
uint8_t happy_map[32][32];

volatile int current_y1 = 10, current_y2 = 20;
volatile int current_b1 = 10, current_b2 = 20;
volatile int popdelta_y = 200, popdelta_b = 200;
volatile int current_speed = 10;

static inline void setled(int v)
{
	*(volatile uint32_t*)0x20000000 = v;
}

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

void handle_ctrls()
{
	static bool first = true;
	static uint8_t ctrlbits[8];

	for (int k = 0; k < 8; k++)
	{
		uint8_t bits = ((*(volatile uint32_t*)(0x20000014 + 0x10*(k / 2))) >> ((k % 2) ? 5 : 1)) & 7;

		if (first)
			ctrlbits[k] = bits;

		if (bits == ctrlbits[k])
			continue;

		int old_pos = ctrlbits[k] >> 1;
		int new_pos = bits >> 1;

		old_pos = old_pos ^ (old_pos >> 1);
		new_pos = new_pos ^ (new_pos >> 1);

		int delta = 0;

		if (new_pos == ((old_pos+1) & 3))
			delta = +1;

		if (new_pos == ((old_pos-1) & 3))
			delta = -1;

		if (k == 0 && 0 < current_y1+delta && current_y1+delta < current_y2)
				current_y1 += delta;

		if (k == 5 && current_y1 < current_y2+delta && current_y2+delta < 31)
				current_y2 += delta;

		if (k == 6 && 0 < current_b1+delta && current_b1+delta < current_b2)
				current_b1 += delta;

		if (k == 7 && current_b1 < current_b2+delta && current_b2+delta < 31)
				current_b2 += delta;

		if ((k == 2 || k == 4) && 0 < current_speed-delta && current_speed-delta < 31)
				current_speed -= delta;

		if (k == 1)
			popdelta_y -= delta;

		if (k == 3)
			popdelta_b -= delta;

		ctrlbits[k] = bits;
	}

	first = false;
}

void update_population()
{
	for (int k = 0; (popdelta_y || popdelta_b) && k < 10; k++)
	{
		int count_f = 0, count_y = 0, count_b = 0;

		for (int x = 0; x < 32; x++)
		for (int y = 0; y < 32; y++) {
			if (current_map[x][y] == 0)
				count_f++;
			else if (current_map[x][y] == 1)
				count_y++;
			else if (current_map[x][y] == 2)
				count_b++;
		}

		int free_y = 0, free_b = 0;
		int set_y = 0, set_b = 0;

		if (popdelta_y > 0 && (popdelta_b <= 0 || (xorshift32() % 2))) {
			if (count_f)
				set_y = (xorshift32() % count_f) + 1;
			popdelta_y--;
		} else
		if (popdelta_b > 0) {
			if (count_f)
				set_b = (xorshift32() % count_f) + 1;
			popdelta_b--;
		}

		if (popdelta_y < 0) {
			if (count_y)
				free_y = (xorshift32() % count_y) + 1;
			popdelta_y++;
		}

		if (popdelta_b < 0) {
			if (count_b)
				free_b = (xorshift32() % count_b) + 1;
			popdelta_b++;
		}

		count_f = 0;
		count_y = 0;
		count_b = 0;

		for (int x = 0; x < 32; x++)
		for (int y = 0; y < 32; y++) {
			if (current_map[x][y] == 0) {
				count_f++;
				if (set_y == count_f) current_map[x][y] = 1;
				if (set_b == count_f) current_map[x][y] = 2;
			} else
			if (current_map[x][y] == 1) {
				count_y++;
				if (free_y == count_y) current_map[x][y] = 0;
			} else
			if (current_map[x][y] == 2) {
				count_b++;
				if (free_b == count_b) current_map[x][y] = 0;
			}
		}
	}
}

void update_happymap()
{
	memset(neigh_y_map, 0, 32*32);
	memset(neigh_b_map, 0, 32*32);
	memset(happy_map, 0, 32*32);

	for (int x = 0; x < 32; x++)
	for (int y = 0; y < 32; y++)
	{
		if (current_map[x][y] == 1) {
			for (int kx = x-1; kx <= x+1; kx++)
			for (int ky = y-1; ky <= y+1; ky++)
				if (0 <= kx && kx < 32 && 0 <= ky && ky < 32)
					neigh_y_map[kx][ky]++;
		}

		if (current_map[x][y] == 2) {
			for (int kx = x-1; kx <= x+1; kx++)
			for (int ky = y-1; ky <= y+1; ky++)
				if (0 <= kx && kx < 32 && 0 <= ky && ky < 32)
					neigh_b_map[kx][ky]++;
		}
	}

	bool enable_move_y = popdelta_y < 10;
	bool enable_move_b = popdelta_b < 10;

	for (int x = 0; x < 32; x++)
	for (int y = 0; y < 32; y++)
	{
		if (current_map[x][y] == 1) {
			int v = 31 - (4 + 3*neigh_b_map[x][y]);
			if (current_y1 < v && v < current_y2)
				happy_map[x][y] = 1;
			else if (enable_move_y && (xorshift32() % 64) < current_speed) {
				current_map[x][y] = 0;
				popdelta_y++;
			}
		}

		if (current_map[x][y] == 2) {
			int v = 31 - (4 + 3*neigh_y_map[x][y]);
			if (current_b1 < v && v < current_b2)
				happy_map[x][y] = 1;
			else if (enable_move_b && (xorshift32() % 64) < current_speed) {
				current_map[x][y] = 0;
				popdelta_b++;
			}
		}
	}
}

void update_screen()
{
	for (int x = 1; x < 31; x++)
	for (int y = 0; y < 31; y++) {
		if (current_map[x][y] == 0) {
			setpixel(x, y, 0, 0, 0);
		} else
		if (current_map[x][y] == 1) {
			if (happy_map[x][y])
				setpixel(x, y, 255, 255, 0);
			else
				setpixel(x, y, 128, 128, 64);
		} else
		if (current_map[x][y] == 2) {
			if (happy_map[x][y])
				setpixel(x, y, 0, 0, 255);
			else
				setpixel(x, y, 64, 64, 128);
		}
	}

	for (int y = 1; y < 31; y++)
	{
		if (y < current_y1)
			setpixel(0, y, 255, 0, 0);
		else if (y <= current_y2)
			setpixel(0, y, 255, 255, 0);
		else
			setpixel(0, y, 255, 0, 0);

		if (y < current_b1)
			setpixel(31, y, 255, 0, 0);
		else if (y <= current_b2)
			setpixel(31, y, 0, 0, 255);
		else
			setpixel(31, y, 255, 0, 0);
	}

	for (int x = 1; x < 31; x++)
		if (x == current_speed)
			setpixel(x, 31, 0, 255, 0);
		else
			setpixel(x, 31, 16, 0, 16);
}

// external symbol
void irq_wrapper();
void enable_timer();

void install_irq()
{
	uint32_t rel_addr = (uint32_t)irq_wrapper - 0x10;
	uint32_t jal_instr = 0x6f;

	uint32_t rel_addr_20 = (rel_addr >> 20) & 1;
	uint32_t rel_addr_10_1 = (rel_addr >> 1) & 0x3ff;
	uint32_t rel_addr_11 = (rel_addr >> 11) & 1;
	uint32_t rel_addr_19_12 = (rel_addr >> 12) & 0xff;

	jal_instr |= rel_addr_19_12 << 12;
	jal_instr |= rel_addr_11 << (12+8);
	jal_instr |= rel_addr_10_1 << (12+8+1);
	jal_instr |= rel_addr_20 << (12+8+1+10);

	*(uint32_t*)0x00000010 = jal_instr;
}

uint32_t *irq(uint32_t *regs, uint32_t irqs)
{
	handle_ctrls();
	enable_timer();
	return regs;
}

void main()
{
	install_irq();
	enable_timer();

	for (int x = 0; x < 32; x++)
	for (int y = 0; y < 32; y++)
		setpixel(x, y, 0, 0, 0);
	
	while (1)
	{
		update_population();
		update_happymap();
		update_screen();
	}
}
