function [f, df] = rbf_attracts(param)
%RBF_ATTRACTS Summary of this function goes here
%   Attractor distance modified RBF Gauss Kernel - Conformal Transformation
%   x_a = x_i(vecnorm(xdot_i,2,2)==0,:);

if ~isfield(param,'sigma')
    error('Define sigma');
elseif ~isfield(param,'sigma_attract')
    error('Define sigma for attractor kernel');
elseif ~isfield(param,'lambda')
    error('Define lambda scaling');
end
        
par_attr.sigma = param.sigma_attract;
        
[k,~,~] = rbf(param);
[k_a,~,~] = rbf(par_attr);
        
f = @(x,y,x_a)...
    repmat((1 + param.lambda*sum(reshape(k_a(x_a,x), size(x_a,1), [])))',size(y,1),1).*...
    k(x,y).*...
    repelem((1 + param.lambda*sum(reshape(k_a(x_a,y), size(x_a,1), [])))',size(x,1),1);

% Gradient
if nargout > 1
    [~,dk,~] = rbf(param);
    [~,dk_a,~] = rbf(par_attr);
    df = @(x,y,x_a) ...
         repmat((1 + param.lambda*sum(reshape(k_a(x_a,x), size(x_a,1), [])))',size(y,1),1).* ...
         dk(x,y).*...
         repelem((1 + param.lambda*sum(reshape(k_a(x_a,y), size(x_a,1), [])))',size(x,1),1) + ...
         repmat((1 + param.lambda*sum(reshape(k_a(x_a,x), size(x_a,1), [])))',size(y,1),1).* ...
         k(x,y).*...
         repelem(squeeze(sum(reshape(dk_a(x_a,y)',size(y,2),size(x_a,1),[]),2))',size(x,1),1);
end

% Hessian
if nargout > 2
    error('Hessian not available yet');           
end
end

