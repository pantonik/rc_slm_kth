% Initialisation script for the Allied Vision Mako U-130B camera
% Written by Piotr Antonik, Jan 2018

cam = videoinput('gentl', 1, 'Mono8');
src = getselectedsource(cam);

triggerconfig(cam, 'manual'); % configure camera trigger mode.

src.BlackLevel = 0;
src.CorrectionMode = 'Off';
src.ExposureTime = 1000;
src.Gain = 0;
src.Gamma = 1;
