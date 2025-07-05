# ===== hft-bot/CMakeLists.txt =====================================
cmake_minimum_required(VERSION 3.18)
project(hft-bot LANGUAGES CXX)

# ------------------------------------------------------------------
# 0.  Global compiler options
# ------------------------------------------------------------------
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
add_compile_options(
        -O3 -march=native -flto
        -Wall -Wextra -Wshadow -Wnon-virtual-dtor
        -fno-exceptions -fno-rtti)

# ------------------------------------------------------------------
# 1.  External dependencies
# ------------------------------------------------------------------
find_package(Threads REQUIRED)              # pthread
find_package(PkgConfig REQUIRED)

# ---- Boost ----
find_package(Boost REQUIRED COMPONENTS system filesystem)
if (NOT Boost_FOUND)
    message(FATAL_ERROR "Boost not found; install libboost-all-dev")
endif()

# ---- QuickFIX ----
find_path(QUICKFIX_INCLUDE_DIR quickfix/Application.h)
find_library(QUICKFIX_LIB quickfix)
if (NOT QUICKFIX_INCLUDE_DIR OR NOT QUICKFIX_LIB)
    message(FATAL_ERROR "QuickFIX not found; apt install libquickfix-dev")
endif()

# ---- pcap ----
find_package(PCAP REQUIRED)
if (NOT PCAP_FOUND)
    message(FATAL_ERROR "libpcap not found; apt install libpcap-dev")
endif()

include_directories(
        ${CMAKE_SOURCE_DIR}/include
        ${QUICKFIX_INCLUDE_DIR}
        ${Boost_INCLUDE_DIRS}
        ${PCAP_INCLUDE_DIRS})

# ------------------------------------------------------------------
# 2.  order_router executable (FIX gateway)
# ------------------------------------------------------------------
add_executable(order_router
        src/order_router.cpp)

target_link_libraries(order_router
        Threads::Threads
        ${QUICKFIX_LIB}
        ${Boost_LIBRARIES})

# ------------------------------------------------------------------
# 3.  md_listener executable (market-data tap)
# ------------------------------------------------------------------
add_executable(md_listener
        src/md_listener.cpp)

target_link_libraries(md_listener
        Threads::Threads
        ${PCAP_LIBRARIES})

# ------------------------------------------------------------------
# 4.  Install targets (optional)
# ------------------------------------------------------------------
install(TARGETS order_router md_listener
        RUNTIME DESTINATION bin)
# ===============================================================
