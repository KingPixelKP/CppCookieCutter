{% if cookiecutter.project_type == "hybrid" %}
#include "fmt/base.h"
#include "math/math.hpp"
{% endif %}
#include <fmt/printf.h>

int main() {
{% if cookiecutter.project_type == "hybrid" %}
  auto vec = math::Vector(1, 2);

  fmt::println("Vector: x:{}, y:{}", vec.x_, vec.y_);
{% else %}
  fmt::println("Hello from {{ cookiecutter.project_name }} v{{ cookiecutter.project_version }}");
{% endif %}
}
