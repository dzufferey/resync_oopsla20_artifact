set xlabel "# Replicas" offset 0,0.5
set ylabel "Throughput (req/ms)" offset 1.5,0
set terminal svg size 400,300 fname "serif,14"
set output "progress_lv.svg"
set xrange [2.5:9.5]
set yrange [0:20]
set tics font "serif,12"
set key font "serif,12"
set key autotitle columnhead font "serif,11"
plot "progress_lv.dat" using 1:2 with lp, \
     "progress_lv.dat" using 1:3 with lp, \
     "progress_lv.dat" using 1:4 with lp, \
     "progress_lv.dat" using 1:5 with lp, \
     "progress_lv.dat" using 1:6 with lp, \
     "progress_lv.dat" using 1:7 with lp
exit
