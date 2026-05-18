find_program(RED2_ICX icx PATHS /opt/intel/oneapi/compiler/latest/bin)
find_program(RED2_ICPX icpx PATHS /opt/intel/oneapi/compiler/latest/bin)
find_program(RED2_IFX ifx PATHS /opt/intel/oneapi/compiler/latest/bin)

set(CMAKE_C_COMPILER "${RED2_ICX}" CACHE STRING "")
set(CMAKE_CXX_COMPILER "${RED2_ICPX}" CACHE STRING "")
set(CMAKE_Fortran_COMPILER "${RED2_IFX}" CACHE STRING "")
