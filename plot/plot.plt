# set terminal pngcairo transparent enhanced font "arial,10" fontscale 1.0 size 800, 640
# set output 'pm3d.png'
set border 4095 front lt black linewidth 1.000 dashtype solid
set sample 15, 15
set isosample 20, 20
unset surface
set style data lines
set xyplane relative 0
set title "Eggholder function"
set xlabel "x"
set xrange [-512.0000 : +512.0000] noreverse nowriteback
set ylabel "y"
set yrange [-512.0000 : +512.0000] noreverse nowriteback
set zrange [-960.0000 : +960.0000] noreverse nowriteback
set cblabel "coloutr gradient"
set samples 2000
set palette model RGB
set palette defined 
set pm3d
splot -(y+47)*sin(sqrt(abs(y+x/2+47)))-x*sin(sqrt(abs(x-(y+47))))