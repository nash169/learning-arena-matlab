function [f,g] = functional(obj, x, varargin)
obj.h_params_.kernel.set_v_params(x, varargin{:});
obj.set_gauss;
f = -obj.likelihood;
g = -obj.likelihood_grad(varargin{:});
end

