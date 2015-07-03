cmake_minimum_required(VERSION 2.6)
cmake_policy(SET CMP0011 NEW) #acknowledge policy push/pop

include(LaTeXBuild)

project("proj")

set(mainTexFile "main.tex")

set(texDir "tex")
set(styDir "sty")
set(imgDir "img")

#set(subProjects "proj2")
set(styleFiles "${styDir}/labreport.sty")

set(includeList 
	"${texDir}"
	"${styDir}"
	"${imgDir}"
	)

SetupLaTexBuildEnv (
	# the main tex file
	"${mainTexFile}" 
	# the file search paths this project provides
	"${includeList}" 
	# the style files this project provides
	"${styleFiles}"
	# projects this project depends on
	"${subProjects}"
	)
