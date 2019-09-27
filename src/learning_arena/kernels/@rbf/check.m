function check(obj)
check@abstract_kernel(obj);

if ~obj.is_covariance_
    obj.calc_covariance;
    obj.is_covariance_ = true;
end
end