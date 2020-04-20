function log_d2k = calc_log_hessian(obj)

    switch obj.type_cov_
        case 1
            if obj.debug; disp('Hessian - Cov 1'); end
            a = obj.diff_ .* obj.sigma_inv_;
            I = repmat(eye(obj.d_), obj.m_ * obj.n_, 1) .* c_reshape(obj.sigma_inv_ .* ones(obj.m_ * obj.n_, obj.d_), [], 1);
            hess = I - outer_product(a, a);
        case 2

            if obj.is_sigma_inv_
                if obj.debug; disp('Hessian - Cov 2 - Inv'); end
                S = repmat(obj.sigma_inv_, obj.m_ * obj.n_, 1);
                x = (obj.sigma_inv_ * obj.diff_')';
                xt = obj.diff_ * obj.sigma_inv_;
                hess = S - 2 * outer_product(x, xt);
            elseif obj.is_chol_
                if obj.debug; disp('Hessian - Cov 2 - Chol'); end
                S = repmat(obj.chol_' \ (inv(obj.chol_)), obj.m_ * obj.n_, 1);
                a = (obj.chol_' \ (obj.chol_ \ obj.diff_'))';
                hess = S - 2 * outer_product(a, a);
            elseif obj.is_sigma_
                if obj.debug; disp('Hessian - Cov 2 - Sigma'); end
                obj.invert('inv');
                % Use the sigma_inv_ since you calculated it
                S = repmat(obj.sigma_inv_, obj.m_ * obj.n_, 1);
                x = (obj.sigma_inv_ * obj.diff_')';
                xt = obj.diff_ * obj.sigma_inv_;
                hess = S - 2 * outer_product(x, xt);
            else
                error('Missing covariance')
            end

        case 3

            if obj.is_sigma_inv_

                if issparse(obj.sigma_inv_)
                    if obj.debug; disp('Hessian - Cov 3 - Inv - Sparse'); end
                    % Here it might be better to revert the sparse and use the
                    % calculation of the dependent hessian for non-sparse
                    % matrix
                    O = blkdiag(outer_product(obj.diff_, obj.diff_));
                    hess = obj.sigma_inv_ - 2 * obj.sigma_inv_ * O * obj.sigma_inv_;
                    hess = blk_revert(hess, obj.d_);
                else
                    if obj.debug; disp('Hessian - Cov 3 - Inv'); end
                    O = outer_product(obj.diff_, obj.diff_);
                    hess = obj.sigma_inv_ - 2 * matrix_prod(obj.sigma_inv_, matrix_prod(O, obj.sigma_inv_));
                end

            elseif obj.is_chol_
                if obj.debug; disp('Hessian - Cov 3 - Chol'); end
                assert(issparse(obj.chol_), 'Sparse Cholesky not present')
                a = c_reshape(obj.chol_' \ (obj.chol_ \ reshape(obj.diff_', [], 1)), [], obj.d_);
                S = obj.chol_' \ inv(obj.chol_);
                hess = S - 2 * blk_matrix(outer_product(a, a));
                hess = blk_revert(hess, obj.d_);
            elseif obj.is_sigma_
                if obj.debug; disp('Hessian - Cov 3 - Sigma'); end
                assert(issparse(obj.sigma_), 'Sparse Sigma not present')
                obj.invert('inv');
                % Also here might be better to revert the spare matrix after
                % the inverse
                O = blkdiag(outer_product(obj.diff_, obj.diff_));
                hess = obj.sigma_inv_ - 2 * obj.sigma_inv_ * O * obj.sigma_inv_;
            else
                error('Missing covariance')
            end

    end

    % Resize hessian in 1 x dim^2
    hess = c_reshape(hess, [], obj.d_^2);

    % Fill tensor containining derivation with respect to all the variables
    log_d2k = zeros(size(hess, 1), size(hess, 2), 4);
    log_d2k(:, :, 1) = -hess; log_d2k(:, :, 2) = hess; log_d2k(:, :, 3) = hess; log_d2k(:, :, 4) = -hess;
end
