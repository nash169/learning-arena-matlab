function [f] = rbf_direct_grad(param)
%RBF_DIRECTED Summary of this function goes here
%   Detailed explanation goes here

if ~isfield(param,'epsilon')
    error('Define epsilon');
end

if ~isfield(param,'lambda')
    error('Define lambda');
end

f = @(x,y,du)...
    exp(-vecnorm(repmat(x,size(y,1),1)-repelem(y,size(x,1),1),2,2).^2./param.epsilon ...
        +param.lambda*sum(repmat(du,size(y,1),1).*(repmat(x,size(y,1),1)-repelem(y,size(x,1),1)),2));
end

