#include "math/math.hpp"

namespace math {

Vector Vector::add(const Vector &other) const {
  return {.x_ = x_ + other.x_, .y_ = y_ + other.y_};
}
Vector Vector::sub(const Vector &other) const {
  return {.x_ = x_ - other.x_, .y_ = y_ - other.y_};
}
} // namespace math
