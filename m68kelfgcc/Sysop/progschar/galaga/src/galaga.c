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

#define GALAGA_PLAYER_PATTERN 0
#define GALAGA_SHOT_PATTERN 1

#define GALAGA_PLAYER_STEP 4
#define GALAGA_SHOT_STEP 4
#define GALAGA_SHOT_X_OFFSET 0
#define GALAGA_SHOT_Y_OFFSET 18

static unsigned char *vdpData = (unsigned char *)0x00400041;
static GalagaSprite sprites[GALAGA_SPRITE_COUNT];

typedef struct
{
    unsigned char x;
    unsigned char y;
    unsigned char active;
} GalagaShot;

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
    galaga_hide_all_sprites();
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

void main(void)
{
    unsigned char key;
    unsigned char x;
    unsigned char y;
    GalagaShot shots[GALAGA_MAX_SHOTS];

    x = 120;
    y = 170;

    galaga_init_video();
    galaga_init_shots(shots);
    galaga_create_sprite(GALAGA_PLAYER_SLOT, GALAGA_PLAYER_PATTERN, playerShip_000, x, y, VDP_WHITE);

    vdp_set_cursor(0, 0);
    printText("GALAGA DEV - ESC sai");

    while (1)
    {
        key = readChar();

        if (key == KEY_ESC)
            break;

        if (key == 'A' || key == 'a')
        {
            if (x > 3)
                x -= GALAGA_PLAYER_STEP;
        }
        else if (key == 'D' || key == 'd')
        {
            if (x < 240)
                x += GALAGA_PLAYER_STEP;
        }
        else if (key == ' ')
        {
            galaga_fire_shot(shots, x, y);
        }

        galaga_update_shots(shots);
        galaga_move_sprite(GALAGA_PLAYER_SLOT, x, y);
        galaga_wait(2000);
    }

    galaga_hide_all_sprites();

    setModeVideoOS(VDP_MODE_TEXT);
    clearScr();
}
