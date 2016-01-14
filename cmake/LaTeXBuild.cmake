cmake_minimum_required(VERSION 2.6)
cmake_policy(SET CMP0011 NEW) #acknowledge policy push/pop

include(FindLATEX)

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

#adds an item to the list and removes the duplicates
function(listUpdate
		# the list to update
		lst
		# the item to append to the list
		item
		)

	list(APPEND "${lst}" "${item}")
	list(REMOVE_DUPLICATES "${lst}")
	set("${lst}" "${${lst}}" PARENT_SCOPE)
endfunction(listUpdate)
################################ End Utility ################################

################################ addStyleFile ################################

#add a style file to be merged with the autogenerated style path
function(addStyleFile
		# the file to add to the 
		styleFilePath
		)

	# check if file exists
	#add the file to the list of files to be processed
	if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${styleFilePath}")
		listUpdate(${PROJECT_NAME}_styleFileList 
			"${CMAKE_CURRENT_SOURCE_DIR}/${styleFilePath}"
			)
		set(${PROJECT_NAME}_styleFileList 
			${${PROJECT_NAME}_styleFileList} 
			CACHE INTERNAL "the projects style files to process"
			)
	else(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${styleFilePath}")
		message(FATAL_ERROR "Stylefile does not exist: 
			${CMAKE_CURRENT_SOURCE_DIR}/${styleFilePath}")
	endif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${styleFilePath}")
endfunction(addStyleFile)

############################## End addStyleFile ##############################

############################# SetupLaTexBuildEnv #############################
function(SetupLaTexBuildEnv 
		# the main tex file
		mainTexFile 
		# the file search paths this project provides
		includeList 
		# the style files this project provides
		styleFiles
		# projects this project depends on
		subProjects
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
	foreach(dir ${includeList})
		list(APPEND ${PROJECT_NAME}_includeDirs ${CMAKE_CURRENT_SOURCE_DIR}/${dir})
	endforeach(dir)

	#clear the cache for generating the style files
	#remove the customCode latex cache to prevent duplicates
	set(${PROJECT_NAME}_customStyleCode "" CACHE INTERNAL "extra style code")
	foreach(p ${${PROJECT_NAME}_packages})
		set(${PROJECT_NAME}_pkg_${p} "" CACHE INTERNAL "")
	endforeach(p)
	set(${PROJECT_NAME}_packages "" CACHE INTERNAL "")


	#add the style files to the current list
	foreach(f ${styleFiles})
		addStyleFile(${f})
	endforeach(f)

	# process the subprojects
	foreach(p ${subProjects})
		#add the include directories of the subprojects 
		list(APPEND ${PROJECT_NAME}_includeDirs "${${p}_includeDirs}")

		#add the subproject style files  to the current list of style files to
		#process
		listUpdate(${PROJECT_NAME}_styleFileList "${${p}_styleFileList}")
	endforeach(p)

	#generate the project style file
	foreach(f ${${PROJECT_NAME}_styleFileList})
		parseStyleFile(${f})
	endforeach(f)
	GenerateStyleFile()

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

	add_custom_command(
		OUTPUT "${CMAKE_BINARY_DIR}/${PROJECT_NAME}.pdf"
		COMMAND
		"TEXINPUTS=${GLOBAL_TEXINPUTS}:${${PROJECT_NAME}_texInputs}" # set the TEXINPUTS
		${PDFLATEX_COMPILER} # run pdflatex
		${PDF_COMPILER_OPTS}
		"${${PROJECT_NAME}_mainTexFilePath}"
		DEPENDS "${${PROJECT_NAME}_mainTexFilePath}"
		COMMENT "pdflatex"
		)

	add_custom_target("build_${PROJECT_NAME}" 
		ALL 
		DEPENDS "${CMAKE_BINARY_DIR}/${PROJECT_NAME}.pdf"
		)

	set_target_properties("build_${PROJECT_NAME}"
		PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
		)
endfunction(SetupLaTexBuildEnv)
########################### End SetupLaTexBuildEnv ###########################

############################## StylefileGenerator ##############################
# NOTE DO NOT CALL THESE METHODS DIRECTLY THEY ARE CALLED FROM SetupLaTexBuildEnv

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
	listUpdate(${PROJECT_NAME}_packages ${packageName})
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

# add a stylefile to merge into the autgenerated style file for the given
# project
function(parseStyleFile 
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
	math(EXPR lineNum 1)
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
					# parse the usepackage data
					parseUsePackage("${line}" pkgName pkgOps)
					if(NOT pkgName)
						message(WARNING "Could not parse in file ${filePath}:${lineNum}: ${line}")
					endif(NOT pkgName)
					addLatexPackage("${pkgName}" "${pkgOps}")
				else(NOT ${usepackageMatch} EQUAL -1)
					# otherwise add the line to the _customStyleCode for the project
					#replace the newline characters so that the cache doesn't yell at us
					strAppend(${PROJECT_NAME}_customStyleCode "_,_${line}")
				endif(NOT ${usepackageMatch} EQUAL -1)
			else(${providesPackageMatch} EQUAL -1)
				#message(STATUS "Provides Package found: ${line}")
			endif(${providesPackageMatch} EQUAL -1)
		else(commentedLine STREQUAL "")
			#message(STATUS "commented line found: ${line}")
		endif(commentedLine STREQUAL "")

		#increment the line number count
		math(EXPR lineNum "${lineNum}+1")
	endforeach(line)

	#export the extra lines
	set(${PROJECT_NAME}_customStyleCode 
		"${${PROJECT_NAME}_customStyleCode}"
		CACHE INTERNAL "extra style lines"
		)
endfunction(parseStyleFile)

function(GenerateStyleFile)
	#add a generation meta data
	set(${PROJECT_NAME}_packageContent "\\ProvidesPackage{${PROJECT_NAME}}\n")
	strAppend(${PROJECT_NAME}_packageContent "\n")
	strAppend(${PROJECT_NAME}_packageContent 
		"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
	strAppend(${PROJECT_NAME}_packageContent 
		"\n% AUTO-GENERATED BY CMAKE. DO NOT REMOVE OR MODIFY.")
	strAppend(${PROJECT_NAME}_packageContent
		"\n% THIS FILE WILL BE OVERWRITEN BY SUCCESSIVE CMAKE CALLS.")
	#add the time stamp info
	strAppend(${PROJECT_NAME}_packageContent "\n% Generated on UTC: ")
	string(TIMESTAMP timestamp UTC)
	strAppend(${PROJECT_NAME}_packageContent ${timestamp})
	strAppend(${PROJECT_NAME}_packageContent 
		"\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n")

	# go through all of our packages and generate the LaTeX code for the package
	foreach(p ${${PROJECT_NAME}_packages})
		#start the option list
		strAppend(${PROJECT_NAME}_packageContent "\\usepackage")

		#add the options to package option list
		set(optionList "")
		foreach(opt ${${PROJECT_NAME}_pkg_${p}})
			strAppend(optionList "${opt},")
		endforeach(opt)

		#remove the trailing comma from the list of options
		if(${PROJECT_NAME}_pkg_${p})
			removeLastChar(optionList)
			strAppend(${PROJECT_NAME}_packageContent "[${optionList}]")
		endif(${PROJECT_NAME}_pkg_${p})

		strAppend(${PROJECT_NAME}_packageContent "{${p}}\n")
	endforeach(p)

	#append the custom styling code
	#add the newlines back into the custom style code
	string(REGEX REPLACE "_,_" "\n" customCode "${${PROJECT_NAME}_customStyleCode}")
	strAppend(${PROJECT_NAME}_packageContent "${customCode}")

	#write to the newly generated style file
	set(${PROJECT_NAME}_genStyPath "${CMAKE_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}.sty")
	file(WRITE ${${PROJECT_NAME}_genStyPath} "${${PROJECT_NAME}_packageContent}")
	message(STATUS "Generated style file: ${${PROJECT_NAME}_genStyPath}")
endfunction(GenerateStyleFile)

############################ End PackageManager ############################
