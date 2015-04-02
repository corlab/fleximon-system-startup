CMAKE_MINIMUM_required(VERSION 2.4)

project(vdemo_scripts)

include(FindPkgConfig)
pkg_search_module(VDEMO REQUIRED vdemo)

set(PROGNAME vdemo_scripts)

set(vdemo_prefix ${VDEMO_PREFIX})
set(vdemo_demoroot "${CMAKE_INSTALL_PREFIX}/etc/vdemo_scripts")
set(prefix ${CMAKE_INSTALL_PREFIX})
set(bindir "${CMAKE_INSTALL_PREFIX}/bin")

install(FILES vdemo_aux_functions.sh DESTINATION "etc/vdemo_scripts")

# generate the demo launchers
file(GLOB demos "demos/*.in")

# Remove all generated scripts from file list in case of in source builds
foreach(item ${demos})
	if(${item} MATCHES "/vdemo_[^/]*.*$")
		list(REMOVE_ITEM demos ${item})
	endif()
endforeach()

# configure files
set(demofiles)
foreach(demo ${demos})
    get_filename_component(demo_name ${demo} NAME_WE)
    set(demo_config "${demo_name}.sh")
    configure_file(${demo} "${CMAKE_CURRENT_BINARY_DIR}/${demo_config}" @ONLY)
    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${demo_config}" DESTINATION "etc/vdemo_scripts")
    list(APPEND demofiles ${demo_config})
endforeach()

file(GLOB components "component_scripts/component_*")
install(FILES ${components}
        DESTINATION "etc/vdemo_scripts/component_scripts"
        PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ OWNER_EXECUTE GROUP_EXECUTE WORLD_EXECUTE)

# configure starter script for each demo configuration
foreach(demofile ${demofiles})
    message(STATUS "file = ${demofile}")
	get_filename_component(demoname ${demofile} NAME_WE)
	set(VDEMO_demofile "${vdemo_demoroot}/${demoname}.sh")
	set(vdemo_starter "vdemo_${demoname}.sh")
	configure_file(vdemo_start.in ${vdemo_starter})
	install(FILES "${PROJECT_BINARY_DIR}/${vdemo_starter}"
            DESTINATION bin
            PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ OWNER_EXECUTE GROUP_EXECUTE WORLD_EXECUTE)
endforeach()

# install data
file(GLOB data_files "data/*")
foreach(data_file ${data_files})
    # check whether we need to configure this file
    if(data_file MATCHES ".*\\.in$")
        string(REGEX REPLACE "^(.*)\\.in$" "\\1" filename ${data_file})
        configure_file(${data_file} "${CMAKE_CURRENT_BINARY_DIR}/data/${filename}" @ONLY)
        install(FILES "${CMAKE_CURRENT_BINARY_DIR}/data/${filename}"
                DESTINATION "etc/vdemo_scripts/data")
    else()
        install(FILES ${data_file}
                DESTINATION "etc/vdemo_scripts/data")
    endif()
endforeach()
