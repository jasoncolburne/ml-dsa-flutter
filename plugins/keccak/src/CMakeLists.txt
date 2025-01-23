# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(keccak_library VERSION 0.0.1 LANGUAGES C)

add_library(keccak SHARED
  "KeccakSum/KeccakHash.c"
  "KeccakSum/SimpleFIPS202.c"
  "KeccakSum/KeccakP-1600-opt64.c"
  "KeccakSum/KeccakSponge.c"
)

set_target_properties(keccak PROPERTIES
  PUBLIC_HEADER keccak.h
  OUTPUT_NAME "keccak"
)

target_compile_definitions(keccak PUBLIC DART_SHARED_LIB)

if (ANDROID)
  # Support Android 15 16k page size
  target_link_options(keccak PRIVATE "-Wl,-z,max-page-size=16384")
endif()
