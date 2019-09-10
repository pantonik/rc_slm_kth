# Script written by P. Antonik

set terminal epslatex size 10cm, 7.5cm standalone
set output "results2.tex"
set style histogram errorbars gap 1 #errorbars #{gap <gapsize>} {<linewidth>}
set style data histograms
set style fill solid 1.0 border -1
set boxwidth 1.00 absolute

set xlabel 'Reservoir size $N$'
set xtics nomirror
set xrange [-0.5:5.5]
  
set ylabel 'Score'
set ytics nomirror
set yrange [450:600]

set key right top

set style line 31 lc rgb "#3264C8" lt 1 lw 1 pt 4 ps 2.0
set style line 32 lc rgb "#FF0000" lt 1 lw 1 pt 3 ps 2.0

# plot
plot "results_all.data" using 2:3:xtic(1) title "Simulations" ls 31 ,\
     "" using 4:5 title "Experiments" ls 32
