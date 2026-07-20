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
#define GALAGA_SHOT_PATTERN 1
#define GALAGA_ENEMY_FIRST_PATTERN 2

#define GALAGA_PLAY_RIGHT 191
#define GALAGA_PANEL_X 192
#define GALAGA_PLAYER_MIN_X 20
#define GALAGA_PLAYER_MAX_X 176
#define GALAGA_PLAYER_STEP 4
#define GALAGA_SHOT_STEP 4
#define GALAGA_SHOT_X_OFFSET 0
#define GALAGA_SHOT_Y_OFFSET 18
#define GALAGA_MAX_ENEMIES 3
#define GALAGA_G2_PATTERN_TABLE 0x0000
#define GALAGA_G2_COLOR_TABLE   0x2000

static unsigned char *vdpData = (unsigned char *)0x00400041;
static GalagaSprite sprites[GALAGA_SPRITE_COUNT];

static unsigned int galaga_g2_offset(unsigned char x, unsigned char y);
static void galaga_set_byte(unsigned char x, unsigned char y, unsigned char value, unsigned char color);
static void galaga_clear_screen(void);

typedef struct
{
    unsigned char x;
    unsigned char y;
    unsigned char active;
} GalagaShot;

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
    const unsigned char *image;
    unsigned char color;
} GalagaEnemy;

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
    unsigned char i;

    addr = GALAGA_SPR_PAT + ((unsigned int)pattern * 32);
    for (i = 0; i < 32; i++)
        galaga_vram_write(addr + i, data[i]);
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

    addr = GALAGA_SPR_ATTR + ((unsigned int)slot * 4);
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

    addr = GALAGA_SPR_ATTR + ((unsigned int)slot * 4);
    galaga_vram_write(addr, y);
    galaga_vram_write(addr + 1, x);
}

void galaga_hide_sprite(unsigned char slot)
{
    unsigned int addr;

    if (slot >= GALAGA_SPRITE_COUNT)
        return;

    sprites[slot].active = 0;
    addr = GALAGA_SPR_ATTR + ((unsigned int)slot * 4);
    galaga_vram_write(addr, 208);
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

static void galaga_draw_hud(unsigned long score, unsigned long hiscore, unsigned char lives, unsigned char specials)
{
    unsigned char y;

    (void)score;
    (void)hiscore;
    (void)lives;
    (void)specials;

    for (y = 0; y < GALAGA_SCREEN_H; y++)
        galaga_set_byte(GALAGA_PANEL_X, y, 0x80, VDP_WHITE);
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

static void galaga_init_enemies(GalagaEnemy *enemies)
{
    memset(enemies, 0, sizeof(GalagaEnemy) * GALAGA_MAX_ENEMIES);

    enemies[0].slot = GALAGA_ENEMY_FIRST_SLOT;
    enemies[0].pattern = GALAGA_ENEMY_FIRST_PATTERN;
    enemies[0].x = 18;
    enemies[0].y = 8;
    enemies[0].target_x = 48;
    enemies[0].target_y = 44;
    enemies[0].image = enemyShip01_000;
    enemies[0].color = VDP_CYAN;
    enemies[0].active = 1;

    enemies[1].slot = GALAGA_ENEMY_FIRST_SLOT + 1;
    enemies[1].pattern = GALAGA_ENEMY_FIRST_PATTERN + 1;
    enemies[1].x = 146;
    enemies[1].y = 8;
    enemies[1].target_x = 88;
    enemies[1].target_y = 44;
    enemies[1].image = enemyShip02_000;
    enemies[1].color = VDP_LIGHT_RED;
    enemies[1].active = 1;

    enemies[2].slot = GALAGA_ENEMY_FIRST_SLOT + 2;
    enemies[2].pattern = GALAGA_ENEMY_FIRST_PATTERN + 2;
    enemies[2].x = 94;
    enemies[2].y = 4;
    enemies[2].target_x = 128;
    enemies[2].target_y = 62;
    enemies[2].image = enemyShip03_000;
    enemies[2].color = VDP_LIGHT_YELLOW;
    enemies[2].active = 1;

    galaga_create_sprite(enemies[0].slot, enemies[0].pattern, enemies[0].image, enemies[0].x, enemies[0].y, enemies[0].color);
    galaga_create_sprite(enemies[1].slot, enemies[1].pattern, enemies[1].image, enemies[1].x, enemies[1].y, enemies[1].color);
    galaga_create_sprite(enemies[2].slot, enemies[2].pattern, enemies[2].image, enemies[2].x, enemies[2].y, enemies[2].color);
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
            galaga_draw_bitmap16(e->x, e->y, e->image, e->color);
        }
        else
        {
            galaga_move_sprite(e->slot, e->x, e->y);
        }
    }
}

void main(void)
{
    unsigned char key;
    unsigned char x;
    unsigned char y;
    GalagaShot shots[GALAGA_MAX_SHOTS];
    GalagaEnemy enemies[GALAGA_MAX_ENEMIES];

    x = 104;
    y = 170;

    galaga_init_video();
    galaga_draw_hud(0, 0, 3, 0);
    galaga_init_shots(shots);
    galaga_init_enemies(enemies);
    galaga_create_sprite(GALAGA_PLAYER_SLOT, GALAGA_PLAYER_PATTERN, playerShip_000, x, y, VDP_WHITE);

    while (1)
    {
        key = galaga_get_key();

        if (key == KEY_ESC)
            break;

        if (key == 'A' || key == 'a')
        {
            if (x > GALAGA_PLAYER_MIN_X)
                x -= GALAGA_PLAYER_STEP;
        }
        else if (key == 'D' || key == 'd')
        {
            if (x < GALAGA_PLAYER_MAX_X)
                x += GALAGA_PLAYER_STEP;
        }
        else if (key == ' ')
        {
            galaga_fire_shot(shots, x, y);
        }

        galaga_update_shots(shots);
        galaga_update_enemies(enemies);
        galaga_move_sprite(GALAGA_PLAYER_SLOT, x, y);
        galaga_wait(2000);
    }

    galaga_hide_all_sprites();

    setModeVideoOS(VDP_MODE_TEXT);
    clearScr();
}
