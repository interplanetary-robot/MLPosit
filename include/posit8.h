#ifndef POSIT_8_0_H
#define POSIT_8_0_H

#include <stdint.h>

typedef union {uint8_t udata; int8_t sdata;} posit8_t ;

#ifdef __cplusplus

  class Posit8{
    public:
      uint8_t data;

      //various public constructors
      Posit8();               //defaults to zero
      Posit8(const float);    //conversion constructor from IEEE32
      Posit8(const double);   //conversion constructor from IEEE64
      Posit8(const Posit8 &); //copy constructor
      Posit8(const posit8_t); //bridge constructor from c functionality.

      //public operators
      Posit8 operator -() const;
      Posit8 operator +(const Posit8 rhs) const;
      Posit8 operator -(const Posit8 rhs) const;
      Posit8 operator *(const Posit8 rhs) const;
      Posit8 &operator +=(const Posit8 rhs);
      Posit8 &operator -=(const Posit8 rhs);
      Posit8 &operator *=(const Posit8 rhs);
      bool operator <(const Posit8 rhs) const;
      bool operator <=(const Posit8 rhs) const;
      bool operator >(const Posit8 rhs) const;
      bool operator >=(const Posit8 rhs) const;
      bool operator ==(const Posit8 rhs) const;
      Posit8 operator /(const Posit8 rhs) const;
      Posit8 &operator /=(const Posit8 rhs);

      operator float() const;
      operator double() const;
      operator posit8_t() const;
  };

#endif

#define P8NAN      ((uint8_t) 0x80)
#define P8MAXREAL  ((uint8_t) 0x7f)
#define P8MINREAL  ((uint8_t) 0x81)
#define P8POSSMALL ((uint8_t) 0x01)
#define P8NEGSMALL ((uint8_t) 0xff)
#define P8ZER      ((uint8_t) 0x00)

extern "C" float p8_to_f(const posit8_t);
extern "C" posit8_t f_to_p8(const float);

extern "C" posit8_t posit8_add(const posit8_t, const posit8_t);
extern "C" posit8_t posit8_mul(const posit8_t, const posit8_t);
extern "C" posit8_t posit8_div(const posit8_t, const posit8_t);
extern "C" posit8_t posit8_sub(const posit8_t, const posit8_t);
extern "C" posit8_t posit8_addinv(const posit8_t);
extern "C" posit8_t posit8_mulinv(const posit8_t);

extern "C" bool posit8_lt(const posit8_t, const posit8_t);
extern "C" bool posit8_lte(const posit8_t, const posit8_t);
extern "C" bool posit8_gt(const posit8_t, const posit8_t);
extern "C" bool posit8_gte(const posit8_t, const posit8_t);
extern "C" bool posit8_eq(const posit8_t, const posit8_t);

#endif
