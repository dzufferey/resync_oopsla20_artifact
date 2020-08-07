set xlabel "# Replicas" offset 0,0.5
set ylabel "Latency (ms)" offset 1.5,0
set terminal svg size 400,300 fname "serif,14"
set output "latency_2pc.svg"
set xrange [2:10]
set yrange [0:4.5]
set tics font "serif,12"
set key font "serif,12"
set key autotitle columnhead
plot "latency_2pc.dat" using 1:2 with lp, \
     "latency_2pc.dat" using 1:3 with lp
exit
