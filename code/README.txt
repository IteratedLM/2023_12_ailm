This is the code we used to produce the figures in 

An iterated learning model of language change that mixes supervised
and unsupervised learning (2024)

Jack Bunyan, Seth Bullock, Conor Houghton

It should be possible to recreate any simulated data here, often the
actual simulated data used in the figures is also included

If there are any questions or problems contact me at
conor.houghton@bristol.ac.uk

All the code is in the public domain and comes with the usual caveats,
like most scientific code it was only written to run once and,
although I am sure I could write stylish code, I didn't on this
occassion. Some day I will learn how to comment code.

The number of the folders is wrong, it refers to the original version
of the paper. In that version the figures for the oILM and ssILM were
different, one of the referees suggested reorganizing these so they
appear in the same figures. I didn't reorganize the folder since there
is a strong chance that everything would be messed up beyond all
repair. Instead there is a translation here.

FIGURE 1-3: these are introduction figures, there is no code with them

FIGURE 5

"The semi-supervised ILM evolves a stable, expressive, compositional language." 

ABC - this is the old FIGURE 4 ABC and are in fig4abc
DEF - old FIGURE 7 ABC
GHI - old FIGURE 7 DEF
so D-I are all in the folder fig789 where they are called fig7abc and fig7def.
it is now labelled "fig:ailmGood"

FIGURE 6

"For larger languages A needs to be different from, and larger than, B"

FIGURE 6ABC 6D and 6EFG
again, these are in fig789, mv the relevant ailm.csv file in from the results_fig8abc and results_fig8efg; same for 6d but using the longPlot.jl programme

FIGURE 7

"Even larger languages do not become stable unless the hidden layer is made larger"

used to be figure 9 use the results_fig9abc and results_fig9def ailm.csv files

FIGURE 8

"The required bottleneck size increases linearly for the semi-supervised ILM."

this is what used to be FIGURE 10 and is in fig10. The old figure
didn't have the pink line in the "b" panel, this is what
plot_with_sd.jl does, in the end it doesn't involve an sd of course.
In the change to EPS the pink had to be changed to magenta.

FIGURE 9

"XCS languages are easier to learn."

used to be FIGURE 11

FIGURE 10

"Exploring optimal training set size"

This used to FIGURE S1
results_n10 vr_unsame -> GHI
whereas the folder results has the data for ABC and DEF


FIGURE 11

"The obverter ILM is sensitive to bottleneck size"

This used to be FIGURE 4DEF 


FIGURE 12

"Performance of the ILM when there is no bottleneck."

FIGURE 12DEF:
This is also in fig4abc for some reason

FIGURE 12ABC:
This uses the code in fig789, just copy ailm.csv from the relevant results folder - results_b256

FIGURE S6:
This used to be figure 5 and is in fig5 and, like in FIGURE 8, use plot_with_sd.jl

