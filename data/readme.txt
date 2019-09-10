This folder contains the experimental data and scripts required to reproduce the figures and tables presented in our paper "Human action recognition with a large-scale brain-inspired photonic computer", written by Piotr Antonik, Nicolas Marsal, Daniel Brunner, and Damien Rontani, and published in Nature Machine Intelligence.

All scripts written by Piotr Antonik.

Files:
* fig3.gs - gnuplot script used to create Fig. 3 from the paper
* results_all.data - experimental and numerical results required to draw Fig. 3
* analyse_exp.m - Matlab script used to analyse experimental data
* conf_matrix.m - Matlab function designed to compute a confusion matrix

A recording from a single experimental run typically takes several Gb of data and therefore can not be stored on GitHub. A full recording of one of the best experimental runs can be downloaded here: FIXME

To reproduce the Tab. 2 (experiment), one needs to:
1. Load the .mat file into Matlab workspace (this may take some time, and a few unimportant warnings may pop up)
2. Launch the analyse_exp.m script in the same folder
3. Open the conf_matrix_test variable in Matlab workspace
