function [f] = VV_rbf(param)
%RBF_VECTORVALUED Summary of this function goes here
%   Detailed explanation goes here
% Vector-Valued Gauss Kernel
if ~isfield(param,'sigma')
    error('Define sigma');
end
        
k = rbf(param);

f = @(x,y)...
    repmat(reshape(eye(size(x,2)),1,[]),size(x,1)*size(y,1),1)...
    .*k(x,y);

end

