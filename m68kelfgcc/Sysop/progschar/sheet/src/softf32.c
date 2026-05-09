#define MONITOR_FUNC_TABLE    0x0000041A
typedef void (*writeLongSerialType)(unsigned char *msg);
#define writeLongSerial ((writeLongSerialType *)(unsigned long)MONITOR_FUNC_TABLE)[27] // Índice da função

#include "softf32.h"

#define SF32_SIGN_MASK 0x80000000UL
#define SF32_EXP_MASK  0x7F800000UL
#define SF32_FRAC_MASK 0x007FFFFFUL
#define SF32_BIAS      127

#define SF32_POS_INF   0x7F800000UL
#define SF32_NEG_INF   0xFF800000UL
#define SF32_MAX_FIN   0x7F7FFFFFUL

//-------------------------------------------------------
// Somente para divisoes pequenas
//-------------------------------------------------------
int vc_div_f32(int n, int d)
{
    int q;
    int neg;

    q = 0;
    neg = 0;

    if (d == 0)
        return 0;

    if (n < 0) {
        n = -n;
        neg = !neg;
    }

    if (d < 0) {
        d = -d;
        neg = !neg;
    }

    while (n >= d) {
        n -= d;
        q++;
    }

    if (neg)
        q = -q;

    return q;
}

static int sf32_is_zero(softf32_t a)
{
    return ((a & 0x7FFFFFFFUL) == 0);
}

static softf32_t sf32_abs(softf32_t a)
{
    return (a & 0x7FFFFFFFUL);
}

static softf32_t sf32_neg(softf32_t a)
{
    return (a ^ SF32_SIGN_MASK);
}

static char *sf32_u32_to_dec(char *dst, unsigned long v)
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
        unsigned long q = vc_div_f32(v, 10UL);
        unsigned long r = v - (q * 10UL);
        tmp[i++] = (char)('0' + r);
        v = q;
    }

    while (i > 0)
        *dst++ = tmp[--i];

    *dst = 0;
    return dst;
}

static inline void sf32_unpack(softf32_t a, int *sign, int *exp_unb, unsigned long *mant24)
{
    unsigned long expf;
    unsigned long frac;

    *sign = (a & SF32_SIGN_MASK) ? 1 : 0;
    expf = (a & SF32_EXP_MASK) >> 23;
    frac = (a & SF32_FRAC_MASK);

    if (expf == 0 || expf == 255UL) {
        *exp_unb = -127;
        *mant24 = 0;
        return;
    }

    *exp_unb = (int)expf - SF32_BIAS;
    *mant24 = (1UL << 23) | frac;

}

static inline softf32_t sf32_pack(int sign, int exp_unb, unsigned long mant24)
{
    unsigned long expf;
    unsigned long frac;

    if (mant24 == 0)
        return 0;

    while (mant24 >= (1UL << 24)) {
        mant24 >>= 1;
        exp_unb++;
    }

    while (mant24 < (1UL << 23)) {
        mant24 <<= 1;
        exp_unb--;
    }

    expf = (unsigned long)(exp_unb + SF32_BIAS);

    if (expf >= 255UL)
        return sign ? (SF32_SIGN_MASK | SF32_MAX_FIN) : SF32_MAX_FIN;

    if ((long)expf <= 0)
        return 0;

    frac = (mant24 & SF32_FRAC_MASK);

    return (softf32_t)((sign ? SF32_SIGN_MASK : 0UL) | (expf << 23) | frac);
}

softf32_t softf32_from_bits(unsigned long bits)
{
    return (softf32_t)bits;
}

unsigned long softf32_to_bits(softf32_t v)
{
    return (unsigned long)v;
}

softf32_t softf32_from_str(const char *s)
{
    int neg;
    int got_digit;
    int exp10;
    int exp_neg;
    softf32_t v;
    softf32_t ten;
    softf32_t frac_step;

    if (!s)
        return 0;

    while (*s == ' ' || *s == '\t' || *s == '\r' || *s == '\n')
        s++;

    neg = 0;
    if (*s == '+') {
        s++;
    } else if (*s == '-') {
        neg = 1;
        s++;
    }

    v = 0;
    ten = softf32_from_int(10);
    got_digit = 0;

    while (*s >= '0' && *s <= '9') {
        int d;

        d = *s - '0';
        v = softf32_mul(v, ten);
        v = softf32_add(v, softf32_from_int(d));
        s++;
        got_digit = 1;
    }

    if (*s == '.') {
        s++;

        frac_step = softf32_div(softf32_from_int(1), ten);

        while (*s >= '0' && *s <= '9') {
            int d;
            softf32_t term;

            d = *s - '0';

            term = softf32_mul(softf32_from_int(d), frac_step);
            v = softf32_add(v, term);
            frac_step = softf32_div(frac_step, ten);
            s++;
            got_digit = 1;
        }
    }

    if (!got_digit)
        return 0;

    exp10 = 0;
    exp_neg = 0;
    if (*s == 'e' || *s == 'E') {
        s++;
        if (*s == '+') {
            s++;
        } else if (*s == '-') {
            exp_neg = 1;
            s++;
        }

        while (*s >= '0' && *s <= '9') {
            exp10 = (exp10 * 10) + (*s - '0');
            s++;
            if (exp10 > 200)
                exp10 = 200;
        }
    }

    while (exp10 > 0) {
        if (exp_neg)
            v = softf32_div(v, ten);
        else
            v = softf32_mul(v, ten);
        exp10--;
    }

    if (neg)
        v = sf32_neg(v);

    return v;
}

softf32_t softf32_from_int(long v)
{
    unsigned long mag;
    int sign;
    int exp;
    unsigned long mant;

    if (v == 0)
        return 0;

    sign = (v < 0) ? 1 : 0;
    mag = (unsigned long)(sign ? -v : v);

    exp = 0;
    mant = mag;

    while (mant >= (1UL << 24)) {
        mant >>= 1;
        exp++;
    }

    while (mant < (1UL << 23)) {
        mant <<= 1;
        exp--;
    }

    return sf32_pack(sign, exp, mant);
}

long softf32_to_int(softf32_t a)
{
    int sign;
    int exp;
    unsigned long mant;
    unsigned long v;

    sf32_unpack(a, &sign, &exp, &mant);

    if (mant == 0)
        return 0;

    if (exp < 0)
        return 0;

    if (exp >= 31)
        return sign ? (long)0x80000000L : (long)0x7FFFFFFFL;

    if (exp >= 23)
        v = mant << (exp - 23);
    else
        v = mant >> (23 - exp);

    if (sign)
        return -(long)v;

    return (long)v;
}

softf32_t softf32_add(softf32_t a, softf32_t b)
{
    int sa;
    int sb;
    int ea;
    int eb;
    unsigned long ma;
    unsigned long mb;
    int e;
    unsigned long m;
    int s;

    if (sf32_is_zero(a))
        return b;

    if (sf32_is_zero(b))
        return a;

    sf32_unpack(a, &sa, &ea, &ma);
    sf32_unpack(b, &sb, &eb, &mb);

    if (ma == 0)
        return b;

    if (mb == 0)
        return a;

    if (ea > eb) {
        int d = ea - eb;
        if (d >= 31)
            mb = 0;
        else
            mb >>= d;
        e = ea;
    } else if (eb > ea) {
        int d = eb - ea;
        if (d >= 31)
            ma = 0;
        else
            ma >>= d;
        e = eb;
    } else {
        e = ea;
    }

    if (sa == sb) {
        m = ma + mb;
        s = sa;
    } else {
        if (ma >= mb) {
            m = ma - mb;
            s = sa;
        } else {
            m = mb - ma;
            s = sb;
        }
    }

    return sf32_pack(s, e, m);
}

softf32_t softf32_sub(softf32_t a, softf32_t b)
{
    return softf32_add(a, sf32_neg(b));
}

softf32_t softf32_mul(softf32_t a, softf32_t b)
{
    int sa;
    int sb;
    int ea;
    int eb;
    unsigned long ma;
    unsigned long mb;
    unsigned long long p;
    int s;
    int e;
    unsigned long m;

    if (sf32_is_zero(a) || sf32_is_zero(b))
        return 0;

    sf32_unpack(a, &sa, &ea, &ma);
    sf32_unpack(b, &sb, &eb, &mb);

    if (ma == 0 || mb == 0)
        return 0;

    s = sa ^ sb;
    e = ea + eb;

    p = (unsigned long long)ma * (unsigned long long)mb;
    m = (unsigned long)(p >> 23);

    return sf32_pack(s, e, m);
}

softf32_t softf32_div(softf32_t a, softf32_t b)
{
    int sa;
    int sb;
    int ea;
    int eb;
    unsigned long ma;
    unsigned long mb;
    unsigned long long n;
    unsigned long m;
    int s;
    int e;

    if (sf32_is_zero(b))
        return (a & SF32_SIGN_MASK) ? SF32_NEG_INF : SF32_POS_INF;

    if (sf32_is_zero(a))
        return 0;

    sf32_unpack(a, &sa, &ea, &ma);
    sf32_unpack(b, &sb, &eb, &mb);

    if (ma == 0)
        return 0;

    if (mb == 0)
        return (sa ^ sb) ? SF32_NEG_INF : SF32_POS_INF;

    s = sa ^ sb;
    e = ea - eb;

    n = ((unsigned long long)ma << 23);
    m = (unsigned long)vc_div_f32(n, (unsigned long long)mb);

    return sf32_pack(s, e, m);
}

void softf32_to_str(softf32_t v, char *out, int decimals)
{
    softf32_t av;
    long int_part;
    softf32_t frac;
    char *p;
    int i;
writeLongSerial("Aqui 0\r\n\0");

    if (decimals < 0)
        decimals = 0;

    if (decimals > 6)
        decimals = 6;

    p = out;

writeLongSerial("Aqui 1\r\n\0");
    if (v & SF32_SIGN_MASK) {
        *p++ = '-';
        av = sf32_abs(v);
    } else {
        av = v;
    }

writeLongSerial("Aqui 2\r\n\0");
    int_part = softf32_to_int(av);
writeLongSerial("Aqui 3\r\n\0");
    p = sf32_u32_to_dec(p, (unsigned long)((int_part < 0) ? -int_part : int_part));
writeLongSerial("Aqui 4\r\n\0");

    if (decimals == 0) {
        *p = 0;
        return;
    }

    *p++ = '.';

writeLongSerial("Aqui 5\r\n\0");
    frac = softf32_sub(av, softf32_from_int(int_part));
writeLongSerial("Aqui 6\r\n\0");

    for (i = 0; i < decimals; i++) {
        int d;
        int sign_f;
        int exp_f;
        unsigned long mant_f;
        softf32_t ten;

writeLongSerial("Aqui 7\r\n\0");
        ten = softf32_from_int(10);
        frac = softf32_mul(frac, ten);
writeLongSerial("Aqui 8\r\n\0");
        d = (int)softf32_to_int(frac);
writeLongSerial("Aqui 9\r\n\0");

        if (d < 0)
            d = 0;
        else if (d > 9)
            d = 9;

        *p++ = (char)('0' + d);
writeLongSerial("Aqui 10\r\n\0");
        
        /* Extrair resto: frac = (frac_old * 10) - d sem chamar softf32_sub */
        sf32_unpack(frac, &sign_f, &exp_f, &mant_f);
        
        if (d > 0) {
            if (exp_f >= 0 && exp_f < 24) {
                unsigned long d_mant = (unsigned long)d << exp_f;
                if (mant_f >= d_mant)
                    mant_f -= d_mant;
            } else if (exp_f < 0 && (-exp_f) < 24) {
                unsigned long d_mant = (unsigned long)d >> (-exp_f);
                if (mant_f >= d_mant)
                    mant_f -= d_mant;
            }
        }
        
        /* Reempacotar (sf32_pack é inline, não aloca stack) */
        frac = sf32_pack(sign_f, exp_f, mant_f);
writeLongSerial("Aqui 11\r\n\0");
    }

    *p = 0;
}
