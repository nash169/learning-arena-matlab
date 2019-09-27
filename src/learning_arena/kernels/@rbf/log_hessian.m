function log_d2k = log_hessian(obj, varargin)
if nargin > 1; obj.set_data(varargin{:}); end
obj.check;
% Signal and noise variance not considered at the moment
if ~obj.is_log_d2k_
    obj.log_d2k_ = obj.calc_log_hessian;
    obj.is_log_d2k_ = true;
end

if nargout > 0; log_d2k = obj.log_d2k_; end
end

