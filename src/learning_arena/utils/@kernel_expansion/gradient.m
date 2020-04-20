function dpsi = gradient(obj, varargin)
    % Get the gradient of the kernel expansion. The gradient is taken
    % by default with respect to the test points. The trining points
    % are considered to be parameters. About this, in the future it
    % would be possible to set them among the parameters instead of
    % through set_data. It is necessary to think about that. It is also
    % important to think about the order in the kernel:
    % k(x_train, x_test) vs k(x_test, x_train).
    % With a symmetric kernel it makes no difference but with a non
    % symmetric one?
    obj.check;
    if nargin > 1; obj.set_data(varargin{:}); end
    obj.input;

    if ~obj.is_dpsi_
        dk = obj.h_params_.kernel.gradient;
        obj.dpsi_ = obj.sum_kernels(dk(:, :, obj.dev_));
        obj.is_dpsi_ = true;
    end

    dpsi = obj.dpsi_;
end
