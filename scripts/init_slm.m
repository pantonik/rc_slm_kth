% Initialisation script for the Meadowlark SLM
% Inspired by BNSPCIe16MatlabSDK_GUI M-file by Boulder Nonlinear Systems, Inc 
% Written by P. Antonik, Jan 2018

n_boards = BNS_OpenSLMs();                                                    % open communication with SLM
BNS_LoadLUTFile(1, 'C:\PCIe16MatlabSDK\LUT_Files\slm3691_at532_P16.LUT');     % load LUT to SLM
optimization_data = libpointer('uint8Ptr', zeros(524288,1));                  % initialise cal memory
BNS_ReadTIFF('C:\PCIe16MatlabSDK\Image_Files\White.tiff', optimization_data); % read cal image from TIFF
BNS_WriteCal(optimization_data);                                              % load cal image to SLM
