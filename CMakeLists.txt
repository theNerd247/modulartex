cmake_minimum_required(VERSION 2.6)
cmake_policy(SET CMP0011 NEW) #acknowledge policy push/pop

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(LaTeXBuild)
include(FindLATEX)

project("TexProject")

set(PDF_COMPILER_OPTS "")

# list of projects to build
set(projects "proj1")

#build the project infos
foreach(proj "${projects}")
	add_subdirectory(${proj})
endforeach(proj)

# finish building the TEXINPUTS for projects with dependencies
foreach(proj "${projects}")
	set("${proj}_TEXINPUTS" "${${proj}_texInputs}")
	foreach(dep ${${proj}_dependProjects})
		set("${proj}_TEXINPUTS" "${${proj}_TEXINPUTS}:${${dep}_texInputs}")
	endforeach(dep)
endforeach(proj)

foreach(projectName "${projects}")
endforeach(projectName)
