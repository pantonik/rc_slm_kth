% Initialisation script for the SLM Reservoir Computer setup
% Run ONCE after powering on the experiment (PC, camera, SLM)
% Written by Piotr Antonik, Jan 2018

% Folder PCIe16MatlabSDK contains the SDK for the Meadowlark XY Phase P512 – 0532
% These files are proprietary and can not be shared freely

clear; clc;
addpath(genpath('C:\PCIe16MatlabSDK\'));
addpath(genpath('.'));

init_slm;
init_cam;

src.ExposureTime = 155000;
