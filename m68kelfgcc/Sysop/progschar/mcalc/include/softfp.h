#ifndef SOFTFP_H
#define SOFTFP_H

/*
 * SoftFP decimal fixed-point (signed 32-bit), scale 1000.
 *
 * Value representation:
 *   real = raw / 1000
 *
 * Examples:
 *   12345  -> 12.345
 *   -2000  -> -2.000
 */

typedef long softfp_t;

#define SOFTFP_SCALE    1000L
#define SOFTFP_ONE      ((softfp_t)SOFTFP_SCALE)
#define SOFTFP_ZERO     ((softfp_t)0)

/* Basic conversions */
softfp_t softfp_from_int(long v);
softfp_t softfp_from_str(const char *s);
long softfp_to_int(softfp_t v);

/* Basic arithmetic */
softfp_t softfp_add(softfp_t a, softfp_t b);
softfp_t softfp_sub(softfp_t a, softfp_t b);
softfp_t softfp_mul(softfp_t a, softfp_t b);
softfp_t softfp_div(softfp_t a, softfp_t b);

/* Formatting */
void softfp_to_str(softfp_t v, char *out, int decimals);

#endif
