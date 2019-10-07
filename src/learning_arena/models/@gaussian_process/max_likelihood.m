function [f,g] = max_likelihood(obj, x, varargin)
% Optimization of the hyper-parameters through marginal likelihood
% maximization. The functional (likelihood) depends on the hyper-parameters
% through the Gaussian distribution. This functional runs every
% optimization step.

% Set the kernel hyper-parameters
obj.h_params_.kernel.set_v_params(x, varargin{:});
% Update the Gaussian
obj.set_gauss;
% Get the negative of the likelihood
f = -obj.likelihood;
% Get the negative og the likelihood gradient
g = -obj.likelihood_grad(varargin{:});
end

