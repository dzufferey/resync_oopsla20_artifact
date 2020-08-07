set xlabel "# Replicas" offset 0,0.5
set ylabel "Throughput (MB/s)" offset 1.5,0
set terminal svg size 400,300 fname "serif,14"
set output "bft.svg"
set xrange [3.5:9.5]
set yrange [0:20]
set tics font "serif,12"
set key font "serif,12"
set key autotitle columnhead
plot "bft.dat" using 1:2 with lp, \
     "bft.dat" using 1:3 with lp
exit
