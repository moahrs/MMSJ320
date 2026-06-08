#include <stddef.h>

void *memcpy(void *dest, const void *src, size_t n) {
    char *d = dest;
    const char *s = src;
    while (n--) *d++ = *s++;
    return dest;
}

void *memset(void *s, int c, size_t n) {
    unsigned char *p = s;
    while (n--) *p++ = (unsigned char)c;
    return s;
}

size_t strlen(const char *s) {
    size_t n = 0;
    while (s[n] != '\0') n++;
    return n;
}

char *strcpy(char *dest, const char *src) {
    char *d = dest;
    while ((*d++ = *src++) != '\0') {
    }
    return dest;
}

char *strcat(char *dest, const char *src) {
    char *d = dest;
    while (*d) d++;
    while ((*d++ = *src++) != '\0') {}
    return dest;
}

int strcmp(const char *s1, const char *s2) {
    while (*s1 != '\0' && *s1 == *s2) {
        s1++;
        s2++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
}

static char *to_base(unsigned long value, char *str, int base) {
    static const unsigned long dec_divs[] = {
        1000000000UL, 100000000UL, 10000000UL, 1000000UL, 100000UL,
        10000UL, 1000UL, 100UL, 10UL, 1UL
    };
    int i = 0;

    if (base != 10) {
        str[0] = '\0';
        return str;
    }

    if (value == 0) {
        str[0] = '0';
        str[1] = '\0';
        return str;
    }

    {
        int idx;
        int started = 0;
        for (idx = 0; idx < (int)(sizeof(dec_divs) / sizeof(dec_divs[0])); idx++) {
            unsigned long div = dec_divs[idx];
            unsigned char digit = 0;
            while (value >= div) {
                value -= div;
                digit++;
            }
            if (digit || started) {
                str[i++] = (char)('0' + digit);
                started = 1;
            }
        }
    }

    str[i] = '\0';
    return str;
}

char *ltoa(long value, char *str, int base) {
    if (base == 10 && value < 0) {
        str[0] = '-';
        to_base((unsigned long)(-value), str + 1, base);
        return str;
    }
    return to_base((unsigned long)value, str, base);
}

char *itoa(int value, char *str, int base) {
    return ltoa((long)value, str, base);
}

int toupper(int c) {
    if (c >= 'a' && c <= 'z') {
        return c - ('a' - 'A');
    }
    return c;
}

unsigned char _ctype_[256];
