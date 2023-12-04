sed -i 's/cmake_minimum_required(VERSION 3.22.1)/cmake_minimum_required(VERSION 3.10.1)/' CMakeLists.txt
cmake  -S .
cmake --build .