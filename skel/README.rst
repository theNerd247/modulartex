project
-------

Directory Structure
===================

<project_name>
  Files related for a specific project

<project_name>/tex/
  LaTeX files for the specific project.

<project_name>/img/

<project_name>/sty/
  Sty files for the entire latex project.

<project_name>/main.tex
  The main LaTeX file for producing the main document for this project.
  This file should not contain actuall document content but should
  instead use the subfiles package LaTeX package for including the
  content. This allows other projects to have access to the content of
  <project_name>.

cmake/LaTeXBuild.cmake
  The core of modulartex. Include this file in the main CMakeLists.txt file to
  use modulartex.

Building
========

Use the following steps to build the project called <project_name>.

::

  mkdir build
  cd build
  cmake ..
  cd <project_name>
  make

The output for the pdf will be produced in build/<project_name>
