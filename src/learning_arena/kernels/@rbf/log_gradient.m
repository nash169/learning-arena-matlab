function log_dk = log_gradient(obj, varargin)
    if nargin > 1; obj.set_data(varargin{:}); end
    obj.check;
    % Signal and noise variance not considered at the moment
    if ~obj.is_log_dk_
        obj.log_dk_ = obj.calc_log_gradient;
        obj.is_log_dk_ = true;
    end

    log_dk = obj.log_dk_;
end
