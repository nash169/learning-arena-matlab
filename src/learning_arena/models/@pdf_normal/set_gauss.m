function set_gauss(obj)
%SET_KERNEL Summary of this function goes here
%   Detailed explanation goes here
obj.h_params_.kernel.set_params('sigma', obj.h_params_.sigma);
obj.type_cov_ = obj.h_params_.kernel.covariance_type;

if obj.type_cov_ == 1
    obj.cov_ = obj.h_params_.kernel.covariance('sigma');
    logdet = prod(obj.cov_.*ones(1,obj.d_)); % no data dependent
else
    obj.cov_ = obj.h_params_.kernel.covariance('cholesky');
    logdet = 2*sum(log(diag(obj.cov_)));
end

obj.h_params_.weights = exp(-(obj.d_*log(2*pi) + logdet)/2);
obj.is_gauss_ = true;
end
