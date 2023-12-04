cmake_minimum_required(VERSION 3.22.1)
project(nbody
        VERSION 1.0.0
        LANGUAGES C CXX)

find_package(MPI REQUIRED)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Werror=unused-variable")
add_executable(nbody_naive nbody_naive.cpp argc.cpp universe.cpp)
target_compile_definitions(nbody_naive PUBLIC NAIVE)
target_include_directories(nbody_naive PRIVATE ${MPI_C_INCLUDE_PATH})
target_link_libraries(nbody_naive PRIVATE ${MPI_C_LIBRARIES})

add_executable(nbody_barnehut nbody_barnehut.cpp argc.cpp universe.cpp quad_tree.cpp)
target_compile_definitions(nbody_barnehut PUBLIC BARNEHUT)
target_include_directories(nbody_barnehut PRIVATE ${MPI_C_INCLUDE_PATH})
target_link_libraries(nbody_barnehut PRIVATE ${MPI_C_LIBRARIES})

add_executable(nbody_mpi nbody_mpi.cpp argc.cpp universe.cpp quad_tree.cpp)
target_compile_definitions(nbody_mpi PUBLIC BARNEHUT_PARALLEL)
target_include_directories(nbody_mpi PRIVATE ${MPI_C_INCLUDE_PATH})
target_link_libraries(nbody_mpi PRIVATE ${MPI_C_LIBRARIES})