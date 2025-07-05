cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
#     ▲     ▲
#   source  build directory

# compile
cmake --build build -j$(nproc)
