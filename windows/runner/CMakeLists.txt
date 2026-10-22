cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "Runner.rc"
  "runner.exe.manifest"
)

apply_standard_settings(${BINARY_NAME})
set_target_properties(${BINARY_NAME} PROPERTIES
  OUTPUT_NAME "institution_management_app"
)

target_compile_definitions(${BINARY_NAME} PRIVATE
  $<$<NOT:$<CONFIG:Debug>>:FLUTTER_RELEASE>
)
