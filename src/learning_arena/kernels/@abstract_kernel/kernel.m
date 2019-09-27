function k = kernel(obj, varargin)
% This function return the kernel evaluation. You can pass the data
% directly here if you want.
if nargin > 1; obj.set_data(varargin{:}); end
obj.check;

if ~obj.is_kernel_
    obj.k_ = obj.calc_kernel;
%     obj.k_ = obj.h_params_.sigma_f^2*obj.calc_kernel + obj.h_params_.sigma_n^2*(vecnorm(obj.diff_,2,2)==0);
    if obj.params_.compact % It might be necessary to create a bool variable for this
        obj.k_ = (obj.k_ >= obj.params_.compact).*obj.k_;
    end
    obj.is_kernel_ = true;
end

k = obj.k_;
end

