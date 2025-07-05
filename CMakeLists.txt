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
        -Wall -Wextra -Wshadow
        -fno-exceptions -fno-rtti)

# ------------------------------------------------------------------
# 1.  External dependencies
# ------------------------------------------------------------------
find_package(Threads REQUIRED)
find_package(PkgConfig REQUIRED)

# ---- Boost (system & filesystem) ----
find_package(Boost REQUIRED COMPONENTS system filesystem)
if (NOT Boost_FOUND)
    message(FATAL_ERROR "Boost not found; install libboost-all-dev (Ubuntu) or boost-devel (RHEL/Fedora).")
endif()

# ---- QuickFIX ----
find_path(QUICKFIX_INCLUDE_DIR quickfix/Application.h)
find_library(QUICKFIX_LIBRARY quickfix)
if (NOT QUICKFIX_INCLUDE_DIR OR NOT QUICKFIX_LIBRARY)
    message(FATAL_ERROR "QuickFIX not found; install libquickfix-dev (Ubuntu) or build from source.")
endif()
set(QUICKFIX_LIBRARIES ${QUICKFIX_LIBRARY})

# ---- pcap (manual check, no FindPCAP.cmake needed) ----
find_path(PCAP_INCLUDE_DIR pcap/pcap.h)
find_library(PCAP_LIBRARY pcap)
if (NOT PCAP_INCLUDE_DIR OR NOT PCAP_LIBRARY)
    message(FATAL_ERROR "libpcap not found; install libpcap-dev (Ubuntu) or libpcap-devel (RHEL/Fedora).")
endif()
set(PCAP_LIBRARIES ${PCAP_LIBRARY})

# ------------------------------------------------------------------
# 2.  Include directories
# ------------------------------------------------------------------
include_directories(
        ${CMAKE_SOURCE_DIR}/include
        ${QUICKFIX_INCLUDE_DIR}
        ${Boost_INCLUDE_DIRS}
        ${PCAP_INCLUDE_DIR})

# ------------------------------------------------------------------
# 3.  order_router executable (FIX/iLink gateway)
# ------------------------------------------------------------------
add_executable(order_router
        src/order_router.cpp)

target_link_libraries(order_router
        PRIVATE
        ${QUICKFIX_LIBRARIES}
        ${Boost_LIBRARIES}
        Threads::Threads)

# ------------------------------------------------------------------
# 4.  md_listener executable (market-data tap)
# ------------------------------------------------------------------
add_executable(md_listener
        src/md_listener.cpp)

target_link_libraries(md_listener
        PRIVATE
        ${PCAP_LIBRARIES}
        Threads::Threads)

# ------------------------------------------------------------------
# 5.  Optional install targets
# ------------------------------------------------------------------
install(TARGETS order_router md_listener
        RUNTIME DESTINATION bin)
# ===============================================================
