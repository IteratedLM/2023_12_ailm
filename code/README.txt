

fig4 A-C: fig_2023_12_10 X
fig4 D-F: fig_2023_12_26 X
fig5: fig_2023_12_25 X
fig 6 A-C: fig_2023_12_27 X
fig 6 D-F: fig_2023_12_27 X
fig 8 A-C: fig_2023_12_27 X
fig 8 D-F: fig_2023_12_27 X
fig 9: fig_2024_01_04 X
fig 10 A-C: fig_2024_01_07 X
fig 10 D-F: fig_2024_01_09 X
fig 10 G-I: fig_2024_01_09 X
fig S1: fig_2024_02_12

fig_2023_12_09: for the ailm with n=8 this calculates the performance
after two different generation lengths as a function of the number of
signals used when learning as an autoencoder. The output files look like
ailm_*_va.* and in the paper are labelled fig:ailm_va
2023-12-10 uploaded based on 25 trials - there is still some confusion
here with some files mislabeld, redo it.
2023-01-02 this is now moot since I am changing the training schedule

fig4 A-C

fig_2023_12_10: for the oilm with n=8 this calculates the performance
as a function of generation. The output files look like oilm_*.png and
form the first row of the figure labelled fig:oilmGood
2023-12-11 uploaded based on 25 trials
2024-02-10 uploaded using same data but tighter layout and e->x

fig 5

fig_2023_12_25: for the oilm with n in 6...12 calculated the number of
generations until all three performance measures exceed 0.95 for
difference sizes of the bottleneck, average the generation count over
25 trials and find the best bottleneck size. This is the figure
fig:oilmBottleneckSize and the files are oilm_best_*.png
2023_12_26 uploaded based on 25 trials - size is wrong needs fixing - fixed
2024_02_11 uploaded with new tighter layout

fig4 D-F

fig_2023_12_26: for n=8 oilm calculates the performance as a function
of bottleneck size, for 40 and 15 generations. It is oilm_*_vb.png and
forms the second row of the figure labelled fig:oilmGood
2023-12-26 uploaded based on 25 trials
2024-02-10 uploaded using same data but tighter layout and e->x
2024-02-11 there was a difference between here and the paper as to
what the generation numbers where and I wasn't sure which was correct
so I ran again and 40/15 is correct, also the end of the 150 was being
clipped so increased the right padding

fig_2023_12_27: for n=8 ailm calculates the performance as a function
of generation. There are three different sets of parameters for the
three rows, but these are all done in the same programme with
comments. This is labelled fig:ailmGood and the file names look like
ailm_n1_n2 where n1 is the bottlenect size and the n2 is the
autoencoder size, if n1=n2 and they use same=true then there is just one number.
2023-12-27 uploaded ailm_100 with 25 trials fig6 A-C
2023-12-27 uploaded ailm_50 with 25 trials  fig6 D-F
2023-12-27 uploaded ailm_100_100 with 25 trials  fig7 A-C
need to do all this again with generationN=50! - fixed 2023-12-28
2024-02-02 this is all moot now I am changing the training schedule
2024-02-10 updated ailm_100 using the new training schedule and reuploded all four

fig_2023_12_28: first attempt at the ailm n-sweep; found it difficult
to fix the number of epochs in a sensible way. There is also a memory
leak even though almost every variable is now local. 2024-02-02 I have
now changed the training schedule so this is no longer relevant.

fig_2024_01_01: looking at oilm learning, so plotting loss as a
function of epoch for different generations. This is not going to be
used since the ailm gives a similar result and this is 2024_01_06.

test_2024_01_01: looking into changing the ailm training schedule.

fig_2024_01_02: another attempt at the ailm n-sweep, for now I am just
going to go as far as n=12 so it is easier to compare to the oilm
calculation - superceded by 2024_01_04

test_2024_01_03: a gpu version of the fig_2023_12_10 code to see if it
runs on the supercomputer

fig 9 A/B

fig_2024_01_04: this is a version of fig_2023_12_28 that should run on
the supercomputer. plot.jl has all sorts of stuff while I try to work
out how to deal with picking "best" when a few stray runs are reaching
generationMax. plot_n14.jl considers only the n\in 8:14.
2024-01-07 uploaded with 25 trials, it is fig9
2024-01-08 uploaded again but only for n in 8:14, again with 25 trials.
2024-02-11 uploaded with tighter layout

fig 10

fig_2024_01_06: this is the same as fig_2024_01_01 but for the ailm:
filenames like ailm_epochX where X is D, E or A for decoder, encoder
or audoencoder.
2024-01-06 - uploaded with 25 trials, it is fig10

fig_2024_01_07: runs the n=16 ailm for 120 generations for plotting e,
c and s against generation. File names like ailm_n16.
2024_01_07 - uploaded with 25 trials; may need to redo with a
different bottle neck number. At the moment this is chosen using the
best value from fig_2024_01_04 but this includes the unresolved runs
so might need to redo.
2024_01_09 - run again with bottle 120

fig_2024_01_08: here I ran the ailm at n=16 for 100 trials, the idea
is to plot the distribution of e, c and s values.

fig_2024_01_09: I run the ailm with n=20 and try different sets of
parameters to see if the expressivity can be improved. There are lots
of these as I trawl through different ideas but what works is making
the hidden layer wider. Here I use n=20 but a hidden layer of 30, I
use 30 epochs and the number of autoencoder presentation 16 times the
supervised presentations. I also do the standard version, this doesn't
have wider in the filenames, here n=20, 20 epochs and 8 autoencoder
presentations.
2024-01-10 uploaded with "n20_wider" and "n20"

fig_2024_02_11: The ailm with sweeps across bottleneck and autoencoder
sizes, run on BC
2024-02-13: uploaded 


_________________________________

figures to do:

1_ ailm performance as a function of training schedule
