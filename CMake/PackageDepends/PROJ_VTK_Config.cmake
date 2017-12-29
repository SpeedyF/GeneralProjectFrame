find_package(VTK COMPONENTS ${VTK_REQUIRED_COMPONENTS_BY_MODULE} REQUIRED)
if(VTK_FOUND AND NOT VTK_BUILD_SHARED_LIBS)
  message(FATAL_ERROR "MITK only supports a VTK which was built with shared libraries. Turn on BUILD_SHARED_LIBS in your VTK config.")
endif()

if(MITK_USE_QT5)
  find_package(Qt5Widgets REQUIRED QUIET)
endif()

list(APPEND ALL_INCLUDE_DIRECTORIES ${VTK_INCLUDE_DIRS})
list(APPEND ALL_LIBRARIES ${VTK_LIBRARIES})
list(APPEND ALL_COMPILE_DEFINITIONS ${VTK_DEFINITIONS})
