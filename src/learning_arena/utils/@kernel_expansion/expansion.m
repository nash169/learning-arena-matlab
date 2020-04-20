function psi = expansion(obj, varargin)
    % Get the kernel expansion.
    if nargin > 1; obj.set_data(varargin{:}); end
    obj.input;

    if ~obj.is_psi_
        obj.psi_ = obj.sum_kernels(obj.h_params_.kernel.kernel);
        obj.is_psi_ = true;
    end

    psi = obj.psi_;
end
