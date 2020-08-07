set xlabel "Timeout (ms)" offset 0,0.5
set ylabel "Throughput (req/ms)" offset 1.5,0
set terminal svg size 400,300 fname "serif,14"
set output "timeout.svg"
set xrange [0.8:60]
set yrange [0:15]
set logscale x
set tics font "serif,12"
set key font "serif,12"
#set xtics rotate by -45
set key autotitle columnhead
plot "timeout.dat" using 1:2 with lp, \
     "timeout.dat" using 1:3 with lp, \
     "timeout.dat" using 1:4 with lp, \
     "timeout.dat" using 1:5 with lp
exit
