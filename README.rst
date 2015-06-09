project
-------

Directory Structure
===================

./project_name>
  LaTeX files for a specific project.

<project_name>/tex/
  LaTeX files for the specific project.

<project_name>/img/
  The images, TikZ files, etc. for the given project

<project_name>/sty/
  Sty files for the latex project

<project_name>/main.tex
  The main LaTeX file for producing the main document for this project.
  This file should not contain actuall document content but should
  instead use the subfiles package LaTeX package for including the
  content. This allows other projects to have access to the content of
  <project_name>.

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
