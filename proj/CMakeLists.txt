cmake_minimum_required(VERSION 2.6)
cmake_policy(SET CMP0011 NEW) #acknowledge policy push/pop

include(LaTeXBuild)

project("proj")

set(mainTexFile "main.tex")

set(texDir "tex")
set(styDir "sty")
set(imgDir "img")
set(otherIncludes "")

#set(subProjects "proj2")

set(texinputs 
	"${texDir}"
	"${styDir}"
	"${imgDir}"
	"${otherIncludes}")

SetupLaTexBuildEnv (
	"${mainTexFile}" # the main tex file
	"${texinputs}" # all the standalone TEXINPUTS for this project
	"${subProjects}"
	)

addStyleFile("sty/customRefs.sty")
addStyleFile("sty/customSty.sty")
#parseUsePackage("\\usepackage[op1,op2,op3,op4]{}"  nme ops)

#addLatexPackage("tabularx" "")
#addLatexPackage("booktabs" "") 
#addLatexPackage("refstyle" "")

GenerateStyleFile()
