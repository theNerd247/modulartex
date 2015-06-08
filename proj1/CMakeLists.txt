cmake_minimum_required(VERSION 2.6)
cmake_policy(SET CMP0011 NEW) #acknowledge policy push/pop

include(LaTeXBuild)

set(projectName "proj1")

set(mainTexFile "main.tex")

set(texDir "tex")
set(styDir "sty")
set(imgDir "img")
set(otherIncludes "")

set(subProjects "")

set(texinputs 
	"${texDir}"
	"${styDir}"
	"${imgDir}"
	"${otherIncludes}")

SetupLaTexBuildEnv (
	"${projectName}" # the name of the project (this also sets the name of the pdf file)
	"${mainTexFile}" # the main tex file
	"${texinputs}" # all the standalone TEXINPUTS for this project
	"${subProjects}"
	)

BuildLaTeX(${projectName})
