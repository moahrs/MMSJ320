/*
*********************************************************************************************************
*                                               uC/OS-II
*                                        The Real-Time Kernel
*
*                            (c) Copyright 2000, Jean J. Labrosse, Weston, FL
*                                          All Rights Reserved
*
*                                          M68000 Specific code
*                                              IDE68K v 2.2
*
* File         : OS_CPU.H
* By           : Jean J. Labrosse, Peter J. Fondse
*********************************************************************************************************
*/

/*
*********************************************************************************************************
*                                           REVISION HISTORY
*
* $Log$
*
*********************************************************************************************************
*/

/*$PAGE*/
/*
*********************************************************************************************************
*                                              DATA TYPES
*********************************************************************************************************
*/

typedef unsigned char  BOOLEAN;
typedef unsigned char  INT8U;                    /* Unsigned  8 bit quantity                           */
typedef signed   char  INT8S;                    /* Signed    8 bit quantity                           */
typedef unsigned short INT16U;                   /* Unsigned 16 bit quantity                           */
typedef signed   short INT16S;                   /* Signed   16 bit quantity                           */
typedef unsigned int   INT32U;                   /* Unsigned 32 bit quantity                           */
typedef signed   int   INT32S;                   /* Signed   32 bit quantity                           */
typedef float          FP32;                     /* Single precision floating point                    */
typedef double         FP64;                     /* Double precision floating point                    */

#define BYTE           INT8S                     /* Define data types for backward compatibility ...   */
#define UBYTE          INT8U                     /* ... to uC/OS V1.xx                                 */
#define WORD           INT16S
#define UWORD          INT16U
#define LONG           INT32S
#define ULONG          INT32U

typedef unsigned short OS_STK;                   /* Each stack entry is 16-bit wide                    */

/*
*********************************************************************************************************
*                                           Motorola 68000
*
* Method #1:  Disable/Enable interrupts using simple instructions.  After critical section, interrupts
*             will be enabled even if they were disabled before entering the critical section.
*
* Method #2:  Disable/Enable interrupts by preserving the state of interrupts.  In other words, if
*             interrupts were disabled before entering the critical section, they will be disabled when
*             leaving the critical section.
*********************************************************************************************************
*/
/* Method #3: Save/restore SR to a local C variable (cpu_sr).
 * This is the correct method for GCC because the compiler does not know
 * that method #2's inline asm changes SP, causing SP-relative local
 * variable accesses to be off by 2 bytes inside critical sections.
 * os_core.c already declares 'OS_CPU_SR cpu_sr = 0u;' in every function
 * that uses these macros, so method #3 works without any source changes.  */
typedef  unsigned short  OS_CPU_SR;

#define  OS_CRITICAL_METHOD    3

#if      OS_CRITICAL_METHOD == 1
#define  OS_ENTER_CRITICAL()  __asm__ volatile ("ori.w #0x0700,%%sr" ::: "memory")
#define  OS_EXIT_CRITICAL()   __asm__ volatile ("andi.w #0xF8FF,%%sr" ::: "memory")
#endif

#if      OS_CRITICAL_METHOD == 2
#define  OS_ENTER_CRITICAL()  __asm__ volatile ("move.w %%sr,-(%%sp)\n\tori.w #0x0700,%%sr" ::: "memory")
#define  OS_EXIT_CRITICAL()   __asm__ volatile ("move.w (%%sp)+,%%sr" ::: "memory")
#endif

#if      OS_CRITICAL_METHOD == 3
#define  OS_ENTER_CRITICAL()  __asm__ volatile ("move.w %%sr,%0\n\tori.w #0x0700,%%sr" : "=d"(cpu_sr) :: "memory")
#define  OS_EXIT_CRITICAL()   __asm__ volatile ("move.w %0,%%sr" :: "d"(cpu_sr) : "memory")
#endif

#define  CPU_INT_DIS()        __asm__ volatile ("ori.w #0x0700,%%sr" ::: "memory")
#define  CPU_INT_EN()         __asm__ volatile ("andi.w #0xF8FF,%%sr" ::: "memory")

#define  OS_TASK_SW()         __asm__ volatile ("trap #0" ::: "memory")

#define  OS_STK_GROWTH        1                                           /* Define stack growth: 1 = Down, 0 = Up       */

#define  OS_INITIAL_SR        0x2000                                      /* Supervisor mode, all interrupts enabled     */

#define  OS_TRAP_NBR          0                                           /* OSCtxSw() invoked through TRAP #0            */

void OSVectSet(INT8U vect, void (*addr)(void));
void *OSVectGet(INT8U vect);
void OSIntExit68K(void);
void OSStartHighRdy(void);
void OSIntCtxSw(void);
void OSCtxSw(void);
void OSFPRestore(void *);
void OSFPSave(void *);
void OSTickISR(void);