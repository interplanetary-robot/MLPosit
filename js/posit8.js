class Posit8 {
  constructor(value = null){
    if (value instanceof Posit8) {
      this.data = value.data;
    } else if (typeof(value) === "number") {
      this.data = f_to_p8int(value);
    } else {
      //give a shortcut to creating zero.
      this.data = 0;
    }
  }

  toString() {
    return "Posit8(" + p8_to_f(this) + ")"
  }
}

const isodd = (x) => n % 2 != 0;

// breaks down a Float64 value into sign, exponent, fraction, and summary bits.
const breakdown = (x) => {
  //use A Float64 array.
  var float_rep = new Float64Array(1);
  //overlay a UInt8 array on top, to decompose into 8 bytes of info.
  var byte_rep = new Uint8Array(float_rep.buffer);
  //assign the floating point representation.
  float_rep[0] = x;

  //assign mantissa based on
  var sgn = (byte_rep[7] >> 7 != 0);
  var exp = ((byte_rep[7] & 0x7f) << 4 | byte_rep[6] >> 4) - 0x3ff;
  var frc = (byte_rep[6] & 0x0f) << 4 | byte_rep[5] >> 4;
  var sum = (byte_rep[5] & 0x0f) != 0 || (byte_rep[4] != 0) || (byte_rep[3] != 0) ||
                   (byte_rep[2] != 0) || (byte_rep[1] != 0) || (byte_rep[0] != 0)
  return { sgn: sgn, exp: exp, frc: frc, sum: sum };
}

const rebuild = (seed, shift, frc, sum) => {
  pos_res = (seed >> shift) | (frc >> (shift + 3));
  var grd = (frc & (4 << shift)) != 0;
  var sum = sum || ((frc & ((4 << shift) - 1)) != 0);
  //round-to-nerest even:
  pos_res += ((grd && isodd(pos_res)) || (grd && sum)) ? 1 : 0;
  return pos_res
}

const f_to_p8int = (x) => {
  if (x == 0.0)     { return 0; }
  if (isNaN(x))     { return 255; }
  if (!isFinite(x)) { return 255; }

  var pos_res = +0;
  val = breakdown(x)
  //check of overflow or underflow
  if (val.exp >= 8) {
    pos_res = 127; // set to maxpos
  } else if (val.exp < -8) {
    pos_res = 1;   // set to minpos
  } else if (val.exp >= 0){
    //start with 0xC0 and shift it the correct number of bits.
    pos_res = rebuild(-64, val.exp, val.frc, val.sum) + 128
  } else {
    pos_res = rebuild(32, -val.exp - 1, val.frc, val.sum)
  }
  return val.sgn ? (-pos_res + 256) : pos_res
}

const f_to_p8 = (x) => {
  var result = new Posit8()
  result.data = f_to_p8int(x)
  return result
}

// an artisanal, hand-crafted lookup table.
const __posit_lookuptable64 = [
  0.0,     0.015625,  0.03125,  0.046875,  0.0625,  0.078125,  0.09375,  0.109375,
  0.125,   0.140625,  0.15625,  0.171875,  0.1875,  0.203125,  0.21875,  0.234375,
  0.25,    0.265625,  0.28125,  0.296875,  0.3125,  0.328125,  0.34375,  0.359375,
  0.375,   0.390625,  0.40625,  0.421875,  0.4375,  0.453125,  0.46875,  0.484375,
  0.5,     0.515625,  0.53125,  0.546875,  0.5625,  0.578125,  0.59375,  0.609375,
  0.625,   0.640625,  0.65625,  0.671875,  0.6875,  0.703125,  0.71875,  0.734375,
  0.75,    0.765625,  0.78125,  0.796875,  0.8125,  0.828125,  0.84375,  0.859375,
  0.875,   0.890625,  0.90625,  0.921875,  0.9375,  0.953125,  0.96875,  0.984375,
  1.0,     1.03125,   1.0625,   1.09375,   1.125,   1.15625,   1.1875,   1.21875,
  1.25,    1.28125,   1.3125,   1.34375,   1.375,   1.40625,   1.4375,   1.46875,
  1.5,     1.53125,   1.5625,   1.59375,   1.625,   1.65625,   1.6875,   1.71875,
  1.75,    1.78125,   1.8125,   1.84375,   1.875,   1.90625,   1.9375,   1.96875,
  2.0,     2.125,     2.25,     2.375,     2.5,     2.625,     2.75,     2.875,
  3.0,     3.125,     3.25,     3.375,     3.5,     3.625,     3.75,     3.875,
  4.0,     4.5,       5.0,      5.5,       6.0,     6.5,       7.0,      7.5,
  8.0,     10.0,      12.0,     14.0,      16.0,    24.0,      32.0,     64.0,
  NaN,     -64.0,     -32.0,    -24.0,     -16.0,   -14.0,     -12.0,    -10.0,
  -8.0,    -7.5,      -7.0,     -6.5,      -6.0,    -5.5,      -5.0,     -4.5,
  -4.0,    -3.875,    -3.75,    -3.625,    -3.5,    -3.375,    -3.25,    -3.125,
  -3.0,    -2.875,    -2.75,    -2.625,    -2.5,    -2.375,    -2.25,    -2.125,
  -2.0,    -1.96875,  -1.9375,  -1.90625,  -1.875,  -1.84375,  -1.8125,  -1.78125,
  -1.75,   -1.71875,  -1.6875,  -1.65625,  -1.625,  -1.59375,  -1.5625,  -1.53125,
  -1.5,    -1.46875,  -1.4375,  -1.40625,  -1.375,  -1.34375,  -1.3125,  -1.28125,
  -1.25,   -1.21875,  -1.1875,  -1.15625,  -1.125,  -1.09375,  -1.0625,  -1.03125,
  -1.0,    -0.984375, -0.96875, -0.953125, -0.9375, -0.921875, -0.90625, -0.890625,
  -0.875,  -0.859375, -0.84375, -0.828125, -0.8125, -0.796875, -0.78125, -0.765625,
  -0.75,   -0.734375, -0.71875, -0.703125, -0.6875, -0.671875, -0.65625, -0.640625,
  -0.625,  -0.609375, -0.59375, -0.578125, -0.5625, -0.546875, -0.53125, -0.515625,
  -0.5,    -0.484375, -0.46875, -0.453125, -0.4375, -0.421875, -0.40625, -0.390625,
  -0.375,  -0.359375, -0.34375, -0.328125, -0.3125, -0.296875, -0.28125, -0.265625,
  -0.25,   -0.234375, -0.21875, -0.203125, -0.1875, -0.171875, -0.15625, -0.140625,
  -0.125,  -0.109375, -0.09375, -0.078125, -0.0625, -0.046875, -0.03125, -0.015625,
 ]

const p8_to_f = (x) => __posit_lookuptable64[x.data]

const posit8_add = (a, b) => f_to_p8(p8_to_f(a) + p8_to_f(b))
const posit8_sub = (a, b) => f_to_p8(p8_to_f(a) - p8_to_f(b))
const posit8_mul = (a, b) => f_to_p8(p8_to_f(a) * p8_to_f(b))
const posit8_div = (a, b) => f_to_p8(p8_to_f(a) / p8_to_f(b))

//these are not efficient functions, but they will get the job done.
const posit8_gt  = (a, b) => p8_to_f(a) >  p8_to_f(b)
const posit8_gte = (a, b) => p8_to_f(a) >= p8_to_f(b)
const posit8_lt  = (a, b) => p8_to_f(a) <  p8_to_f(b)
const posit8_lte = (a, b) => p8_to_f(a) <= p8_to_f(b)
const posit8_eq  = (a, b) => p8_to_f(a) == p8_to_f(b)
