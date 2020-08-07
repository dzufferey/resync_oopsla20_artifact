set xlabel "# Replicas" offset 0,0.5
set ylabel "Throughput (MB/s)" offset 1.5,0
set terminal svg size 400,300 fname "serif,14"
set output "lp3_gl_ed_z.svg"
set xrange [2.5:9.5]
set yrange [0:40]
set tics font "serif,12"
set key font "serif,12"
set key autotitle columnhead
plot "lp3_gl_ed_z.dat" using 1:2 with line, \
     "lp3_gl_ed_z.dat" using 1:3 with line, \
     "lp3_gl_ed_z.dat" using 1:4 with line, \
     "lp3_gl_ed_z.dat" using 1:5 with line, \
     "lp3_gl_ed_z.dat" using 1:6 with line, \
     "lp3_gl_ed_z.dat" using 1:7 with line
exit
