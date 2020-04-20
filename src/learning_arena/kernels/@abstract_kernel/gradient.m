function dk = gradient(obj, varargin)
    % This function return the gradient evaluation. You can pass the data
    % directly here if you want.
    if nargin > 1; obj.set_data(varargin{:}); end
    obj.check;

    if ~obj.is_gradient_
        obj.dk_ = obj.h_params_.sigma_f^2 * obj.calc_gradient;
        obj.is_gradient_ = true;
    end

    dk = obj.dk_;
end
