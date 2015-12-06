#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

int level;
int player_x;
int player_bullet_x;
int player_bullet_y;

bool invaders_chdir;
int invaders_dir;
int invaders_down;
int active_invader;
int invader_bullet_x;
int invader_bullet_y;
int invader_max_y;
int next_invader_max_y;

uint32_t blocks[32];
bool reset_blocks;

struct invader_pos_t {
	int x;
	int y;
} invaders[16];

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

void place_block(int x, int y)
{
	blocks[y] |= 1 << x;
}

void place_barrier(int x, int y)
{
	place_block(x-3, y+1);
	place_block(x-2, y+1);
	place_block(x-1, y+1);
	place_block(x+1, y+1);
	place_block(x+2, y+1);
	place_block(x+3, y+1);

	place_block(x-3, y);
	place_block(x-2, y);
	place_block(x-1, y);
	place_block(x+0, y);
	place_block(x+1, y);
	place_block(x+2, y);
	place_block(x+3, y);

	place_block(x-2, y-1);
	place_block(x-1, y-1);
	place_block(x+0, y-1);
	place_block(x+1, y-1);
	place_block(x+2, y-1);

	place_block(x-1, y-2);
	place_block(x+0, y-2);
	place_block(x+1, y-2);

}

bool move_invader(int n)
{
	if (!n)
	{
		int n2 = xorshift32() % 16;

		int t = invaders[n].x;
		invaders[n].x = invaders[n2].x;
		invaders[n2].x = t;

		t = invaders[n].y;
		invaders[n].y = invaders[n2].y;
		invaders[n2].y = t;

		invader_max_y = next_invader_max_y;
		next_invader_max_y = 0;
	}

	int x = invaders[n].x;
	int y = invaders[n].y;

	setpixel(x, y, 0, 0, 0);
	setpixel(x-1, y+1, 0, 0, 0);
	setpixel(x+1, y+1, 0, 0, 0);

	if (invaders_dir > 0 && y > 0 && x == 31)
		invaders_chdir = true;

	if (invaders_dir < 0 && y > 0 && x == 0)
		invaders_chdir = true;

	if (invaders_chdir && !n) {
		invaders_chdir = false;
		invaders_dir = invaders_dir > 0 ? -1 : +1;
		invaders_down = 16;
	}

	x = x + invaders_dir;
	if (invaders_down) {
		invaders_down--;
		y++;
	}

	setpixel(x, y, 50, 30, 30);
	setpixel(x-1, y+1, 50, 30, 30);
	setpixel(x+1, y+1, 50, 30, 30);

	invaders[n].x = x;
	invaders[n].y = y;

	if (y < 31) {
		if (x < 31) blocks[y+1] &= ~(1 << (x+1));
		if (x >  0) blocks[y+1] &= ~(1 << (x-1));
	}

	if (next_invader_max_y < y)
		next_invader_max_y = y;

	if (invader_max_y == y && player_x == x && invader_bullet_y < 0) {
		invader_bullet_x = x;
		invader_bullet_y = y+1;
		setpixel(invader_bullet_x, invader_bullet_y, 255, 0, 0);
	}

	return y >= 29 && x >= player_x-2 && x <= player_x+2;
}

void place_invader(int n, int x, int y)
{
	invaders[n].x = x;
	invaders[n].y = y;

	setpixel(x, y, 50, 30, 30);
	setpixel(x-1, y+1, 50, 30, 30);
	setpixel(x+1, y+1, 50, 30, 30);
}

void move_player_left()
{
	if (player_x > 0)
		player_x--;

	// setpixel(player_x-2, 31, 0, 0, 0);
	setpixel(player_x-1, 31, 50, 100, 100);
	setpixel(player_x+0, 31, 50, 100, 100);
	setpixel(player_x+1, 31, 50, 100, 100);
	setpixel(player_x+2, 31, 0, 0, 0);

	// setpixel(player_x-1, 30, 0, 0, 0);
	setpixel(player_x+0, 30, 50, 100, 100);
	setpixel(player_x+1, 30, 0, 0, 0);
}

void move_player_right()
{
	if (player_x < 31)
		player_x++;

	setpixel(player_x-2, 31, 0, 0, 0);
	setpixel(player_x-1, 31, 50, 100, 100);
	setpixel(player_x+0, 31, 50, 100, 100);
	setpixel(player_x+1, 31, 50, 100, 100);
	// setpixel(player_x+2, 31, 0, 0, 0);

	setpixel(player_x-1, 30, 0, 0, 0);
	setpixel(player_x+0, 30, 50, 100, 100);
	// setpixel(player_x+1, 30, 0, 0, 0);
}

void game()
{
	player_x = 0;
	player_bullet_x = 0;
	player_bullet_y = -1;

	invaders_chdir = false;
	invaders_dir = +1;
	invaders_down = 0;
	active_invader = 0;
	invader_bullet_x = 0;
	invader_bullet_y = -1;
	invader_max_y = 0;
	next_invader_max_y = 0;

	if (reset_blocks) {
		level = 0;
		place_barrier(3, 27);
		place_barrier(11, 27);
		place_barrier(20, 27);
		place_barrier(28, 27);
		reset_blocks = false;
	} else {
		level++;
	}

	for (int x = 0; x < 32; x++)
	for (int y = 0; y < 32; y++)
		if (blocks[y] & (1 << x))
			setpixel(x, y, 0, 50, 50);
		else
			setpixel(x, y, 0, 0, 0);

	for (int x = 0; x < 32 && x < level; x++)
		setpixel(x, 0, 200, 200, 0);

	for (int x = 0; x < 4; x++)
	for (int y = 0; y < 4; y++)
		place_invader(4*x+y, 6 + 5*x, 2 + 4*y);

	player_x = 10;
	move_player_right();

	uint32_t ctrlbits = *(volatile uint32_t*)0x20000014;
	bool old_fire = false;
	int old_pos = ctrlbits >> 6;
	old_pos = old_pos ^ (old_pos >> 1);

	uint32_t num_cycles_now, num_cycles_last;
	asm volatile ("rdcycle %0" : "=r"(num_cycles_last));

	while (1)
	{
		ctrlbits = *(volatile uint32_t*)0x20000014;
		bool new_fire = !((ctrlbits >> 5) & 1);
		int new_pos = ctrlbits >> 6;
		new_pos = new_pos ^ (new_pos >> 1);

		if (new_pos == ((old_pos+1) & 3))
			move_player_left();

		if (new_pos == ((old_pos-1) & 3))
			move_player_right();

		if (new_fire && !old_fire) {
			setpixel(player_bullet_x, player_bullet_y, 0, 0, 0);
			player_bullet_x = player_x;
			player_bullet_y = 29;
			setpixel(player_bullet_x, player_bullet_y, 255, 255, 255);
		}
		
		asm volatile ("rdcycle %0" : "=r"(num_cycles_now));
		if (num_cycles_now - num_cycles_last > 100000)
		{
			num_cycles_last = num_cycles_last + 100000;

			if (invader_bullet_y >= 0)
			{
				setpixel(invader_bullet_x, invader_bullet_y, 0, 0, 0);
				invader_bullet_y++;

				if (invader_bullet_y >= 32) {
					invader_bullet_y = -1;
				} else if (blocks[invader_bullet_y] & (1 << invader_bullet_x)) {
					setpixel(invader_bullet_x, invader_bullet_y, 0, 0, 0);
					blocks[invader_bullet_y] &= ~(1 << invader_bullet_x);
					invader_bullet_y = -1;
				} else {
					setpixel(invader_bullet_x, invader_bullet_y, 255, 0, 0);
					if (invader_bullet_y >= 30 && player_x-1 <= invader_bullet_x && player_x+1 >= invader_bullet_x) {
						for (int i = 0; i < 100000; i++)
							asm volatile ("");
						reset_blocks = true;
						return;
					}
				}
			}

			if (player_bullet_y >= 0)
			{
				setpixel(player_bullet_x, player_bullet_y, 0, 0, 0);
				player_bullet_y--;

				if (player_bullet_y == 0)
					player_bullet_y = -1;

				for (int i = 0; i < 16; i++)
					if (invaders[i].y+1 == player_bullet_y &&
							invaders[i].x-1 <= player_bullet_x &&
							invaders[i].x+1 >= player_bullet_x)
					{
						int x = invaders[i].x;
						int y = invaders[i].y;

						setpixel(x, y, 0, 0, 0);
						setpixel(x-1, y+1, 0, 0, 0);
						setpixel(x+1, y+1, 0, 0, 0);

						invaders[i].y = -1000;
						player_bullet_y = -10;
					}

				if (blocks[player_bullet_y] & (1 << player_bullet_x)) {
					setpixel(player_bullet_x, player_bullet_y, 0, 0, 0);
					blocks[player_bullet_y] &= ~(1 << player_bullet_x);
					player_bullet_y = -1;
				} else
					setpixel(player_bullet_x, player_bullet_y, 255, 255, 255);
			}
			else
			{
				bool player_won = true;

				for (int i = 0; i < 16; i++)
					if (invaders[i].y > 0)
						player_won = false;

				if (player_won) {
					for (int i = 0; i < 100000; i++)
						asm volatile ("");
					return;
				}
			}

			if (move_invader(active_invader)) {
				for (int i = 0; i < 100000; i++)
					asm volatile ("");
				reset_blocks = true;
				return;
			}

			active_invader = (active_invader + 1) % 16;
		}

		old_pos = new_pos;
		old_fire = new_fire;
	}
}

void main()
{
	printf("Space Invaders!\n");
	reset_blocks = true;
	while (1) game();
}
