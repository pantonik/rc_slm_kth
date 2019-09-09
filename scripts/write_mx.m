% Upload data (a square 16-bit-valued matrix) into the SLM
% Written by Piotr Antonik, Jan 2018

function [ ] = write_mx( mx )

    if isa(mx, 'uint8')
        mx = mx';                                              % rotate matrix to read image row by row
        mx_stream = reshape([zeros(1,512^2); mx(:)'], 1, [])'; % convert matrix into 2x8-bit stream for SLM memory
        mx_ptr = libpointer('uint8Ptr', mx_stream);            % create pointer with value = matrix stream
        BNS_WriteImage(mx_ptr);                                % load matrix to SLM
        BNS_SetPower(true);                                    % turn SLM on
    else
        warning('write_mx expects a matrix of type uint8.');
    end

end

