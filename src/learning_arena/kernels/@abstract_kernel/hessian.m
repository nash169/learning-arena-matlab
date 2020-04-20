function d2k = hessian(obj, varargin)
    % This function return the hessian evaluation. You can pass the data
    % directly here if you want.
    if nargin > 1; obj.set_data(varargin{:}); end
    obj.check;

    if ~obj.is_hessian_
        obj.d2k_ = obj.h_params_.sigma_f^2 * obj.calc_hessian;
        obj.is_hessian_ = true;
    end

    d2k = obj.d2k_;
end
