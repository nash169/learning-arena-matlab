function [f, df, d2f] = rbf_compact(param)
% RBF Compact Gauss Kernel: exp(-||x-y||/2*sigma^2) if ||x-y||<=r
% This is the classical Gaussian Kernel with compact support. Besides
% 'sigma' it needs the support 'r' of the function so that the kernel
% is equal to zero if ||x-y||>r
% Required parameters: sigma, r
if ~isfield(param,'sigma')
    error('Define sigma');
elseif ~isfield(param,'r')
    error('Define r');
end
        
[k,~,~] = rbf(param);
f = @(x,y)...
    (vecnorm(repmat(x,size(y,1),1)-repelem(y,size(x,1),1),2,2) <= param.r)...
    .*k(x,y);
        
% Gradient
if nargout > 1
    [~,dk,~] = rbf(param);
    df = @(x,y)...
         (vecnorm(repmat(x,size(y,1),1)-repelem(y,size(x,1),1),2,2) <= param.r)...
         .*dk(x,y);    
end

% Hessian
if nargout > 2
    [~,~,d2k] = rbf(param);
    d2f = @(x,y)...
          (vecnorm(repmat(x,size(y,1),1)-repelem(y,size(x,1),1),2,2) <= param.r)...
          .*d2k(x,y);
end

end

