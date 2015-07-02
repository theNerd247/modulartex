cmake_minimum_required(VERSION 2.6)
cmake_policy(SET CMP0011 NEW) #acknowledge policy push/pop

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(LaTeXBuild)
include(FindLATEX)

project("project")

set(PDF_COMPILER_OPTS "")

# list of projects to build
set(projects 
	"proj3"
	"proj2"
	"proj"
	)

#build the project infos
foreach(proj ${projects})
	message(STATUS "adding project: ${proj}")
	add_subdirectory(${proj})
	message(STATUS "${${proj}_includeDirs}")
endforeach(proj)
