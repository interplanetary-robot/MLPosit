#include "posit8.h"
#include <stdbool.h>

Posit8::Posit8(){ this->data = P8ZER; }

Posit8::Posit8(const float a){ this->data = f_to_p8(a).udata; }

Posit8::Posit8(const double a){ this->data = f_to_p8((float) a).udata; }

Posit8::Posit8(const Posit8 &a){ this->data = a.data; }

Posit8::Posit8(const posit8_t a){ this->data = a.udata; }

Posit8 Posit8::operator -() const{
  Posit8 res;
  res.data = -(this->data);
  return res;
}

Posit8 &Posit8::operator *=(const Posit8 rhs){
  posit8_t res;

  res = posit8_mul(*this, rhs);

  this->data = res.udata;
  return (*this);
}

Posit8 Posit8::operator *(const Posit8 rhs) const{
  Posit8 res;          //create a return value from the stack.

  res = posit8_t(posit8_mul(*this, rhs));

  return Posit8(res);
}

Posit8 &Posit8::operator -=(const Posit8 rhs){
  posit8_t res;

  res = posit8_sub(*this, rhs);

  this->data = res.udata;
  return (*this);
}

Posit8 Posit8::operator -(const Posit8 rhs) const{
  Posit8 res;          //create a return value from the stack.

  res = posit8_t(posit8_sub(*this, rhs));

  return Posit8(res);
}

Posit8 &Posit8::operator +=(const Posit8 rhs){
  posit8_t res;

  res = posit8_add(*this, rhs);

  this->data = res.udata;
  return (*this);
}

Posit8 Posit8::operator +(const Posit8 rhs) const{
  Posit8 res;          //create a return value from the stack.

  res = posit8_t(posit8_add(*this, rhs));

  return Posit8(res);
}

Posit8 &Posit8::operator /=(const Posit8 rhs){
  posit8_t res;

  res = posit8_div(*this, rhs);

  this->data = res.udata;
  return (*this);
}

Posit8 Posit8::operator /(const Posit8 rhs) const{
  Posit8 res;          //create a return value from the stack.

  res = posit8_t(posit8_div(*this, rhs));

  return Posit8(res);
}

bool Posit8::operator ==(const Posit8 rhs) const{
  posit8_t lhs_p, rhs_p;
  lhs_p.udata = this->data;
  rhs_p.udata = rhs.data;

  return posit8_eq(lhs_p, rhs_p);
}

bool Posit8::operator >(const Posit8 rhs) const{
  posit8_t lhs_p, rhs_p;
  lhs_p.udata = this->data;
  rhs_p.udata = rhs.data;

  return posit8_gt(lhs_p, rhs_p);
}

bool Posit8::operator >=(const Posit8 rhs) const{
  posit8_t lhs_p, rhs_p;
  lhs_p.udata = this->data;
  rhs_p.udata = rhs.data;

  return posit8_gte(lhs_p, rhs_p);
}

bool Posit8::operator <=(const Posit8 rhs) const{
  posit8_t lhs_p, rhs_p;
  lhs_p.udata = this->data;
  rhs_p.udata = rhs.data;

  return posit8_lte(lhs_p, rhs_p);
}

bool Posit8::operator <(const Posit8 rhs) const{
  posit8_t lhs_p, rhs_p;
  lhs_p.udata = this->data;
  rhs_p.udata = rhs.data;

  return posit8_lt(lhs_p, rhs_p);
}

Posit8::operator float() const{
  return (float) p8_to_f((posit8_t)(*this));
}

Posit8::operator double() const{
  return (double) p8_to_f((posit8_t)(*this));
}

Posit8::operator posit8_t() const{
  posit8_t res;
  res.udata = this->data;
  return res;
}

Posit8 mulinv (const Posit8 x){
  Posit8 res_c(posit8_mulinv(x));
  return res_c;
}
