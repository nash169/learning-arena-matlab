function type = covariance_type(obj)
%COVARIANCE_TYPE Summary of this function goes here
%   Detailed explanation goes here
obj.check;

if nargout > 0
    type = obj.type_cov_;
end
end

