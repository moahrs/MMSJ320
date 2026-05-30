#ifndef TESTES_H
#define TESTES_H

/* -------------------------------------------------- */
/* HOOKS                                              */
/* -------------------------------------------------- */

#define HOOK_MAGIC      0x4D4A

#define HOOKF_ACTIVE    0x0001

#define HOOK_TIMER_BEFORE      0
#define HOOK_TIMER_AFTER       1
#define HOOK_KEYBOARD_BEFORE   2
#define HOOK_KEYBOARD_AFTER    3

#define MAX_HOOKS              4

/* -------------------------------------------------- */
/* CONTEXTOS                                          */
/* -------------------------------------------------- */

typedef struct
{
    unsigned short consumed;
    unsigned short status;
    unsigned long  tick;

} TIMER_CTX;


typedef struct
{
    unsigned short consumed;
    unsigned short status;
    unsigned short raw;
    unsigned short ascii;

} KEY_CTX;

extern void tstIntsOff(void);
extern void tstIntsOn(void);

#endif

