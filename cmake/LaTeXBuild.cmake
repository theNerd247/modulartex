cmake_minimum_required(VERSION 2.6)
cmake_policy(SET CMP0011 NEW) #acknowledge policy push/pop

function(SetupLaTexBuildEnv 
	projectName # the name of the project (this also sets the name of the pdf file)
	mainTexFile # the main tex file
	inputList # the dirs to search for building pdf files (relative to this
	          #CMakeLists)
	subProjects # list of sub projects that this project depends on
	)

	project(${projectName})

	# build the main file path
	set("${projectName}_mainTexFilePath"
		"${CMAKE_CURRENT_SOURCE_DIR}/${mainTexFile}" 
		CACHE INTERNAL "main tex file to compile from"
		)
	
	# build the TEXINPUTS environment variable
	#  - get the exported input paths for each sub project
	set("${projectName}_texInputs" 
		"${CMAKE_CURRENT_SOURCE_DIR}"
		)
	
	#build the include list for this project
	foreach(dir ${inputList})
		set("${projectName}_texInputs"
			"${${projectName}_texInputs}:${CMAKE_CURRENT_SOURCE_DIR}/${dir}"
			)
	endforeach(dir)

	#set the list of dependent projects
	set("${projectName}_dependProjects" 
		${subProjects}
		CACHE INTERNAL "list of dependent projects for this project"
		)

	#export our provided TEXINPUTS
	set("${projectName}_texInputs" "${${projectName}_texInputs}" 
		CACHE INTERNAL "TEXINPUTS provided by this project"
		)
endfunction(SetupLaTexBuildEnv)

function(BuildLaTeX
		projectName
		)

	add_custom_command(
		OUTPUT "${CMAKE_BINARY_DIR}/${projectName}.pdf"
		COMMAND ${PDFLATEX_COMPILER}
			${PDF_COMPILER_OPTS}
			"${${projectName}_mainTexFilePath}"
		DEPENDS "${${projectName}_mainTexFilePath}"
		COMMENT "pdflates"
		)

	add_custom_target("build_${projectName}" 
		ALL 
		DEPENDS "${CMAKE_BINARY_DIR}/${projectName}.pdf"
		)

	set_target_properties("build_${projectName}"
		PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
		)

endfunction(BuildLaTeX)
