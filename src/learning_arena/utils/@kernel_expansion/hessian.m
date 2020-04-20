function d2psi = hessian(obj, varargin)
    % Get the hessian. Also the hessian is taken with respect to the
    % test points.
    obj.check;
    if nargin > 1; obj.set_data(varargin{:}); end
    obj.input;

    if ~obj.is_d2psi_
        d2k = obj.h_params_.kernel.hessian;
        obj.d2psi_ = obj.sum_kernels(d2k(:, :, obj.dev_^2));
        obj.is_d2psi_ = true;
    end

    d2psi = obj.d2psi_;
end
