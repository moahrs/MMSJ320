#include "softfp.h"

#define SOFTFP_MAX  ((softfp_t)0x7FFFFFFFL)
#define SOFTFP_MIN  ((softfp_t)0x80000000L)

static softfp_t softfp_sat_from_i64(long long v)
{
    if (v > (long long)SOFTFP_MAX)
        return SOFTFP_MAX;

    if (v < (long long)SOFTFP_MIN)
        return SOFTFP_MIN;

    return (softfp_t)v;
}

static unsigned long softfp_abs_u32(long v)
{
    if (v < 0)
        return (unsigned long)(-v);
    return (unsigned long)v;
}

static char *softfp_u32_to_dec(char *dst, unsigned long v)
{
    char tmp[12];
    int i;

    i = 0;

    if (v == 0) {
        *dst++ = '0';
        *dst = 0;
        return dst;
    }

    while (v > 0 && i < (int)sizeof(tmp)) {
        unsigned long q = v / 10UL;
        unsigned long r = v - (q * 10UL);
        tmp[i++] = (char)('0' + r);
        v = q;
    }

    while (i > 0)
        *dst++ = tmp[--i];

    *dst = 0;
    return dst;
}

softfp_t softfp_from_int(long v)
{
    long long n;

    n = ((long long)v) * (long long)SOFTFP_SCALE;
    return softfp_sat_from_i64(n);
}

softfp_t softfp_from_str(const char *s)
{
    int neg;
    int saw_digit;
    long long int_part;
    long long frac_part;
    int frac_digits;
    long long raw;

    if (!s)
        return SOFTFP_ZERO;

    while (*s == ' ' || *s == '\t' || *s == '\r' || *s == '\n')
        s++;

    neg = 0;
    if (*s == '+') {
        s++;
    } else if (*s == '-') {
        neg = 1;
        s++;
    }

    int_part = 0;
    saw_digit = 0;

    while (*s >= '0' && *s <= '9') {
        int digit;

        digit = *s - '0';
        int_part = (int_part * 10LL) + (long long)digit;
        if (int_part > 3000000000LL)
            int_part = 3000000000LL;
        s++;
        saw_digit = 1;
    }

    frac_part = 0;
    frac_digits = 0;

    if (*s == '.') {
        s++;
        while (*s >= '0' && *s <= '9') {
            int digit;

            digit = *s - '0';
            if (frac_digits < 3) {
                frac_part = (frac_part * 10LL) + (long long)digit;
                frac_digits++;
            }
            s++;
            saw_digit = 1;
        }
    }

    if (!saw_digit)
        return SOFTFP_ZERO;

    while (frac_digits < 3) {
        frac_part *= 10LL;
        frac_digits++;
    }

    raw = (int_part * (long long)SOFTFP_SCALE) + frac_part;
    if (neg)
        raw = -raw;

    return softfp_sat_from_i64(raw);
}

long softfp_to_int(softfp_t v)
{
    return (long)(v / (softfp_t)SOFTFP_SCALE);
}

softfp_t softfp_add(softfp_t a, softfp_t b)
{
    long long s;

    s = (long long)a + (long long)b;
    return softfp_sat_from_i64(s);
}

softfp_t softfp_sub(softfp_t a, softfp_t b)
{
    long long d;

    d = (long long)a - (long long)b;
    return softfp_sat_from_i64(d);
}

softfp_t softfp_mul(softfp_t a, softfp_t b)
{
    long long p;

    p = ((long long)a * (long long)b);
    p = p / (long long)SOFTFP_SCALE;

    return softfp_sat_from_i64(p);
}

softfp_t softfp_div(softfp_t a, softfp_t b)
{
    long long n;
    long long q;

    if (b == 0)
        return (a >= 0) ? SOFTFP_MAX : SOFTFP_MIN;

    n = ((long long)a * (long long)SOFTFP_SCALE);
    q = n / (long long)b;

    return softfp_sat_from_i64(q);
}

void softfp_to_str(softfp_t v, char *out, int decimals)
{
    unsigned long abs_v;
    unsigned long int_part;
    unsigned long frac_part;
    char *p;
    int i;
    
    if (decimals < 0)
        decimals = 0;

    if (decimals > 3)
        decimals = 3;

    p = out;

    if (v < 0) {
        *p++ = '-';
        abs_v = softfp_abs_u32(-v);
    } else {
        abs_v = softfp_abs_u32(v);
    }

    int_part = (abs_v / (unsigned long)SOFTFP_SCALE);
    frac_part = (abs_v % (unsigned long)SOFTFP_SCALE);

    p = softfp_u32_to_dec(p, int_part);

    if (decimals == 0) {
        *p = 0;
        return;
    }

    *p++ = '.';

    if (decimals >= 1)
        *p++ = (char)('0' + (frac_part / 100UL));

    if (decimals >= 2)
        *p++ = (char)('0' + ((frac_part / 10UL) % 10UL));

    if (decimals >= 3)
        *p++ = (char)('0' + (frac_part % 10UL));

    *p = 0;
}
