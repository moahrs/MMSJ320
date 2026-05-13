/* sheet.c - fonte consolidado */

#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include "mmsj320api.h"
#include "mmsj320vdp.h"
#include "mmsj320mfp.h"
#include "monitor.h"
#include "mmsjos.h"
#include "mgui.h"
#include "mguiapi.h"
#include "monitorapi.h"
#include "mmsjosapi.h"

#include "testes.h"

#include <stdio.h>

/* -------------------------------------------------- */
/* CALL HOOK GENERICO                                 */
/* -------------------------------------------------- */

void callHook(int hookNum, void *ctx)
{
    HOOK *h;

    if (hookNum < 0 || hookNum >= MAX_HOOKS)
        return;

    h = &hookTable[hookNum];

    if (h->magic != HOOK_MAGIC)
        return;

    if (!(h->flags & HOOKF_ACTIVE))
        return;

    if (h->addr == 0)
        return;

    h->addr(ctx);
}


/* -------------------------------------------------- */
/* HOOK CUSTOM DO TIMER                               */
/* -------------------------------------------------- */

void myTimerBefore(void *p)
{
    TIMER_CTX *ctx;

    ctx = (TIMER_CTX *)p;

    printf("\n[TIMER BEFORE] tick atual = %lu\n", ctx->tick);
}


void myTimerAfter(void *p)
{
    TIMER_CTX *ctx;

    ctx = (TIMER_CTX *)p;

    printf("[TIMER AFTER] tick depois da rotina normal = %lu\n", ctx->tick);

    /* desativa depois de executar uma vez */
    hookTable[HOOK_TIMER_AFTER].magic = 0;
}


/* -------------------------------------------------- */
/* HOOK CUSTOM DO TECLADO                             */
/* -------------------------------------------------- */

void myKeyboardBefore(void *p)
{
    KEY_CTX *ctx;

    ctx = (KEY_CTX *)p;

    printf("\n[KEY BEFORE] raw = %u ascii = %c\n", ctx->raw, ctx->ascii);

    /* exemplo: troca a tecla A por Z antes da rotina normal */
    if (ctx->ascii == 'A')
    {
        ctx->ascii = 'Z';
    }
}


void myKeyboardAfter(void *p)
{
    KEY_CTX *ctx;

    ctx = (KEY_CTX *)p;

    printf("[KEY AFTER] ascii final = %c\n", ctx->ascii);

    hookTable[HOOK_KEYBOARD_AFTER].magic = 0;
}


/* -------------------------------------------------- */
/* INSTALA HOOK                                       */
/* -------------------------------------------------- */

void installHook(int hookNum, void (*func)(void *))
{
    hookTable[hookNum].addr  = func;
    hookTable[hookNum].flags = HOOKF_ACTIVE;
    hookTable[hookNum].magic = HOOK_MAGIC;
}


/* -------------------------------------------------- */
/* ROTINAS NORMAIS DO SISTEMA                         */
/* -------------------------------------------------- */

void rotinaNormalTimer(TIMER_CTX *ctx)
{
    ctx->tick++;
    printf("Rotina normal TIMER executou. tick = %lu\n", ctx->tick);
}


void rotinaNormalKeyboard(KEY_CTX *ctx)
{
    printf("Rotina normal KEYBOARD recebeu ascii = %c\n", ctx->ascii);
}


/* -------------------------------------------------- */
/* SIMULACAO DAS INTERRUPCOES                         */
/* -------------------------------------------------- */

void IntTimer(void)
{
    TIMER_CTX ctx;

    ctx.consumed = 0;
    ctx.status = 0;
    ctx.tick = 100;

    callHook(HOOK_TIMER_BEFORE, &ctx);

    if (!ctx.consumed)
    {
        rotinaNormalTimer(&ctx);
    }

    callHook(HOOK_TIMER_AFTER, &ctx);
}


void IntKeyboard(void)
{
    KEY_CTX ctx;

    ctx.consumed = 0;
    ctx.status = 0;
    ctx.raw = 30;
    ctx.ascii = 'A';

    callHook(HOOK_KEYBOARD_BEFORE, &ctx);

    if (!ctx.consumed)
    {
        rotinaNormalKeyboard(&ctx);
    }

    callHook(HOOK_KEYBOARD_AFTER, &ctx);
}


/* -------------------------------------------------- */
/* MAIN                                               */
/* -------------------------------------------------- */

int main(void)
{
    int i;

    for (i = 0; i < MAX_HOOKS; i++)
    {
        hookTable[i].magic = 0;
        hookTable[i].flags = 0;
        hookTable[i].addr = 0;
    }

    printf("Instalando hooks...\n");

    installHook(HOOK_TIMER_BEFORE, myTimerBefore);
    installHook(HOOK_TIMER_AFTER, myTimerAfter);

    installHook(HOOK_KEYBOARD_BEFORE, myKeyboardBefore);
    installHook(HOOK_KEYBOARD_AFTER, myKeyboardAfter);

    printf("\n--- Simulando interrupcao TIMER ---\n");
    IntTimer();

    printf("\n--- Simulando interrupcao KEYBOARD ---\n");
    IntKeyboard();

    return 0;
}