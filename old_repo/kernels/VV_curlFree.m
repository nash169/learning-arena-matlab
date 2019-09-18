function [f] = VV_curlFree(param)
%VV_CURLFREE Summary of this function goes here
%   Detailed explanation goes here
% Vector-Valued Curl Free Kernel
 if ~isfield(param,'sigma')
     error('Define sigma');
 end
        
[~,~,d2k] = rbf(param);
f = @(x,y) -d2k(x,y);

end

