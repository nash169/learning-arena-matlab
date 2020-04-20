function log_dk = calc_log_gradient(obj)

    switch obj.type_cov_
        case 1

            if obj.debug; disp('Gradient - Cov 1'); end
            grad = obj.sigma_inv_ .* obj.diff_;
        case 2

            if obj.sigma_inv_
                if obj.debug; disp('Gradient - Cov 2 - Inv'); end
                grad = (obj.sigma_inv_ * obj.diff_')';
            elseif obj.is_chol_
                if obj.debug; disp('Gradient - Cov 2 - Chol'); end
                grad = (obj.chol_' \ (obj.chol_ \ obj.diff_'))';
            elseif obj.is_sigma_
                if obj.debug; disp('Gradient - Cov 2 - Sigma'); end
                grad = (obj.sigma_ \ obj.diff_')';
            else
                error('Missing covariance')
            end

        case 3

            if obj.is_sigma_inv_

                if issparse(obj.sigma_inv_)
                    if obj.debug; disp('Gradient - Cov 3 - Inv - Sparse'); end
                    grad = c_reshape(obj.sigma_inv_ * reshape(obj.diff_', [], 1), [], obj.d_);
                else
                    if obj.debug; disp('Gradient - Cov 3 - Inv'); end
                    grad = c_reshape(sum(obj.sigma_inv_ .* ...
                        repelem(obj.diff_, obj.d_, 1), 2), [], obj.d_);
                end

            elseif obj.is_chol_
                if obj.debug; disp('Gradient - Cov 3 - Chol'); end
                assert(issparse(obj.chol_), 'Sparse Cholesky not present')
                grad = c_reshape(obj.chol_' \ (obj.chol_ \ reshape(obj.diff_', [], 1)), [], obj.d_);
            elseif obj.is_sigma_
                if obj.debug; disp('Gradient - Cov 3 - Sigma'); end
                assert(issparse(obj.sigma_), 'Sparse Sigma not present')
                grad = c_reshape(obj.sigma_ \ reshape(obj.diff_', [], 1), [], obj.d_);
            else
                error('Missing covariance')
            end

        otherwise
            error('Covariance type not found')
    end

    log_dk = zeros(size(grad, 1), size(grad, 2), 2);
    log_dk(:, :, 1) = -grad; log_dk(:, :, 2) = grad;
end
