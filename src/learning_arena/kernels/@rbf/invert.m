% Get the inverse of the covariance
function M = invert(obj, type)

    switch type
        case 'chol'

            if ~obj.is_chol_
                assert(obj.is_sigma_, 'Sigma not present')
                obj.chol_ = chol(obj.sigma_, 'lower');
                obj.is_chol_ = true;
            end

            if nargout > 0; M = obj.chol_; end

        case 'inv'

            if ~obj.is_sigma_inv_
                assert(obj.is_sigma_, 'Sigma not present')
                obj.sigma_inv_ = inv(obj.sigma_);
                obj.is_sigma_inv_ = true;
            end

            if nargout > 0; M = obj.sigma_inv_; end

        otherwise
            error('Case not found')
    end

end
