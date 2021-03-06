This folder contains Matlab scripts used to control the photonic experimental setup presented in our paper "Human action recognition with a large-scale brain-inspired photonic computer", written by Piotr Antonik, Nicolas Marsal, Daniel Brunner, and Damien Rontani, and published in Nature Machine Intelligence.

All scripts written by Piotr Antonik.

Files:
* init_exp.m - initialisation script for the experimental setup, to be executed once after powering up the hardware
    * init_cam.m - initialisation script for the camera
    * init_slm.m - initialisation script for the SLM
* main.m - main script file, loads the KTH database, performs the measurements with different hyperparameters, evaluates the RC performance and returns a table for comparison
    * write_mx.m - function for writing data into the SLM device
    
The "kth_hog8x8_pca2k_labels.mat" database, containing HOG features extracted from the KTH video frames, and loaded by the "main.m" script, can be downloaded here: https://osf.io/axtd5/?view_only=49aee5e79e8744c29e598e19bc9368da (file: kth_hog8x8_pca2k_labels.mat).

The scripts are designed to operate specifically with the hardware described in the paper above, and have not been tested elsewhere. They are shared "as is" and the authors bear no responsibility for the outcome in any other configuration than the one described in the paper.

If you found these scripts useful and plan to use it in full or in part, please consider:
* citing our paper
* letting us know - appreciation is always welcome :-)
