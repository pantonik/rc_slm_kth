function [ mx_conf ] = conf_matrix( n_actions, targets, outs )
%CONF_MATRIX Compute confusion matrix
    % Written by P. Antonik, Jul 2018

mx_conf   = zeros(n_actions);
mx_totals = zeros(n_actions, 1);
for i=1:length(targets)
    mx_conf(targets(i), outs(i)) = mx_conf(targets(i), outs(i)) + 1;
    mx_totals(targets(i),1) = mx_totals(targets(i), 1) + 1;
end
mx_conf = mx_conf ./ repmat(mx_totals, 1, n_actions) * 100;

end

