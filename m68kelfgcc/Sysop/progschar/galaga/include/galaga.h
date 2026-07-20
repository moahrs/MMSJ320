#ifndef GALAGA_H
#define GALAGA_H

#define GALAGA_SPR_PAT  0x1800
#define GALAGA_SPR_ATTR 0x3B00

#define GALAGA_SPRITE_COUNT 32
#define GALAGA_SCREEN_W 256
#define GALAGA_SCREEN_H 192
#define GALAGA_MAX_SHOTS 4

typedef struct
{
    unsigned char x;
    unsigned char y;
    unsigned char pattern;
    unsigned char color;
    unsigned char active;
} GalagaSprite;

void galaga_init_video(void);
void galaga_hide_all_sprites(void);
void galaga_set_sprite_pattern(unsigned char pattern, const unsigned char *data);
void galaga_put_sprite(unsigned char slot, unsigned char pattern, unsigned char x, unsigned char y, unsigned char color);
void galaga_create_sprite(unsigned char slot, unsigned char pattern, const unsigned char *data, unsigned char x, unsigned char y, unsigned char color);
void galaga_move_sprite(unsigned char slot, unsigned char x, unsigned char y);
void galaga_hide_sprite(unsigned char slot);

#endif
