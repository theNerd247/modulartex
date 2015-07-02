cmake_minimum_required(VERSION 2.6)
cmake_policy(SET CMP0011 NEW) #acknowledge policy push/pop

function(SetupLaTexBuildEnv 
	mainTexFile # the main tex file
	inputList # the dirs to search for building pdf files (relative to this
	          #CMakeLists)
	subProjects # list of sub projects that this project depends on
	)

	# build the main file path
	set("${PROJECT_NAME}_mainTexFilePath"
		"${CMAKE_CURRENT_SOURCE_DIR}/${mainTexFile}" 
		CACHE INTERNAL "main tex file to compile from"
		)
	
	# build the TEXINPUTS environment variable
	#  - get the exported input paths for each sub project
	set(${PROJECT_NAME}_includeDirs ${CMAKE_CURRENT_SOURCE_DIR})
	
	#build the include list for this project
	foreach(dir ${inputList})
		list(APPEND ${PROJECT_NAME}_includeDirs ${CMAKE_CURRENT_SOURCE_DIR}/${dir})
	endforeach(dir)

	#add the include directories of the subprojects
	foreach(p ${subProjects})
		list(APPEND ${PROJECT_NAME}_includeDirs ${${p}_includeDirs})
	endforeach(p)

	#export our provided include dirs
	list(REMOVE_DUPLICATES ${PROJECT_NAME}_includeDirs)
	set(${PROJECT_NAME}_includeDirs 
		${${PROJECT_NAME}_includeDirs}
		CACHE INTERNAL "include directories provided by this project"
		)

	#set the TEXINPUTS variable
	foreach(d ${${PROJECT_NAME}_includeDirs})
		set(${PROJECT_NAME}_texInputs 
			"${${PROJECT_NAME}_texInputs}:${d}"
			)
	endforeach(d)

	############################## CUUSTOM COMMAND ##############################
	add_custom_command(
		OUTPUT "${CMAKE_BINARY_DIR}/${PROJECT_NAME}.pdf"
		COMMAND
			"TEXINPUTS=${GLOBAL_TEXINPUTS}:${${PROJECT_NAME}_texInputs}" # set the TEXINPUTS
			${PDFLATEX_COMPILER} # run pdflatex
				${PDF_COMPILER_OPTS}
				"${${PROJECT_NAME}_mainTexFilePath}"
		DEPENDS "${${PROJECT_NAME}_mainTexFilePath}"
		COMMENT "pdflates"
		)

	add_custom_target("build_${PROJECT_NAME}" 
		ALL 
		DEPENDS "${CMAKE_BINARY_DIR}/${PROJECT_NAME}.pdf"
		)

	set_target_properties("build_${PROJECT_NAME}"
		PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
		)
	############################ End CUUSTOM COMMAND ############################

endfunction(SetupLaTexBuildEnv)
