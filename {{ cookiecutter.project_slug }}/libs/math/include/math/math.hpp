#pragma once

namespace math {
class Vector {
public:
  ~Vector() = default;

  [[nodiscard]] Vector add(const Vector &other) const;
  [[nodiscard]] Vector sub(const Vector &other) const;

  int x_, y_;
};
} // namespace math
