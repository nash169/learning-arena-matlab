function S = covariance(obj, param) 
% Get the either the covariance matrix, the inverse or the cholesky
% decomposition - % sigma, inverse, cholesky
obj.check;
    
if nargout > 0
    if nargin < 2; param = 'sigma'; end
    switch param
        case 'sigma'
            assert(obj.is_sigma_, 'Covariance matrix not present');
            S = obj.sigma_;
        case 'inverse'
            S = obj.invert('inv');
        case 'cholesky'
            S = obj.invert('chol'); 
    end
end
end
