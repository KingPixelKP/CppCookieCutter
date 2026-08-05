#include <iostream>
int main() {
    std::cout << "Hello from: {% raw %}{{ cookiecutter.exec_slug }}{% endraw %}\n";
    return 0;
}