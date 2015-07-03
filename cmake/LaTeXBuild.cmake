cmake_minimum_required(VERSION 2.6)
cmake_policy(SET CMP0011 NEW) #acknowledge policy push/pop

################################## Utility ##################################

# append a string to a string
function(strAppend
		#destination string
		dest
		#content to append)
		needle
		)
	string(CONCAT ${dest} ${${dest}} ${needle})
	set(${dest} ${${dest}} PARENT_SCOPE)

endfunction(strAppend)

function(removeLastChar
		#input string
		str
		)

	string(LENGTH ${${str}} length)
	math(EXPR length ${length}-1)
	string(SUBSTRING ${${str}} 0 ${length} ${str})
	set(${str} ${${str}} PARENT_SCOPE)
endfunction(removeLastChar)

# parses the given string (assumed to be an uncommented line from a text file)
# for the \usepackage[...]{...} information. 
function(parseUsePackage
		# the line to parse
		line
		# the name of the package found. Set to "" upon parser failure
		packageName
		# the options given for the package
		packageOptions
		)

	string(REGEX MATCH "\\usepackage(\\[(.*)\\]|){(.*)}" parsedInfo ${line})
	set(${packageName} "${CMAKE_MATCH_3}" PARENT_SCOPE)

	string(REGEX REPLACE "," ";" ops "${CMAKE_MATCH_2}")
	set(${packageOptions} ${ops} PARENT_SCOPE)

endfunction(parseUsePackage)
################################ End Utility ################################

############################# SetupLaTexBuildEnv #############################
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
########################### End SetupLaTexBuildEnv ###########################

############################## PackageManager ##############################

# add a package to the list of packages to be included in the project style file
function(addLatexPackage
		# the name of the package
		packageName
		#package options list
		packageOptions
		)

	# sanity check
	if(NOT packageName)
		return()
	endif(NOT packageName)

	# append the options to the cooresponding package (this should create a new
	# package if it doesn't exist
	list(APPEND ${PROJECT_NAME}_pkg_${packageName} ${packageOptions})

	#remove the duplicate options
	if(packageOptions)
		list(REMOVE_DUPLICATES ${PROJECT_NAME}_pkg_${packageName})
	endif(packageOptions)

	# export the changes above
	set(${PROJECT_NAME}_pkg_${packageName} 
		"${${PROJECT_NAME}_pkg_${packageName}}"
		CACHE INTERNAL "pkg_${packageName} package"
		)

	#add the package to the list of packages to track
	list(APPEND ${PROJECT_NAME}_packages ${packageName})
	list(REMOVE_DUPLICATES ${PROJECT_NAME}_packages)
	set(${PROJECT_NAME}_packages
		${${PROJECT_NAME}_packages}
		CACHE INTERNAL "list of packages for ${PROJECT_NAME}"
		)

endfunction(addLatexPackage)

#function(addCustomLatexStyles
## handwritten style code
#str
#)
#endfunction(addCustomLatexStyles)

function(addStyleFile 
		#path to the style file 
		filePath
		)

	#read the file
	file(READ ${filePath} rawFileData)

	#convert the read file to a list of lines
	string(REGEX REPLACE "[\n\r]+" ";" lines ${rawFileData})

	#iterate through each line. Ignore each \ProvidesPackage command and parse and
	#remove the lines that begin with \usepackage[...]{...} (storing the parsed
	# using addLatexPackage. The remaining lines will get added directly to the
	# generated style file
	#message("File Len: ${lines}")
	foreach(line ${lines})
		#ignore commented lines
		string(REGEX MATCH "^%" commentedLine ${line})
		if(commentedLine STREQUAL "")
			# test for 'ProvidesPackage'
			string(FIND ${line} "\\ProvidesPackage" providesPackageMatch)
			if(${providesPackageMatch} EQUAL -1)
				# test for use package
				string(FIND ${line} "\\usepackage" usepackageMatch) 
				if(NOT ${usepackageMatch} EQUAL -1)
					message(STATUS "usepackage found: ${line}")
					# parse the usepackage data
					parseUsePackage("${line}" pkgName pkgOps)
					addLatexPackage("${pkgName}" "${pkgOps}")
				else(NOT ${usepackageMatch} EQUAL -1)
					message(STATUS "Extra Line Found: ${line}")
					# otherwise add the line to the _customStyleCode for the project
					strAppend(${PROJECT_NAME}_customStyleCode "\n${line}")
				endif(NOT ${usepackageMatch} EQUAL -1)
			else(${providesPackageMatch} EQUAL -1)
				#message(STATUS "Provides Package found: ${line}")
			endif(${providesPackageMatch} EQUAL -1)
		else(commentedLine STREQUAL "")
			#message(STATUS "commented line found: ${line}")
		endif(commentedLine STREQUAL "")
	endforeach(line)

	#export the extra lines
	set(${PROJECT_NAME}_customStyleCode 
		"${${PROJECT_NAME}_customStyleCode}"
		CACHE INTERNAL "extra style lines"
		)

endfunction(addStyleFile)

function(GenerateStyleFile)

	#add a generation meta data
	strAppend(${PROJECT_NAME}_packageContent "\n")
	strAppend(${PROJECT_NAME}_packageContent 
		"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
	strAppend(${PROJECT_NAME}_packageContent 
		"\n% AUTO-GENERATED BY CMAKE. DO NOT REMOVE OR MODIFY.")
	strAppend(${PROJECT_NAME}
		"\n%THIS FILE WILL BE OVERWRITEN BY SUCCESSIVE RUNS BY CMAKE.")
	#add the time stamp info
	strAppend(${PROJECT_NAME}_packageContent "\n% Generated on UTC: ")
	string(TIMESTAMP timestamp UTC)
	strAppend(${PROJECT_NAME}_packageContent ${timestamp})
	strAppend(${PROJECT_NAME}_packageContent 
		"\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n")

	set(${PROJECT_NAME}_packageContent "\\ProvidesPackage{${PROJECT_NAME}}\n")

	# go through all of our packages and generate the LaTeX code for the package
	foreach(p ${${PROJECT_NAME}_packages})
		#start the option list
		strAppend(${PROJECT_NAME}_packageContent "\\usepackage")

		#add the options to package option list
		foreach(opt ${${PROJECT_NAME}_pkg_${p}})
			strAppend(${PROJECT_NAME}_optionList "${opt},")
		endforeach(opt)

		#remove the trailing comma from the list of options
		if(${PROJECT_NAME}_pkg_${p})
			removeLastChar(${PROJECT_NAME}_optionList)
			strAppend(${PROJECT_NAME}_packageContent "[${${PROJECT_NAME}_optionList}]")
		endif(${PROJECT_NAME}_pkg_${p})

		strAppend(${PROJECT_NAME}_packageContent "{${p}}\n")
	endforeach(p)

	#append the custom styling code
	strAppend(${PROJECT_NAME}_packageContent "\n${${PROJECT_NAME}_customStyleCode}")
	message(STATUS ${${PROJECT_NAME}_packageContent})

	#write to the newly generated style file
	set(${PROJECT_NAME}_genStyPath "${CMAKE_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}.sty")
	#file(WRITE ${${PROJECT_NAME}_genStyPath} "${${PROJECT_NAME}_packageContent}")
	message(STATUS "Generated style file: ${${PROJECT_NAME}_genStyPath}")

endfunction(GenerateStyleFile)

############################ End PackageManager ############################
