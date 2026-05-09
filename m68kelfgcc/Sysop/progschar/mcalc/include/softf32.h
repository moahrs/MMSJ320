#ifndef SOFTF32_H
#define SOFTF32_H

/*
 * SoftF32: software float32-like format (IEEE-754 single layout)
 * - 1 bit sign
 * - 8 bits exponent (bias 127)
 * - 23 bits fraction
 *
 * This module uses integer-only math internally.
 */

typedef unsigned long softf32_t;

/* Raw helpers */
softf32_t softf32_from_bits(unsigned long bits);
unsigned long softf32_to_bits(softf32_t v);

/* Conversions */
softf32_t softf32_from_int(long v);
long softf32_to_int(softf32_t v);
softf32_t softf32_from_str(const char *s);

/* Basic arithmetic */
softf32_t softf32_add(softf32_t a, softf32_t b);
softf32_t softf32_sub(softf32_t a, softf32_t b);
softf32_t softf32_mul(softf32_t a, softf32_t b);
softf32_t softf32_div(softf32_t a, softf32_t b);

/* Formatting */
void softf32_to_str(softf32_t v, char *out, int decimals);

#endif
