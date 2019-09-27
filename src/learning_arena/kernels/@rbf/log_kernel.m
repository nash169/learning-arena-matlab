function log_k = log_kernel(obj, varargin)
% Get the the argument of the rbf kernel exponential. This is
% mainly needed for the computation of the log-likelihood in the
% normal distribution. It's not very elegant. Perhaps, a better
% solution should be find here.
if nargin > 1; obj.set_data(varargin{:}); end
obj.check;
% Signal and noise variance not considered at the moment
if ~obj.is_log_k_
    obj.log_k_ = obj.calc_log_kernel;
    obj.is_log_k_ = true;
end

if nargout > 0; log_k = obj.log_k_; end
end

