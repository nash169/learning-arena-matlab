function [f, df, d2f] = rbf_vel(param)
% Velocity modified RBF Gauss Kernel (asym):
%              (1+lambda*exp(-|||f(x)||/sigma_vel))*exp(-||x-y||/2*sigma^2)
% Velocity modified RBF Gauss Kernel (sym):
%              (1+lambda*exp(-|||f(x)||/sigma_vel))*exp(-||x-y||/2*sigma^2)*(1+lambda*exp(-|||f(y)||/sigma_vel))
% This is the standard Gaussian Kernel premultiplied by a decreasing
% exponential whose argument is a function of data x (a modulating
% factor 'lambda' regulates the intensity of this exponential while
% 'sigma_vel' regulates the locality). This is basically the velocity 
% at point x. It is a non-symmetric kernel dependent on values related
% to the points x.
% Required parameters: sigma, sigma_vel, lambda
if ~isfield(param,'sigma')
    error('Define sigma');
elseif ~isfield(param,'sigma_vel')
    error('Define sigma for velocity');
elseif ~isfield(param,'lambda')
    error('Define lambda');
end

if isfield(param,'sym')
    sym = param.sym;
else
    sym = false;
end


[k,~,~] = rbf(param);

if sym
    f = @(x,y,v)...
        (1 + param.lambda*exp(-vecnorm(repmat(v,size(y,1),1),2,2)/param.sigma_vel)).*...
        k(x,y).*...
        (1 + param.lambda*exp(-vecnorm(repelem(v,size(x,1),1),2,2)/param.sigma_vel));
else
    f = @(x,y,v)...
        (1 + param.lambda*exp(-vecnorm(repmat(v,size(y,1),1),2,2)/param.sigma_vel)).*...
        k(x,y);   
end

% Gradient
if nargout > 1
    [~,dk,~] = rbf(param);
    if sym
        df = @(x,y,v)...
             (1 + param.lambda*exp(-vecnorm(repmat(v,size(y,1),1),2,2)/param.sigma_vel)).*...
             dk(x,y).*...
             (1 + param.lambda*exp(-vecnorm(repelem(v,size(x,1),1),2,2)/param.sigma_vel));     
    else
        df = @(x,y,v)...
             (1 + param.lambda*exp(-vecnorm(repmat(v,size(y,1),1),2,2)/param.sigma_vel)).*...
             dk(x,y);
    end      
end

% Hessian
if nargout > 2
    [~,~,d2k] = rbf(param);
    if sym
        d2f = @(x,y,v)...
              (1 + param.lambda*exp(-vecnorm(repmat(v,size(y,1),1),2,2)/param.sigma_vel)).*...
              d2k(x,y).*...
              (1 + param.lambda*exp(-vecnorm(repelem(v,size(x,1),1),2,2)/param.sigma_vel));
    else
        d2f = @(x,y,v)...
              (1 + param.lambda*exp(-vecnorm(repmat(v,size(y,1),1),2,2)/param.sigma_vel)).*...
              d2k(x,y);
    end         
end

end