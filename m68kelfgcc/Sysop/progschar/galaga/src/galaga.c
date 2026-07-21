/********************************************************************************
*    Programa    : galaga.c
*    Objetivo    : Esqueleto do jogo Galaga para MMSJ320
*********************************************************************************/
#include <string.h>

#include "mmsj320api.h"
#include "mmsj320vdp.h"
#include "mmsj320mfp.h"
#include "monitor.h"
#include "mmsjos.h"
#include "mgui.h"
#include "mguiapi.h"
#include "monitorapi.h"
#include "mmsjosapi.h"

#include "galaga.h"
#include "galagaships.h"

#define GALAGA_PLAYER_SLOT 0
#define GALAGA_SHOT_FIRST_SLOT 1
#define GALAGA_ENEMY_FIRST_SLOT 5

#define GALAGA_PLAYER_PATTERN 0
#define GALAGA_ENEMY_FIRST_PATTERN 2
#define GALAGA_SHOT_PATTERN 48
#define GALAGA_ENEMY_SHOT_PATTERN 49
#define GALAGA_EXPLOSION_PATTERN 50

#define GALAGA_PLAY_RIGHT 191
#define GALAGA_PANEL_X 192
#define GALAGA_PLAYER_MIN_X 20
#define GALAGA_PLAYER_MAX_X 176
#define GALAGA_PLAYER_STEP 4
#define GALAGA_SHOT_STEP 4
#define GALAGA_ENEMY_SHOT_STEP 3
#define GALAGA_SHOT_X_OFFSET 0
#define GALAGA_SHOT_Y_OFFSET 18
#define GALAGA_ENEMY_SHOT_X_OFFSET 0
#define GALAGA_ENEMY_SHOT_Y_OFFSET 14
#define GALAGA_SPRITE_SIZE 16
#define GALAGA_MAX_ENEMIES 24
#define GALAGA_MOVING_ENEMY_SLOTS 4
#define GALAGA_MAX_ENEMY_SHOTS 4
#define GALAGA_ENEMY_SHOT_FIRST_SLOT (GALAGA_ENEMY_FIRST_SLOT + GALAGA_MOVING_ENEMY_SLOTS)
#define GALAGA_ENEMY_STEP_DELAY 2
#define GALAGA_ENEMY_FIRE_DELAY 90
#define GALAGA_EXPLOSION_DELAY 2500
#define GALAGA_RESPAWN_DELAY 30000
#define GALAGA_INPUT_HOLD 6
#define GALAGA_FIRE_COOLDOWN 8
#define GALAGA_NO_SLOT 255
#define GALAGA_G2_PATTERN_TABLE 0x0000
#define GALAGA_G2_COLOR_TABLE   0x2000

static unsigned char *vdpData = (unsigned char *)0x00400041;
static GalagaSprite sprites[GALAGA_SPRITE_COUNT];

static unsigned int galaga_g2_offset(unsigned char x, unsigned char y);
static void galaga_set_byte(unsigned char x, unsigned char y, unsigned char value, unsigned char color);
static void galaga_clear_screen(void);
static unsigned int galaga_sprite_handle(unsigned char slot);
static void galaga_hide_sprite_vdp(unsigned char slot);
static void galaga_clear_bitmap16(unsigned char x, unsigned char y);
static void galaga_play_explosion(unsigned char slot, unsigned char x, unsigned char y);
static void galaga_draw_bitmap16(unsigned char x, unsigned char y, const unsigned char *data, unsigned char color);

typedef struct
{
    unsigned char x;
    unsigned char y;
    unsigned char active;
} GalagaShot;

typedef struct
{
    unsigned char x;
    unsigned char y;
    unsigned char target_x;
    unsigned char target_y;
    unsigned int start_delay;
    const unsigned char *image;
    unsigned char color;
} GalagaEnemyPlan;

typedef struct
{
    const GalagaEnemyPlan *enemies;
    unsigned char enemy_count;
} GalagaWave;

typedef struct
{
    const GalagaWave *waves;
    unsigned char wave_count;
} GalagaLevel;

typedef struct
{
    unsigned char slot;
    unsigned char pattern;
    unsigned char x;
    unsigned char y;
    unsigned char target_x;
    unsigned char target_y;
    unsigned char active;
    unsigned char settled;
    unsigned char spawned;
    unsigned int start_delay;
    unsigned char step_tick;
    const unsigned char *image;
    unsigned char color;
} GalagaEnemy;

static const GalagaEnemyPlan level1_wave1[] = {
    {0, 30, 24, 34, 0, enemyShip01_000, VDP_CYAN},
    {60, 0, 44, 34, 8, enemyShip02_000, VDP_LIGHT_RED},
    {0, 30, 64, 34, 16, enemyShip03_000, VDP_LIGHT_YELLOW},
    {60, 0, 84, 34, 24, enemyShip04_000, VDP_LIGHT_GREEN},

    {176, 30, 104, 34, 54, enemyShip05_000, VDP_CYAN},
    {120, 0, 124, 34, 62, enemyShip06_000, VDP_LIGHT_RED},
    {176, 30, 144, 34, 70, enemyShip07_000, VDP_LIGHT_YELLOW},
    {120, 0, 164, 34, 78, enemyShip08_000, VDP_LIGHT_GREEN},

    {0, 120, 24, 54, 108, enemyShip09_000, VDP_CYAN},
    {176, 120, 44, 54, 116, enemyShip10_000, VDP_LIGHT_RED},
    {0, 120, 64, 54, 124, enemyShip01_000, VDP_LIGHT_YELLOW},
    {176, 120, 84, 54, 132, enemyShip02_000, VDP_LIGHT_GREEN},

    {60, 0, 104, 54, 162, enemyShip03_000, VDP_CYAN},
    {0, 30, 124, 54, 170, enemyShip04_000, VDP_LIGHT_RED},
    {60, 0, 144, 54, 178, enemyShip05_000, VDP_LIGHT_YELLOW},
    {0, 30, 164, 54, 186, enemyShip06_000, VDP_LIGHT_GREEN},

    {120, 0, 24, 74, 216, enemyShip07_000, VDP_CYAN},
    {176, 30, 44, 74, 224, enemyShip08_000, VDP_LIGHT_RED},
    {120, 0, 64, 74, 232, enemyShip09_000, VDP_LIGHT_YELLOW},
    {176, 30, 84, 74, 240, enemyShip10_000, VDP_LIGHT_GREEN},

    {0, 120, 104, 74, 270, enemyShip01_000, VDP_CYAN},
    {176, 120, 124, 74, 278, enemyShip02_000, VDP_LIGHT_RED},
    {0, 120, 144, 74, 286, enemyShip03_000, VDP_LIGHT_YELLOW},
    {176, 120, 164, 74, 294, enemyShip04_000, VDP_LIGHT_GREEN}
};

static const GalagaEnemyPlan level1_wave2[] = {
    {176, 30, 24, 34, 0, enemyShip10_000, VDP_LIGHT_RED},
    {120, 0, 44, 34, 8, enemyShip09_000, VDP_CYAN},
    {176, 30, 64, 34, 16, enemyShip08_000, VDP_LIGHT_YELLOW},
    {120, 0, 84, 34, 24, enemyShip07_000, VDP_LIGHT_GREEN},

    {0, 30, 104, 34, 54, enemyShip06_000, VDP_LIGHT_RED},
    {60, 0, 124, 34, 62, enemyShip05_000, VDP_CYAN},
    {0, 30, 144, 34, 70, enemyShip04_000, VDP_LIGHT_YELLOW},
    {60, 0, 164, 34, 78, enemyShip03_000, VDP_LIGHT_GREEN},

    {176, 120, 24, 54, 108, enemyShip02_000, VDP_LIGHT_RED},
    {0, 120, 44, 54, 116, enemyShip01_000, VDP_CYAN},
    {176, 120, 64, 54, 124, enemyShip10_000, VDP_LIGHT_YELLOW},
    {0, 120, 84, 54, 132, enemyShip09_000, VDP_LIGHT_GREEN},

    {120, 0, 104, 54, 162, enemyShip08_000, VDP_LIGHT_RED},
    {176, 30, 124, 54, 170, enemyShip07_000, VDP_CYAN},
    {120, 0, 144, 54, 178, enemyShip06_000, VDP_LIGHT_YELLOW},
    {176, 30, 164, 54, 186, enemyShip05_000, VDP_LIGHT_GREEN},

    {60, 0, 24, 74, 216, enemyShip04_000, VDP_LIGHT_RED},
    {0, 30, 44, 74, 224, enemyShip03_000, VDP_CYAN},
    {60, 0, 64, 74, 232, enemyShip02_000, VDP_LIGHT_YELLOW},
    {0, 30, 84, 74, 240, enemyShip01_000, VDP_LIGHT_GREEN},

    {176, 120, 104, 74, 270, enemyShip05_000, VDP_LIGHT_RED},
    {0, 120, 124, 74, 278, enemyShip06_000, VDP_CYAN},
    {176, 120, 144, 74, 286, enemyShip07_000, VDP_LIGHT_YELLOW},
    {0, 120, 164, 74, 294, enemyShip08_000, VDP_LIGHT_GREEN}
};

static const GalagaWave level1_waves[] = {
    {level1_wave1, sizeof(level1_wave1) / sizeof(level1_wave1[0])},
    {level1_wave2, sizeof(level1_wave2) / sizeof(level1_wave2[0])}
};

static const GalagaLevel levels[] = {
    {level1_waves, sizeof(level1_waves) / sizeof(level1_waves[0])}
};

static void galaga_vram_write(unsigned int addr, unsigned char value)
{
    setWriteAddress(addr);
    *vdpData = value;
}

static void galaga_wait(unsigned int ticks)
{
    volatile unsigned int i;

    for (i = 0; i < ticks; i++)
        ;
}

void galaga_hide_all_sprites(void)
{
    unsigned char slot;

    for (slot = 0; slot < GALAGA_SPRITE_COUNT; slot++)
        galaga_hide_sprite(slot);
}

void galaga_set_sprite_pattern(unsigned char pattern, const unsigned char *data)
{
    unsigned int addr;
    unsigned char ix;

    addr = GALAGA_SPR_PAT + ((unsigned int)pattern * 32);
    for (ix = 0; ix < 32; ix++)
        galaga_vram_write(addr + ix, data[ix]);
}

void galaga_put_sprite(unsigned char slot, unsigned char pattern, unsigned char x, unsigned char y, unsigned char color)
{
    unsigned int addr;

    if (slot >= GALAGA_SPRITE_COUNT)
        return;

    sprites[slot].x = x;
    sprites[slot].y = y;
    sprites[slot].pattern = pattern;
    sprites[slot].color = color;
    sprites[slot].active = 1;

    addr = galaga_sprite_handle(slot);
    galaga_vram_write(addr, y);
    galaga_vram_write(addr + 1, x);
    galaga_vram_write(addr + 2, (unsigned char)(pattern * 4));
    galaga_vram_write(addr + 3, color & 0x0F);
}

void galaga_create_sprite(unsigned char slot, unsigned char pattern, const unsigned char *data, unsigned char x, unsigned char y, unsigned char color)
{
    galaga_set_sprite_pattern(pattern, data);
    galaga_put_sprite(slot, pattern, x, y, color);
}

void galaga_move_sprite(unsigned char slot, unsigned char x, unsigned char y)
{
    unsigned int addr;

    if (slot >= GALAGA_SPRITE_COUNT || !sprites[slot].active)
        return;

    sprites[slot].x = x;
    sprites[slot].y = y;

    addr = galaga_sprite_handle(slot);
    galaga_vram_write(addr, y);
    galaga_vram_write(addr + 1, x);
}

void galaga_hide_sprite(unsigned char slot)
{
    if (slot >= GALAGA_SPRITE_COUNT)
        return;

    sprites[slot].active = 0;
    galaga_hide_sprite_vdp(slot);
}

static unsigned int galaga_sprite_handle(unsigned char slot)
{
    return GALAGA_SPR_ATTR + ((unsigned int)slot * 4);
}

static void galaga_hide_sprite_vdp(unsigned char slot)
{
    unsigned int addr;

    addr = galaga_sprite_handle(slot);
    galaga_vram_write(addr, 192);
    galaga_vram_write(addr + 1, 0);
    galaga_vram_write(addr + 2, 0);
    galaga_vram_write(addr + 3, VDP_TRANSPARENT);
}

void galaga_init_video(void)
{
    vdp_init(VDP_MODE_G2, 0x00, 1, 0);
    vdp_set_bdcolor(VDP_BLACK);
    galaga_clear_screen();
    galaga_hide_all_sprites();
}

static unsigned char galaga_get_key(void)
{
    MMSJ_KEYEVENT k;

    if (!mmsjKeyGet(&k))
        return KEY_NONE;

    if (!(k.flags & KEY_CTRL))
        return k.ascii;

    return k.raw;
}

static unsigned int galaga_g2_offset(unsigned char x, unsigned char y)
{
    return (unsigned int)(8 * (x / 8)) + (y % 8) + (unsigned int)(256 * (y / 8));
}

static void galaga_set_byte(unsigned char x, unsigned char y, unsigned char value, unsigned char color)
{
    unsigned int offset;

    offset = galaga_g2_offset(x, y);
    galaga_vram_write(GALAGA_G2_PATTERN_TABLE + offset, value);
    galaga_vram_write(GALAGA_G2_COLOR_TABLE + offset, (unsigned char)((VDP_BLACK & 0x0F) | ((color & 0x0F) << 4)));
}

static void galaga_clear_screen(void)
{
    unsigned int ix;

    for (ix = 0; ix < 0x1800; ix++)
    {
        galaga_vram_write(GALAGA_G2_PATTERN_TABLE + ix, 0x00);
        galaga_vram_write(GALAGA_G2_COLOR_TABLE + ix, (unsigned char)((VDP_BLACK & 0x0F) | ((VDP_BLACK & 0x0F) << 4)));
    }
}

static void galaga_draw_bitmap16(unsigned char x, unsigned char y, const unsigned char *data, unsigned char color)
{
    unsigned char row;

    for (row = 0; row < 16; row++)
    {
        galaga_set_byte(x, y + row, data[row], color);
        galaga_set_byte(x + 8, y + row, data[row + 16], color);
    }
}

static void galaga_clear_bitmap16(unsigned char x, unsigned char y)
{
    unsigned char row;

    for (row = 0; row < GALAGA_SPRITE_SIZE; row++)
    {
        galaga_set_byte(x, y + row, 0x00, VDP_BLACK);
        galaga_set_byte(x + 8, y + row, 0x00, VDP_BLACK);
    }
}

static unsigned char galaga_bitmap_pixel(const unsigned char *data, unsigned char x, unsigned char y)
{
    if (x >= GALAGA_SPRITE_SIZE || y >= GALAGA_SPRITE_SIZE)
        return 0;

    if (x < 8)
        return (data[y] & (0x80 >> x)) != 0;

    return (data[y + GALAGA_SPRITE_SIZE] & (0x80 >> (x - 8))) != 0;
}

static unsigned char galaga_bitmap_overlap(unsigned char ax, unsigned char ay, const unsigned char *adata,
                                           unsigned char bx, unsigned char by, const unsigned char *bdata)
{
    int left;
    int right;
    int top;
    int bottom;
    int x;
    int y;

    left = ax > bx ? ax : bx;
    top = ay > by ? ay : by;
    right = (ax + GALAGA_SPRITE_SIZE - 1) < (bx + GALAGA_SPRITE_SIZE - 1) ? (ax + GALAGA_SPRITE_SIZE - 1) : (bx + GALAGA_SPRITE_SIZE - 1);
    bottom = (ay + GALAGA_SPRITE_SIZE - 1) < (by + GALAGA_SPRITE_SIZE - 1) ? (ay + GALAGA_SPRITE_SIZE - 1) : (by + GALAGA_SPRITE_SIZE - 1);

    if (left > right || top > bottom)
        return 0;

    for (y = top; y <= bottom; y++)
    {
        for (x = left; x <= right; x++)
        {
            if (galaga_bitmap_pixel(adata, (unsigned char)(x - ax), (unsigned char)(y - ay)) &&
                galaga_bitmap_pixel(bdata, (unsigned char)(x - bx), (unsigned char)(y - by)))
                return 1;
        }
    }

    return 0;
}

static void galaga_play_explosion(unsigned char slot, unsigned char x, unsigned char y)
{
    const unsigned char *frames[4];
    unsigned char ix;

    frames[0] = explosion_000;
    frames[1] = explosion_001;
    frames[2] = explosion_002;
    frames[3] = explosion_003;

    for (ix = 0; ix < 4; ix++)
    {
        galaga_set_sprite_pattern(GALAGA_EXPLOSION_PATTERN, frames[ix]);
        galaga_put_sprite(slot, GALAGA_EXPLOSION_PATTERN, x, y, VDP_WHITE);
        galaga_wait(GALAGA_EXPLOSION_DELAY);
    }

    galaga_hide_sprite(slot);
}

static unsigned char galaga_font_row(unsigned char chr, unsigned char row)
{
    static const unsigned char digits[10][7] = {
        {0x0E, 0x11, 0x13, 0x15, 0x19, 0x11, 0x0E},
        {0x04, 0x0C, 0x04, 0x04, 0x04, 0x04, 0x0E},
        {0x0E, 0x11, 0x01, 0x02, 0x04, 0x08, 0x1F},
        {0x1E, 0x01, 0x01, 0x0E, 0x01, 0x01, 0x1E},
        {0x02, 0x06, 0x0A, 0x12, 0x1F, 0x02, 0x02},
        {0x1F, 0x10, 0x10, 0x1E, 0x01, 0x01, 0x1E},
        {0x0E, 0x10, 0x10, 0x1E, 0x11, 0x11, 0x0E},
        {0x1F, 0x01, 0x02, 0x04, 0x08, 0x08, 0x08},
        {0x0E, 0x11, 0x11, 0x0E, 0x11, 0x11, 0x0E},
        {0x0E, 0x11, 0x11, 0x0F, 0x01, 0x01, 0x0E}
    };
    static const unsigned char font_a[7] = {0x0E, 0x11, 0x11, 0x1F, 0x11, 0x11, 0x11};
    static const unsigned char font_c[7] = {0x0F, 0x10, 0x10, 0x10, 0x10, 0x10, 0x0F};
    static const unsigned char font_e[7] = {0x1F, 0x10, 0x10, 0x1E, 0x10, 0x10, 0x1F};
    static const unsigned char font_g[7] = {0x0F, 0x10, 0x10, 0x17, 0x11, 0x11, 0x0F};
    static const unsigned char font_h[7] = {0x11, 0x11, 0x11, 0x1F, 0x11, 0x11, 0x11};
    static const unsigned char font_i[7] = {0x0E, 0x04, 0x04, 0x04, 0x04, 0x04, 0x0E};
    static const unsigned char font_k[7] = {0x11, 0x12, 0x14, 0x18, 0x14, 0x12, 0x11};
    static const unsigned char font_l[7] = {0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x1F};
    static const unsigned char font_m[7] = {0x11, 0x1B, 0x15, 0x15, 0x11, 0x11, 0x11};
    static const unsigned char font_n[7] = {0x11, 0x19, 0x15, 0x13, 0x11, 0x11, 0x11};
    static const unsigned char font_o[7] = {0x0E, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0E};
    static const unsigned char font_p[7] = {0x1E, 0x11, 0x11, 0x1E, 0x10, 0x10, 0x10};
    static const unsigned char font_r[7] = {0x1E, 0x11, 0x11, 0x1E, 0x14, 0x12, 0x11};
    static const unsigned char font_s[7] = {0x0F, 0x10, 0x10, 0x0E, 0x01, 0x01, 0x1E};
    static const unsigned char font_v[7] = {0x11, 0x11, 0x11, 0x11, 0x0A, 0x0A, 0x04};
    static const unsigned char font_x[7] = {0x11, 0x11, 0x0A, 0x04, 0x0A, 0x11, 0x11};
    static const unsigned char font_y[7] = {0x11, 0x11, 0x0A, 0x04, 0x04, 0x04, 0x04};

    if (row >= 7)
        return 0;

    if (chr >= '0' && chr <= '9')
        return digits[chr - '0'][row];

    switch (chr)
    {
    case 'A':
        return font_a[row];
    case 'C':
        return font_c[row];
    case 'E':
        return font_e[row];
    case 'G':
        return font_g[row];
    case 'H':
        return font_h[row];
    case 'I':
        return font_i[row];
    case 'K':
        return font_k[row];
    case 'L':
        return font_l[row];
    case 'M':
        return font_m[row];
    case 'N':
        return font_n[row];
    case 'O':
        return font_o[row];
    case 'P':
        return font_p[row];
    case 'R':
        return font_r[row];
    case 'S':
        return font_s[row];
    case 'V':
        return font_v[row];
    case 'X':
        return font_x[row];
    case 'Y':
        return font_y[row];
    default:
        return 0;
    }
}

static void galaga_draw_char(unsigned char x, unsigned char y, unsigned char chr, unsigned char color)
{
    unsigned char row;

    for (row = 0; row < 7; row++)
        galaga_set_byte(x, y + row, (unsigned char)(galaga_font_row(chr, row) << 3), color);
}

static void galaga_draw_text(unsigned char x, unsigned char y, const char *text, unsigned char color)
{
    while (*text)
    {
        galaga_draw_char(x, y, (unsigned char)*text, color);
        x += 8;
        text++;
    }
}

static void galaga_draw_number(unsigned char x, unsigned char y, unsigned long value, unsigned char digits, unsigned char color)
{
    unsigned long divisor;
    unsigned char ix;

    divisor = 1;
    for (ix = 1; ix < digits; ix++)
        divisor *= 10;

    for (ix = 0; ix < digits; ix++)
    {
        galaga_draw_char(x, y, (unsigned char)('0' + ((value / divisor) % 10)), color);
        value %= divisor;
        divisor /= 10;
        x += 8;
    }
}

static void galaga_clear_panel(void)
{
    unsigned char col;
    unsigned char y;

    for (y = 0; y < GALAGA_SCREEN_H; y++)
    {
        for (col = 0; col < 7; col++)
            galaga_set_byte((unsigned char)(200 + (col * 8)), y, 0x00, VDP_BLACK);
    }
}

static void galaga_clear_playfield(void)
{
    unsigned char col;
    unsigned char y;

    for (y = 0; y < GALAGA_SCREEN_H; y++)
    {
        for (col = 0; col < (GALAGA_PANEL_X / 8); col++)
            galaga_set_byte((unsigned char)(col * 8), y, 0x00, VDP_BLACK);
    }
}

static void galaga_clear_hud_value(unsigned char x, unsigned char y, unsigned char cols, unsigned char rows)
{
    unsigned char col;
    unsigned char row;

    for (row = 0; row < rows; row++)
    {
        for (col = 0; col < cols; col++)
            galaga_set_byte((unsigned char)(x + (col * 8)), y + row, 0x00, VDP_BLACK);
    }
}

static void galaga_draw_hud_static(unsigned char level, unsigned char specials)
{
    unsigned char y;

    galaga_clear_panel();
    for (y = 0; y < GALAGA_SCREEN_H; y++)
        galaga_set_byte(GALAGA_PANEL_X, y, 0x80, VDP_WHITE);

    galaga_draw_text(200, 0, "LEVEL", VDP_WHITE);
    galaga_draw_number(248, 0, level, 1, VDP_LIGHT_YELLOW);

    galaga_draw_text(200, 12, "SCORE", VDP_WHITE);
    galaga_draw_text(200, 38, "HI", VDP_WHITE);

    galaga_draw_bitmap16(200, 66, playerShip_000, VDP_WHITE);
    galaga_draw_char(224, 70, 'X', VDP_WHITE);

    if (specials > 0)
        galaga_draw_bitmap16(200, 96, medalha_000, VDP_LIGHT_YELLOW);
    if (specials > 1)
        galaga_draw_bitmap16(216, 96, medalha_001, VDP_LIGHT_YELLOW);
    if (specials > 2)
        galaga_draw_bitmap16(232, 96, medalha_002, VDP_LIGHT_RED);
    if (specials > 3)
        galaga_draw_bitmap16(200, 116, medalha_003, VDP_LIGHT_RED);
    if (specials > 4)
        galaga_draw_bitmap16(216, 116, medalha_004, VDP_CYAN);
    if (specials > 5)
        galaga_draw_bitmap16(232, 116, medalha_005, VDP_CYAN);
}

static void galaga_draw_hud_values(unsigned long score, unsigned long hiscore, unsigned char lives)
{
    galaga_clear_hud_value(200, 22, 6, 7);
    galaga_draw_number(200, 22, score, 6, VDP_LIGHT_YELLOW);

    galaga_clear_hud_value(200, 48, 6, 7);
    galaga_draw_number(200, 48, hiscore, 6, VDP_CYAN);

    galaga_clear_hud_value(240, 70, 1, 7);
    galaga_draw_number(240, 70, lives, 1, VDP_WHITE);
}

static void galaga_draw_hud(unsigned char level, unsigned long score, unsigned long hiscore, unsigned char lives, unsigned char specials)
{
    galaga_draw_hud_static(level, specials);
    galaga_draw_hud_values(score, hiscore, lives);
}

static void galaga_init_shots(GalagaShot *shots)
{
    memset(shots, 0, sizeof(GalagaShot) * GALAGA_MAX_SHOTS);
    galaga_set_sprite_pattern(GALAGA_SHOT_PATTERN, shootShip_000);
}

static void galaga_fire_shot(GalagaShot *shots, unsigned char player_x, unsigned char player_y)
{
    unsigned char ix;

    for (ix = 0; ix < GALAGA_MAX_SHOTS; ix++)
    {
        if (!shots[ix].active)
        {
            shots[ix].x = player_x + GALAGA_SHOT_X_OFFSET;
            shots[ix].y = player_y - GALAGA_SHOT_Y_OFFSET;
            shots[ix].active = 1;

            galaga_put_sprite(GALAGA_SHOT_FIRST_SLOT + ix, GALAGA_SHOT_PATTERN, shots[ix].x, shots[ix].y, VDP_WHITE);
            return;
        }
    }
}

static void galaga_update_shots(GalagaShot *shots)
{
    unsigned char ix;

    for (ix = 0; ix < GALAGA_MAX_SHOTS; ix++)
    {
        if (shots[ix].active)
        {
            if (shots[ix].y > 6)
            {
                shots[ix].y = shots[ix].y - GALAGA_SHOT_STEP;
                galaga_move_sprite(GALAGA_SHOT_FIRST_SLOT + ix, shots[ix].x, shots[ix].y);
            }
            else
            {
                shots[ix].y = 0;
                shots[ix].active = 0;
                galaga_hide_sprite(GALAGA_SHOT_FIRST_SLOT + ix);
            }
        }
    }
}

static void galaga_init_enemy_shots(GalagaShot *shots)
{
    memset(shots, 0, sizeof(GalagaShot) * GALAGA_MAX_ENEMY_SHOTS);
    galaga_set_sprite_pattern(GALAGA_ENEMY_SHOT_PATTERN, shootShip_004);
}

static void galaga_clear_shots(GalagaShot *shots, unsigned char count, unsigned char first_slot)
{
    unsigned char ix;

    for (ix = 0; ix < count; ix++)
    {
        shots[ix].active = 0;
        shots[ix].x = 0;
        shots[ix].y = 0;
        galaga_hide_sprite(first_slot + ix);
    }
}

static void galaga_fire_enemy_shot(GalagaShot *shots, unsigned char enemy_x, unsigned char enemy_y)
{
    unsigned char ix;

    for (ix = 0; ix < GALAGA_MAX_ENEMY_SHOTS; ix++)
    {
        if (!shots[ix].active)
        {
            shots[ix].x = enemy_x + GALAGA_ENEMY_SHOT_X_OFFSET;
            shots[ix].y = enemy_y + GALAGA_ENEMY_SHOT_Y_OFFSET;
            shots[ix].active = 1;

            galaga_put_sprite(GALAGA_ENEMY_SHOT_FIRST_SLOT + ix, GALAGA_ENEMY_SHOT_PATTERN, shots[ix].x, shots[ix].y, VDP_LIGHT_RED);
            return;
        }
    }
}

static void galaga_enemy_try_fire(GalagaShot *shots, GalagaEnemy *enemies, unsigned char *fire_tick, unsigned char *next_enemy)
{
    unsigned char tries;
    unsigned char ix;
    GalagaEnemy *enemy;

    (*fire_tick)++;
    if (*fire_tick < GALAGA_ENEMY_FIRE_DELAY)
        return;
    *fire_tick = 0;

    for (tries = 0; tries < GALAGA_MAX_ENEMIES; tries++)
    {
        ix = *next_enemy;
        *next_enemy = (unsigned char)((*next_enemy + 1) % GALAGA_MAX_ENEMIES);
        enemy = &enemies[ix];

        if (enemy->active && enemy->spawned)
        {
            galaga_fire_enemy_shot(shots, enemy->x, enemy->y);
            return;
        }
    }
}

static void galaga_update_enemy_shots(GalagaShot *shots)
{
    unsigned char ix;

    for (ix = 0; ix < GALAGA_MAX_ENEMY_SHOTS; ix++)
    {
        if (shots[ix].active)
        {
            if (shots[ix].y < 178)
            {
                shots[ix].y = shots[ix].y + GALAGA_ENEMY_SHOT_STEP;
                galaga_move_sprite(GALAGA_ENEMY_SHOT_FIRST_SLOT + ix, shots[ix].x, shots[ix].y);
            }
            else
            {
                shots[ix].active = 0;
                galaga_hide_sprite(GALAGA_ENEMY_SHOT_FIRST_SLOT + ix);
            }
        }
    }
}

static unsigned char galaga_check_player_hits(GalagaShot *shots, unsigned char player_x, unsigned char player_y)
{
    unsigned char ix;

    for (ix = 0; ix < GALAGA_MAX_ENEMY_SHOTS; ix++)
    {
        if (!shots[ix].active)
            continue;

        if (galaga_bitmap_overlap(shots[ix].x, shots[ix].y, shootShip_004,
                                  player_x, player_y, playerShip_000))
        {
            shots[ix].active = 0;
            galaga_hide_sprite(GALAGA_ENEMY_SHOT_FIRST_SLOT + ix);
            return 1;
        }
    }

    return 0;
}

static unsigned char galaga_alloc_enemy_slot(GalagaEnemy *enemies)
{
    unsigned char slot;
    unsigned char ix;
    unsigned char used;

    for (slot = GALAGA_ENEMY_FIRST_SLOT; slot < GALAGA_ENEMY_FIRST_SLOT + GALAGA_MOVING_ENEMY_SLOTS; slot++)
    {
        used = 0;
        for (ix = 0; ix < GALAGA_MAX_ENEMIES; ix++)
        {
            if (enemies[ix].active && enemies[ix].spawned && !enemies[ix].settled && enemies[ix].slot == slot)
            {
                used = 1;
                break;
            }
        }

        if (!used)
            return slot;
    }

    return GALAGA_NO_SLOT;
}

static void galaga_init_enemies(GalagaEnemy *enemies, const GalagaWave *wave)
{
    unsigned char ix;

    memset(enemies, 0, sizeof(GalagaEnemy) * GALAGA_MAX_ENEMIES);

    for (ix = 0; ix < GALAGA_MAX_ENEMIES; ix++)
    {
        enemies[ix].slot = GALAGA_NO_SLOT;
        enemies[ix].active = 0;
    }

    for (ix = 0; ix < wave->enemy_count && ix < GALAGA_MAX_ENEMIES; ix++)
    {
        enemies[ix].slot = GALAGA_NO_SLOT;
        enemies[ix].pattern = 0;
        enemies[ix].x = wave->enemies[ix].x;
        enemies[ix].y = wave->enemies[ix].y;
        enemies[ix].target_x = wave->enemies[ix].target_x;
        enemies[ix].target_y = wave->enemies[ix].target_y;
        enemies[ix].image = wave->enemies[ix].image;
        enemies[ix].color = wave->enemies[ix].color;
        enemies[ix].active = 1;
        enemies[ix].spawned = 0;
        enemies[ix].start_delay = wave->enemies[ix].start_delay;
    }

    for (ix = 0; ix < GALAGA_MOVING_ENEMY_SLOTS; ix++)
        galaga_hide_sprite(GALAGA_ENEMY_FIRST_SLOT + ix);
}

static unsigned char galaga_wave_done(GalagaEnemy *enemies)
{
    unsigned char ix;

    for (ix = 0; ix < GALAGA_MAX_ENEMIES; ix++)
    {
        if (enemies[ix].active)
            return 0;
    }

    return 1;
}

static void galaga_update_enemies(GalagaEnemy *enemies)
{
    unsigned char ix;
    GalagaEnemy *e;

    for (ix = 0; ix < GALAGA_MAX_ENEMIES; ix++)
    {
        e = &enemies[ix];

        if (!e->active || e->settled)
            continue;

        if (!e->spawned)
        {
            if (e->start_delay)
            {
                e->start_delay--;
                continue;
            }

            e->slot = galaga_alloc_enemy_slot(enemies);
            if (e->slot == GALAGA_NO_SLOT)
                continue;

            e->pattern = (unsigned char)(GALAGA_ENEMY_FIRST_PATTERN + (e->slot - GALAGA_ENEMY_FIRST_SLOT));
            e->spawned = 1;
            e->step_tick = 0;
            galaga_create_sprite(e->slot, e->pattern, e->image, e->x, e->y, e->color);
        }

        e->step_tick++;
        if (e->step_tick < GALAGA_ENEMY_STEP_DELAY)
            continue;
        e->step_tick = 0;

        if (e->x < e->target_x)
            e->x++;
        else if (e->x > e->target_x)
            e->x--;

        if (e->y < e->target_y)
            e->y++;
        else if (e->y > e->target_y)
            e->y--;

        if (e->x == e->target_x && e->y == e->target_y)
        {
            e->settled = 1;
            galaga_hide_sprite(e->slot);
            e->slot = GALAGA_NO_SLOT;
            e->pattern = 0;
            galaga_draw_bitmap16(e->x, e->y, e->image, e->color);
        }
        else
        {
            galaga_move_sprite(e->slot, e->x, e->y);
        }
    }
}

static void galaga_destroy_enemy(GalagaEnemy *enemy, GalagaEnemy *enemies)
{
    unsigned char explosion_slot;

    if (!enemy->active)
        return;

    explosion_slot = enemy->slot;
    if (enemy->settled)
    {
        galaga_clear_bitmap16(enemy->x, enemy->y);
        explosion_slot = galaga_alloc_enemy_slot(enemies);
    }

    enemy->active = 0;
    enemy->settled = 0;
    enemy->spawned = 0;
    enemy->slot = GALAGA_NO_SLOT;

    if (explosion_slot != GALAGA_NO_SLOT)
        galaga_play_explosion(explosion_slot, enemy->x, enemy->y);
}

static unsigned char galaga_check_shot_hits(GalagaShot *shots, GalagaEnemy *enemies)
{
    unsigned char shot_ix;
    unsigned char enemy_ix;
    unsigned char hits;
    GalagaEnemy *enemy;

    hits = 0;

    for (shot_ix = 0; shot_ix < GALAGA_MAX_SHOTS; shot_ix++)
    {
        if (!shots[shot_ix].active)
            continue;

        for (enemy_ix = 0; enemy_ix < GALAGA_MAX_ENEMIES; enemy_ix++)
        {
            enemy = &enemies[enemy_ix];

            if (!enemy->active || !enemy->spawned)
                continue;

            if (galaga_bitmap_overlap(shots[shot_ix].x, shots[shot_ix].y, shootShip_000,
                                      enemy->x, enemy->y, enemy->image))
            {
                shots[shot_ix].active = 0;
                galaga_hide_sprite(GALAGA_SHOT_FIRST_SLOT + shot_ix);
                galaga_destroy_enemy(enemy, enemies);
                hits++;
                break;
            }
        }
    }

    return hits;
}

static void galaga_wait_any_key(void)
{
    while (galaga_get_key() != KEY_NONE)
        ;

    while (galaga_get_key() == KEY_NONE)
        ;
}

static void galaga_show_game_over(void)
{
    galaga_hide_all_sprites();
    galaga_clear_playfield();
    galaga_draw_text(60, 78, "GAME OVER", VDP_LIGHT_RED);
    galaga_draw_text(44, 98, "PRESS ANY KEY", VDP_WHITE);
    galaga_wait_any_key();
}

static void galaga_show_level_start(unsigned char level)
{
    galaga_clear_playfield();
    galaga_draw_text(72, 86, "LEVEL", VDP_WHITE);
    galaga_draw_number(120, 86, level, 1, VDP_LIGHT_YELLOW);
    galaga_wait(50000);
    galaga_clear_playfield();
}

static void galaga_respawn_player(GalagaShot *shots, GalagaShot *enemy_shots, unsigned char *player_x, unsigned char player_y)
{
    galaga_clear_shots(shots, GALAGA_MAX_SHOTS, GALAGA_SHOT_FIRST_SLOT);
    galaga_clear_shots(enemy_shots, GALAGA_MAX_ENEMY_SHOTS, GALAGA_ENEMY_SHOT_FIRST_SLOT);

    *player_x = 104;
    galaga_set_sprite_pattern(GALAGA_PLAYER_PATTERN, playerShip_000);
    galaga_put_sprite(GALAGA_PLAYER_SLOT, GALAGA_PLAYER_PATTERN, *player_x, player_y, VDP_WHITE);
    galaga_wait(GALAGA_RESPAWN_DELAY);
}

void main(void)
{
    unsigned char key;
    unsigned char x;
    unsigned char y;
    unsigned char hits;
    unsigned char lives;
    unsigned char specials;
    unsigned char enemy_fire_tick;
    unsigned char next_enemy_fire;
    unsigned char game_over;
    unsigned char current_level;
    unsigned char current_wave;
    unsigned char level_complete;
    unsigned char move_hold;
    unsigned char fire_cooldown;
    signed char move_dir;
    unsigned long score;
    unsigned long hiscore;
    GalagaShot shots[GALAGA_MAX_SHOTS];
    GalagaShot enemy_shots[GALAGA_MAX_ENEMY_SHOTS];
    GalagaEnemy enemies[GALAGA_MAX_ENEMIES];

    x = 104;
    y = 170;
    score = 0;
    hiscore = 0;
    lives = 3;
    specials = 6;
    enemy_fire_tick = 0;
    next_enemy_fire = 0;
    game_over = 0;
    current_level = 0;
    current_wave = 0;
    level_complete = 0;
    move_hold = 0;
    fire_cooldown = 0;
    move_dir = 0;

    galaga_init_video();
    galaga_draw_hud(current_level + 1, score, hiscore, lives, specials);
    galaga_init_shots(shots);
    galaga_init_enemy_shots(enemy_shots);
    galaga_show_level_start(current_level + 1);
    galaga_init_enemies(enemies, &levels[current_level].waves[current_wave]);
    galaga_create_sprite(GALAGA_PLAYER_SLOT, GALAGA_PLAYER_PATTERN, playerShip_000, x, y, VDP_WHITE);

    while (1)
    {
        while ((key = galaga_get_key()) != KEY_NONE)
        {
            if (key == KEY_ESC)
                break;

            if (key == 'A' || key == 'a' || key == KEY_LEFT)
            {
                move_dir = -1;
                move_hold = GALAGA_INPUT_HOLD;
            }
            else if (key == 'D' || key == 'd' || key == KEY_RIGHT)
            {
                move_dir = 1;
                move_hold = GALAGA_INPUT_HOLD;
            }
            else if (key == ' ' && !fire_cooldown)
            {
                galaga_fire_shot(shots, x, y);
                fire_cooldown = GALAGA_FIRE_COOLDOWN;
            }
        }

        if (key == KEY_ESC)
            break;

        if (move_hold)
        {
            if (move_dir < 0)
            {
                if (x > GALAGA_PLAYER_MIN_X + GALAGA_PLAYER_STEP)
                    x -= GALAGA_PLAYER_STEP;
                else
                    x = GALAGA_PLAYER_MIN_X;
            }
            else if (move_dir > 0)
            {
                if (x < GALAGA_PLAYER_MAX_X - GALAGA_PLAYER_STEP)
                    x += GALAGA_PLAYER_STEP;
                else
                    x = GALAGA_PLAYER_MAX_X;
            }

            move_hold--;
        }

        if (fire_cooldown)
            fire_cooldown--;

        galaga_update_shots(shots);
        galaga_update_enemies(enemies);
        galaga_enemy_try_fire(enemy_shots, enemies, &enemy_fire_tick, &next_enemy_fire);
        galaga_update_enemy_shots(enemy_shots);
        hits = galaga_check_shot_hits(shots, enemies);
        if (hits)
        {
            score += (unsigned long)hits * 100;
            if (score > hiscore)
                hiscore = score;
            galaga_draw_hud_values(score, hiscore, lives);
        }
        if (galaga_check_player_hits(enemy_shots, x, y))
        {
            galaga_clear_shots(shots, GALAGA_MAX_SHOTS, GALAGA_SHOT_FIRST_SLOT);
            galaga_clear_shots(enemy_shots, GALAGA_MAX_ENEMY_SHOTS, GALAGA_ENEMY_SHOT_FIRST_SLOT);
            galaga_play_explosion(GALAGA_PLAYER_SLOT, x, y);

            if (lives)
                lives--;
            galaga_draw_hud_values(score, hiscore, lives);
            if (!lives)
            {
                game_over = 1;
                break;
            }

            enemy_fire_tick = 0;
            move_hold = 0;
            move_dir = 0;
            fire_cooldown = 0;
            galaga_respawn_player(shots, enemy_shots, &x, y);
        }

        if (!level_complete && galaga_wave_done(enemies))
        {
            current_wave++;
            if (current_wave < levels[current_level].wave_count)
            {
                galaga_clear_shots(shots, GALAGA_MAX_SHOTS, GALAGA_SHOT_FIRST_SLOT);
                galaga_clear_shots(enemy_shots, GALAGA_MAX_ENEMY_SHOTS, GALAGA_ENEMY_SHOT_FIRST_SLOT);
                enemy_fire_tick = 0;
                next_enemy_fire = 0;
                galaga_init_enemies(enemies, &levels[current_level].waves[current_wave]);
            }
            else
            {
                current_level++;
                if (current_level < (sizeof(levels) / sizeof(levels[0])))
                {
                    current_wave = 0;
                    galaga_clear_shots(shots, GALAGA_MAX_SHOTS, GALAGA_SHOT_FIRST_SLOT);
                    galaga_clear_shots(enemy_shots, GALAGA_MAX_ENEMY_SHOTS, GALAGA_ENEMY_SHOT_FIRST_SLOT);
                    enemy_fire_tick = 0;
                    next_enemy_fire = 0;
                    galaga_draw_hud(current_level + 1, score, hiscore, lives, specials);
                    galaga_hide_sprite(GALAGA_PLAYER_SLOT);
                    galaga_show_level_start(current_level + 1);
                    galaga_init_enemies(enemies, &levels[current_level].waves[current_wave]);
                    galaga_set_sprite_pattern(GALAGA_PLAYER_PATTERN, playerShip_000);
                    galaga_put_sprite(GALAGA_PLAYER_SLOT, GALAGA_PLAYER_PATTERN, x, y, VDP_WHITE);
                }
                else
                {
                    level_complete = 1;
                }
            }
        }
        galaga_move_sprite(GALAGA_PLAYER_SLOT, x, y);
        galaga_wait(2000);
    }

    if (game_over)
        galaga_show_game_over();
    else
        galaga_hide_all_sprites();

    if (*startBasic == 1)
    {
        setModeVideoOS(VDP_MODE_TEXT);
        clearScr();
    }
    else
    {
        vdp_init(VDP_MODE_G2, VDP_BLACK, 0, 0);
        vdp_set_bdcolor(VDP_BLACK);
    }
}
