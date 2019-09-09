% Control script for the SLM Reservoir Computer setup
% Offline/batch learning
% KTH database
% Classification based on HOG features from frames
% 9k features reduced to 2k with PCA
% Written by Piotr Antonik, Jul 2018

% References: dalal2005histograms, liu2009recognizing, schuldt2004recognizing

% NOTE: run init_exp.m after powering on the experiment

rng(1);

%% Load KTH features (HOG) & labels

load('db/kth_hog8x8_pca2k_labels.mat');
fprintf('Database loaded.\n');
kth_hog_labels = kth_hog_pca2k_labels;
clear kth_hog_pca2k_labels

% duplicate one missing boxing sequence (person 22, cel 507)
kth_hog_labels = [kth_hog_labels(:,1:507) kth_hog_labels(:,507) kth_hog_labels(:,508:end)];

% add cell indexes for ease of tracking
for i_cell=1:size(kth_hog_labels,2)
    kth_hog_labels{3, i_cell} = i_cell * ones(1, size(kth_hog_labels{2, i_cell}, 2));
end

% create inputs & targets from data cells
data_train     = [kth_hog_labels(:, 1:4:end) kth_hog_labels(:, 2:4:end) kth_hog_labels(:, 3:4:end)];
data_train     = data_train(:, randperm(size(data_train,2)));
features_train = [data_train{1, :}];
labels_train   = [data_train{2, :}];
indexes_train  = [data_train{3, :}];

data_test     = kth_hog_labels(:, 4:4:end);
data_test     = data_test(:, randperm(size(data_test,2)));
features_test = [data_test{1, :}];
labels_test   = [data_test{2, :}];
indexes_test  = [data_test{3, :}];

inputs  = [features_train features_test];    % combine train & test data
targets = [labels_train labels_test];
indexes = [indexes_train indexes_test];

size_input = size(inputs, 1);

targets_bin = zeros(6, length(targets));
for i=1:6
    targets_bin(i, :) = targets==i;
end

clear data_train data_test kth_hog_labels i


%% Constants

% slm
len_slm     = 512;
len_slm_roi = 384;

% reservoir
len_res     = 128;
size_res    = len_res^2;
len_train   = size(features_train, 2);
len_test    = size(features_test, 2);
len_inputs  = len_train + len_test;
reg_term    = 0;

% cam settings for 128x128 reservoir
x0              = 288; % upper-left corner of the camera roi
y0              = 125;
cam_nrn_size_x  = 6;
cam_nrn_size_y  = 6;

roi_len_x       = len_res*cam_nrn_size_x;
roi_len_y       = len_res*cam_nrn_size_y;

%% Generate input mask

% mask         = 2*rand(size_res, size_img) - 1;
mask_orig = 2*rand(size_res, size_input) - 1;
rand_sgn  = 2*randi([1,2], size_res)-3;

%% Scanned parameters
[scan_params, scan_list, n_runs] = def_scan_params_kth_hog();

%% Run reservoir

res_err_train = zeros(n_runs, 1);
res_err_test  = zeros(n_runs, 1);
res_rcouts    = zeros(n_runs, len_inputs);

start(cam)

for i_run=1:n_runs
    tic;

    % set current parameters, print status
    gain_in  = scan_list(1, i_run);
    gain_fdb = scan_list(2, i_run); 
    gain_inter = scan_list(3, i_run);
    w_density  = scan_list(4, i_run);
    
    fprintf('Run %3.0f/%d: ', i_run, n_runs);
    fprintf('in: %.3f, ', gain_in);
    fprintf('fdb: %.3f, ', gain_fdb);
    fprintf('int: %.3f, ', gain_inter);
    fprintf('w_d: %.3f, ', w_density);

    img_slm     = uint8(zeros(len_slm));
    res_history = [zeros(size_res, len_inputs); ones(1, len_inputs)];

    rng(2);
    w = sprand(size_res, size_res, w_density) .* rand_sgn * gain_inter;
    w(1:size_res+1:end) = gain_fdb * ones(size_res, 1);
    mask = gain_in * mask_orig;
    
    d_mxb_in = uint8(zeros(len_res, len_res, len_inputs));

    for t=1:len_inputs
        % prepare matrix to SLM
        if t==1
            mxf_in = mask * inputs(:, t);
        else
            mxf_in = mask * inputs(:, t) + w * res_history(1:size_res, t-1);
        end
        mxf_in = reshape(mxf_in, len_res, len_res);
        sgn_in = sign(mxf_in);
        mxb_in = uint8( round( 255 * abs(mxf_in) ));
        mxb_in(mxb_in>255)  = 255;
        mxb_in(mxb_in<-255) = -255;
        
        d_mxb_in(:,:,t) = mxb_in;
        
        % write to SLM
        img_res = repelem(mxb_in, len_slm_roi/len_res, len_slm_roi/len_res);
        img_slm(65:448,65:448) = img_res;
        write_mx(img_slm);
        subplot(1,3,1);
        imshow(img_res);
        title(['res-in (t=' num2str(t) ')']);

        % read from camera
        img_cam = getsnapshot(cam);
        img_cam_roi = img_cam(y0:y0+roi_len_y-1,x0:x0+roi_len_x-1);
        subplot(1,3,2);
        imshow(img_cam_roi);
        title('img-cam-roi');
       
        % process camera roi
        avg_tiles = @(block_struct) mean(mean(block_struct.data));
        res_out = blockproc(img_cam_roi,[cam_nrn_size_y cam_nrn_size_x],avg_tiles);
        mxb_out = uint8(round(res_out));
        mxf_out = double(mxb_out) .* sgn_in / 255;
        subplot(1,3,3);
        imshow(repelem(mxb_out, len_slm_roi/len_res, len_slm_roi/len_res));
        title('res-out');
        drawnow;
        
        % record reservoir history
        res_history(1:size_res,t) = mxf_out(:);
    end

    % train reservoir & evaluate performance
    X           = res_history(:, 1:len_train);
    R           = X*X' + reg_term*eye(size(X,1));
    P           = X * targets_bin(:, 1:len_train)';
    weights     = P' * pinv(R);
    rcouts      = weights * res_history(:,1:len_inputs);
    [~, rcouts_md] = max(rcouts);
    
    res_err_train(i_run) = sum(rcouts_md(1:len_train)~=targets(1:len_train))/len_train;
    res_err_test(i_run)  = sum(rcouts_md(len_train+1:len_inputs)~=targets(len_train+1:len_inputs))/len_test;
    fprintf('TrErr: %.2e, TtErr: %.2e. ', res_err_train(i_run), res_err_test(i_run));
    
    % save results
    save(['res_exp_run' num2str(i_run) '_slm_kth_hog.mat'], '-v7.3');

    % remaining time
    t_rem = round( (n_runs-i_run)*toc );
    fprintf('tRem: %d min, %d sec.\n', floor(t_rem/60), rem(t_rem,60));
end

stop(cam)

res_list      = [1:n_runs; scan_list; res_err_train'; res_err_test'];
res_list_srtd = sortrows(res_list', 7);




% Definition of ranges of scanned parameters
% Written by Piotr Antonik, Jan 2018

function [ scan_params, scan_list, n_runs ] = def_scan_params_kth_hog()

    % 1. set labels & values
    scan_params = struct();

    scan_params.lbls{1} = 'Input Gain';
    scan_params.vals{1} = [0.0001 0.0005 0.001 0.005 0.01 0.05 0.1 0.5 1];
    scan_params.lens(1) = length(scan_params.vals{1});

    scan_params.lbls{2} = 'Feedback Gain';
    scan_params.vals{2} = 0.1:0.1:1.5;
    scan_params.lens(2) = length(scan_params.vals{2});
 
    scan_params.lbls{3} = 'Interconnectivity Gain';
    scan_params.vals{3} = [0.0001 0.001 0.01 0.1 1];
    scan_params.lens(3) = length(scan_params.vals{3});
    
    scan_params.lbls{4} = 'Interconnectivity Matrix Density';
    scan_params.vals{4} = [0.0001 0.001 0.01 0.1 1];
    scan_params.lens(4) = length(scan_params.vals{4});

    % 2. generate permutations list
    n_runs       = prod(scan_params.lens);
    nscan_params = length(scan_params.lbls);
    scan_list    = zeros(nscan_params, n_runs);

    % understanding this loop requires a pencil, a paper and some concentration
    % better try it on a 3x3 example
    for i=1:nscan_params
        rep = prod( scan_params.lens(1:i-1) );
        cyc = prod( scan_params.lens(i+1:end) );
        % create rep x cyc matrix, then reshape columnwise into vector
        scan_list(i,:) = reshape( repmat(scan_params.vals{i}, rep, cyc), ...
            1, n_runs );
    end
end

