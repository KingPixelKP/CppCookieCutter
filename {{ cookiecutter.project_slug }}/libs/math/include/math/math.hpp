#pragma once

namespace math {
/**
   * @brief A demo Vector to show of the template
   * 
   */
class Vector {
 public:
  /**
  * @brief Destroy the darn vector
  * 
  */
  ~Vector() = default;

  /**
   * @brief Add two beautiful vectors
   * 
   * @param other the other vector to add to this
   * @return Vector a brand new vector with added results
   */
  [[nodiscard]] Vector add(const Vector& other) const;
  /**
   * @brief Sub two beautiful vectors
   * 
   * @param other the other vector to sub to this
   * @return Vector a brand new vector with subbed results
   */
  [[nodiscard]] Vector sub(const Vector& other) const;

  /**
   * @brief The two beautiful integers representing a 2d vector
   * 
   */
  int x_, y_;
};
}  // namespace math
