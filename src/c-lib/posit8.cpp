#include "posit8.h"

#include <math.h>

const float __posit_lookuptable64[] = {
  0.0,    0.015625,  0.03125,  0.046875,  0.0625,  0.078125,  0.09375,  0.109375,
  0.125,  0.140625,  0.15625,  0.171875,  0.1875,  0.203125,  0.21875,  0.234375,
  0.25,   0.265625,  0.28125,  0.296875,  0.3125,  0.328125,  0.34375,  0.359375,
  0.375,  0.390625,  0.40625,  0.421875,  0.4375,  0.453125,  0.46875,  0.484375,
  0.5,    0.515625,  0.53125,  0.546875,  0.5625,  0.578125,  0.59375,  0.609375,
  0.625,  0.640625,  0.65625,  0.671875,  0.6875,  0.703125,  0.71875,  0.734375,
  0.75,   0.765625,  0.78125,  0.796875,  0.8125,  0.828125,  0.84375,  0.859375,
  0.875,  0.890625,  0.90625,  0.921875,  0.9375,  0.953125,  0.96875,  0.984375,
  1.0,    1.03125,   1.0625,   1.09375,   1.125,   1.15625,   1.1875,   1.21875,
  1.25,   1.28125,   1.3125,   1.34375,   1.375,   1.40625,   1.4375,   1.46875,
  1.5,    1.53125,   1.5625,   1.59375,   1.625,   1.65625,   1.6875,   1.71875,
  1.75,   1.78125,   1.8125,   1.84375,   1.875,   1.90625,   1.9375,   1.96875,
  2.0,    2.125,     2.25,     2.375,     2.5,     2.625,     2.75,     2.875,
  3.0,    3.125,     3.25,     3.375,     3.5,     3.625,     3.75,     3.875,
  4.0,    4.5,       5.0,      5.5,       6.0,     6.5,       7.0,      7.5,
  8.0,    10.0,      12.0,     14.0,      16.0,    24.0,      32.0,     64.0,
  NAN,    -64.0,     -32.0,    -24.0,     -16.0,   -14.0,     -12.0,    -10.0,
  -8.0,   -7.5,      -7.0,     -6.5,      -6.0,    -5.5,      -5.0,     -4.5,
  -4.0,   -3.875,    -3.75,    -3.625,    -3.5,    -3.375,    -3.25,    -3.125,
  -3.0,   -2.875,    -2.75,    -2.625,    -2.5,    -2.375,    -2.25,    -2.125,
  -2.0,   -1.96875,  -1.9375,  -1.90625,  -1.875,  -1.84375,  -1.8125,  -1.78125,
  -1.75,  -1.71875,  -1.6875,  -1.65625,  -1.625,  -1.59375,  -1.5625,  -1.53125,
  -1.5,   -1.46875,  -1.4375,  -1.40625,  -1.375,  -1.34375,  -1.3125,  -1.28125,
  -1.25,  -1.21875,  -1.1875,  -1.15625,  -1.125,  -1.09375,  -1.0625,  -1.03125,
  -1.0,   -0.984375, -0.96875, -0.953125, -0.9375, -0.921875, -0.90625, -0.890625,
  -0.875, -0.859375, -0.84375, -0.828125, -0.8125, -0.796875, -0.78125, -0.765625,
  -0.75,  -0.734375, -0.71875, -0.703125, -0.6875, -0.671875, -0.65625, -0.640625,
  -0.625, -0.609375, -0.59375, -0.578125, -0.5625, -0.546875, -0.53125, -0.515625,
  -0.5,   -0.484375, -0.46875, -0.453125, -0.4375, -0.421875, -0.40625, -0.390625,
  -0.375, -0.359375, -0.34375, -0.328125, -0.3125, -0.296875, -0.28125, -0.265625,
  -0.25,  -0.234375, -0.21875, -0.203125, -0.1875, -0.171875, -0.15625, -0.140625,
  -0.125, -0.109375, -0.09375, -0.078125, -0.0625, -0.046875, -0.03125, -0.015625};

extern "C" posit8_t f_to_p8(const float a){
  //create a result value
  posit8_t res;

  //infinity and NaN checks:
  if (isinf(a))  {res.udata = P8NAN; return res; };
  if (a == 0.0f) {res.udata = P8ZER; return res; };
  if (isnan(a))  {res.udata = P8NAN; return res; }

  //do a surreptitious conversion from float precision to UInt8
  uint32_t *ival = (uint32_t *) &a;
  bool signbit = ((0x80000000L & (*ival)) != 0);
  //capture the exponent value
  int16_t exponent = (((0x7f800000L & (*ival)) >> 23) - 127);

  //pin the exponent.
  exponent = (exponent > 6) ? 6 : exponent;
  //underflow behavior is defined by the POSIT_ENV.underflows setting.
  exponent = (exponent >= -7) ? exponent : -7;

  //use an uint32_t value as an intermediary store for
  //raw fraction bits.  Shift all the way to the right and then

  int16_t regime = exponent;
  uint32_t frac = (*ival) << (7);
  //there are no exponent bits.
  frac &= 0x3fffffffL;

  //next, append the appropriate shift prefix in front of the value.
  int16_t shift;

  if (regime >= 0) {
    shift = 1 + regime;
    frac |= 0x80000000L;
  } else {
    shift = -regime;
    frac |= 0x40000000L;
  }

  //perform an *arithmetic* shift; convert back to unsigned.
  frac = (uint32_t)(((int32_t) frac) >> shift);

  //mask out the top bit of the fraction, which is going to be the
  //basis for the result.
  frac = frac & 0x7fffffffL;

  bool guard = (frac & 0x00800000L) != 0;
  bool summ  = (frac & 0x007fffffL ) != 0;
  bool inner = (frac & 0x01000000L) != 0;

  //round the frac variable in the event it needs be augmented.

  frac += ((guard && inner) || (guard && summ)) ? 0x01000000L : 0x00000000L;
  //shift as necessary

  //shift further, as necessary, to match sizes
  frac = frac >> 24;

  uint8_t sfrac = (uint8_t) frac;

  res.udata = (signbit ? -sfrac : sfrac);
  return res;
}

extern "C" float p8_to_f(const posit8_t a){
  return (float)__posit_lookuptable64[a.udata];
}

extern "C" posit8_t posit8_add(const posit8_t a, const posit8_t b) {
  return f_to_p8(p8_to_f(a) + p8_to_f(b));
}

extern "C" posit8_t posit8_mul(const posit8_t a, const posit8_t b) {
  return f_to_p8(p8_to_f(a) * p8_to_f(b));
}

extern "C" posit8_t posit8_div(const posit8_t a, const posit8_t b) {
  return f_to_p8(p8_to_f(a) / p8_to_f(b));
}

extern "C" posit8_t posit8_sub(const posit8_t a, const posit8_t b) {
  return f_to_p8(p8_to_f(a) - p8_to_f(b));
}

extern "C" posit8_t posit8_addinv(const posit8_t a) {
  posit8_t res;
  res.udata = -(a.udata);
  return res;
}

extern "C" posit8_t posit8_mulinv(const posit8_t a) {
  return f_to_p8(1.0f/(p8_to_f(a)));
}

extern "C" bool posit8_lt(const posit8_t a,const  posit8_t b) {
  if ((a.udata == P8NAN) || (b.udata == P8NAN)) { return false; }
  return (a.sdata < b.sdata);
}

extern "C" bool posit8_lte(const posit8_t a,const  posit8_t b) {
  if ((a.udata == P8NAN) || (b.udata == P8NAN)) { return false; }
  return (a.sdata <= b.sdata);
}

extern "C" bool posit8_gt(const posit8_t a,const  posit8_t b) {
  if ((a.udata == P8NAN) || (b.udata == P8NAN)) { return false; }
  return (a.sdata > b.sdata);
}

extern "C" bool posit8_gte(const posit8_t a,const  posit8_t b) {
  if ((a.udata == P8NAN) || (b.udata == P8NAN)) { return false; }
  return (a.sdata >= b.sdata);
}

extern "C" bool posit8_eq(const posit8_t a,const  posit8_t b) {
  if ((a.udata == P8NAN) || (b.udata == P8NAN)) { return false; }
  return (a.sdata == b.sdata);
}
