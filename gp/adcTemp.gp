set terminal latex
set output './report/figures/adcTempGraph.tex'
set xlabel 'ADC Value'
set xrange [0:950]
set ylabel '\rotatebox{90}{Temperature ($^{\circ}\mathrm{C}$)}' 
set yrange [0:100]
set pointsize 2.0

ptLabel(x,y) = sprintf("(%i,%i)",x,y)
plot './RTDataPoints.dat' notitle with linespoints pt 3, \
	'./RTDataPoints.dat' using 1:2:(ptLabel($1,$2)) notitle with labels offset -6,0

