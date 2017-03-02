#!/bin/bash
# This script generates the figures for lesson 5

make_gif()
{
for f in tmp/frames_*.tif; do convert $f ${f/tif/gif}; done
gifsicle --delay $2 --colors 256 --loop tmp/frames*.gif > tmp/$1
convert -layers Optimize tmp/$1 $1
rm tmp/frames_*if
}

make -C ../.. bin/HalideTraceViz

rm -rf tmp
mkdir -p tmp

# Grab a trace
HL_TRACE=3 HL_TRACE_FILE=$(pwd)/tmp/trace.bin make -C ../.. tutorial_lesson_18_parallel_associative_reductions
ls tmp/trace.bin

# Serial histogram
cat tmp/trace.bin | ../../bin/HalideTraceViz -s 230 280 -t 1 -d 10000 -h 10 \
	-f 'input' 0 256 -1 0 20 1 10 32 1 0 0 1 -l 'input' Input 10 32 1 \
	-f 'hist_serial' 0 25 -1 0 20 1 10 230 1 0 -l 'hist_serial' 'Serial Histogram' 10 230 1 \
	 |  avconv -f rawvideo -pix_fmt bgr32 -s 230x280 -i /dev/stdin tmp/frames_%04d.tif

make_gif lesson_18_hist_serial.gif 5

# Manually-factored parallel histogram
cat tmp/trace.bin | ../../bin/HalideTraceViz -s 460 300 -t 1 -d 10000 -h 10 \
	-f 'merge_par_manual:input' 0 256 -1 0 20 1 20 32 1 0 0 1 -l 'merge_par_manual:input' Input 20 32 1 \
	-f 'intm_par_manual' 0 4 -1 0 20 1 230 32 1 0 0 1 -l 'intm_par_manual' 'Partial Histogram' 230 32 1  \
	-f 'merge_par_manual' 0 10 -1 0 20 1 230 230 1 0 -l 'merge_par_manual' Histogram 230 230 1  \
	 |  avconv -f rawvideo -pix_fmt bgr32 -s 460x300 -i /dev/stdin tmp/frames_%04d.tif

make_gif lesson_18_hist_manual_par.gif 5

# Parallelize the outer dimension using rfactor
cat tmp/trace.bin | ../../bin/HalideTraceViz -s 460 300 -t 1 -d 10000 -h 10 \
	-f 'hist_rfactor_par:input' 0 256 -1 0 20 1 20 32 1 0 0 1 -l 'hist_rfactor_par:input' Input 20 32 1 \
	-f 'hist_rfactor_par_intm' 0 4 -1 0 20 1 230 32 1 0 0 1 -l 'hist_rfactor_par_intm' 'Partial Histogram' 230 32 1  \
	-f 'hist_rfactor_par' 0 10 -1 0 20 1 230 230 1 0 -l 'hist_rfactor_par' Histogram 230 230 1  \
	 |  avconv -f rawvideo -pix_fmt bgr32 -s 460x300 -i /dev/stdin tmp/frames_%04d.tif

make_gif lesson_18_hist_rfactor_par.gif 5

# Vectorize the inner dimension using rfactor
cat tmp/trace.bin | ../../bin/HalideTraceViz -s 460 300 -t 1 -d 10000 -h 10 \
	-f 'hist_rfactor_vec:input' 0 256 -1 0 20 1 20 32 1 0 0 1 -l 'hist_rfactor_vec:input' Input 20 32 1 \
	-f 'hist_rfactor_vec_intm' 0 4 -1 0 20 1 230 32 1 0 0 1 -l 'hist_rfactor_vec_intm' 'Partial Histogram' 230 32 1  \
	-f 'hist_rfactor_vec' 0 10 -1 0 20 1 230 230 1 0 -l 'hist_rfactor_vec' Histogram 230 230 1  \
	 |  avconv -f rawvideo -pix_fmt bgr32 -s 460x300 -i /dev/stdin tmp/frames_%04d.tif

make_gif lesson_18_hist_rfactor_vec.gif 5

# Tile histogram using rfactor
cat tmp/trace.bin | ../../bin/HalideTraceViz -s 650 200 -t 1 -d 10000 -h 10 \
	-f 'hist_rfactor_tile:input' 0 256 -1 0 20 1 20 32 1 0 0 1 -l 'hist_rfactor_tile:input' Input 20 32 1 \
	-f 'hist_rfactor_tile_intm' 0 4 -1 0 20 1 230 32 1 0 11 0 0 2 -l 'hist_rfactor_tile_intm' 'Partial Histogram' 230 32 1  \
	-f 'hist_rfactor_tile' 0 10 -1 0 20 1 230 150 1 0 -l 'hist_rfactor_tile' Histogram 230 150 1  \
	 |  avconv -f rawvideo -pix_fmt bgr32 -s 650x200 -i /dev/stdin tmp/frames_%04d.tif

make_gif lesson_18_hist_rfactor_tile.gif 5

rm -rf tmp
