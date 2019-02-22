function [f] = anisotropicRbf_cov(param)
%ANISOTROPICRBF_COV Summary of this function goes here
%   Detailed explanation goes here

if ~isfield(param,'epsilon')
    error('Define epsilon');
end

if isfield(param,'train_points')
    train_points = param.train_points;
else
    train_points = true;
end

if train_points
% Non-Stationary Covariance Oriented Gaussian Kernel
    f = @(x,y,x_i)...
        exp(-CovCenter2(x,y,x_i)/param.epsilon);
else
% Non-Stationary Covariance Oriented Gaussian Kernel with training points
    f = @(x,y)...
        exp(-CovCenter(x,y)/param.epsilon);
end

if nargout > 1
    error('Gradient not available yet.');
end

if nargout > 2
    error('Hessian not available yet.');
end

end

