% Experimental results analysis script
% Extract unitary targets & RC outputs
% Keep the same order as in experiment
% Written by P. Antonik, Jul 2018

n_cells = 600;
idx_short_train = 1:n_cells/4*3;
idx_short_test  = n_cells/4*3+1:n_cells;
mx_outs_short = zeros(n_cells, len_inputs);
mx_targets_short = zeros(n_cells, len_inputs);
for t=1:len_inputs
    mx_targets_short(indexes(t), t) = targets(t);
    mx_outs_short(indexes(t), t) = rcouts_md(t);
end
mx_outs_short(mx_outs_short==0) = NaN;
outs_short = mode(mx_outs_short, 2);
outs_short(isnan(outs_short)) = [];

mx_targets_short(mx_targets_short==0) = NaN;
targets_short = mode(mx_targets_short, 2);
targets_short(isnan(targets_short)) = [];

indexes_short = unique(indexes, 'stable');
outs_short = outs_short(indexes_short);
targets_short = targets_short(indexes_short);

conf_matrix_train = conf_matrix(6, targets_short(idx_short_train), outs_short(idx_short_train));
conf_matrix_test = conf_matrix(6, targets_short(idx_short_test), outs_short(idx_short_test));
