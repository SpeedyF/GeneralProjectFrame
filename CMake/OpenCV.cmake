# Sanity checks
  if(DEFINED OpenCV_DIR AND NOT EXISTS ${OpenCV_DIR})
    message(FATAL_ERROR "OpenCV_DIR variable is defined but corresponds to non-existing directory")
  endif()

  set(proj OpenCV)
  set(proj_DEPENDENCIES)
  set(OpenCV_DEPENDS ${proj})

  if(NOT DEFINED OpenCV_DIR)

    set(additional_cmake_args
      -DBUILD_opencv_java:BOOL=OFF
      -DBUILD_opencv_ts:BOOL=OFF
      -DBUILD_PERF_TESTS:BOOL=OFF
    )

    # 12-05-02, muellerm, added QT usage by OpenCV if QT is used
    # 12-09-11, muellerm, removed automatic usage again, since this will struggle with the Qt application object
    if(PROJ_USE_QT5)
      list(APPEND additional_cmake_args
           -DWITH_QT:BOOL=OFF
           -DWITH_QT_OPENGL:BOOL=OFF
           -DQT_QMAKE_EXECUTABLE:FILEPATH=${QT_QMAKE_EXECUTABLE}
          )
    endif()

    set(opencv_url ${MYPROJ_THIRDPARTY_DOWNLOAD_PREFIX_URL}/opencv-2.4.13.2.tar.gz)
    set(opencv_url_md5 80a4a3bee0e98898bbbc68986ca73655)

    ExternalProject_Add(${proj}
      LIST_SEPARATOR ${sep}
      URL ${opencv_url}
      URL_MD5 ${opencv_url_md5}
      # Related bug: http://bugs.mitk.org/show_bug.cgi?id=5912
      PATCH_COMMAND ${PATCH_COMMAND} -N -p1 -i ${CMAKE_CURRENT_LIST_DIR}/OpenCV.patch
      CMAKE_GENERATOR ${gen}
      CMAKE_ARGS
        ${ep_common_args}
		-DBUILD_opencv_python:BOOL=OFF
        -DBUILD_NEW_PYTHON_SUPPORT:BOOL=OFF
        -DBUILD_TESTS:BOOL=OFF
        -DBUILD_DOCS:BOOL=OFF
        -DBUILD_EXAMPLES:BOOL=OFF
        -DBUILD_DOXYGEN_DOCS:BOOL=OFF
        -DWITH_CUDA:BOOL=ON
		
        ${additional_cmake_args}
      CMAKE_CACHE_ARGS
        ${ep_common_cache_args}
      CMAKE_CACHE_DEFAULT_ARGS
        ${ep_common_cache_default_args}
      DEPENDS ${proj_DEPENDENCIES}
    )

    set(OpenCV_DIR ${ep_prefix})
    FunctionInstallExternalCMakeProject(${proj})

  else()

    MacroEmptyExternalProject(${proj} "${proj_DEPENDENCIES}")

  endif()