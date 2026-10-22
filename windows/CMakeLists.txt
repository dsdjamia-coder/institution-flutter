cmake_minimum_required(VERSION 3.14)
project(institution_management_app LANGUAGES CXX)

set(BINARY_NAME "institution_management_app")

cmake_policy(SET CMP0079 NEW)

# Flutter CMake build integration
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")

# Add application target
add_subdirectory("runner")
