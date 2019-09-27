function log_dp = calc_log_pgradient(obj)
% Calculate the log of the gradient with respect to hyper
% parameters
switch obj.type_cov_
    case 1
        if obj.debug; disp('Params - Cov 1'); end
        log_dp = obj.diff_.^2.*obj.sigma_inv_.*sqrt(obj.sigma_inv_);
        if size(obj.h_params_.sigma,2) == 1; log_dp = sum(log_dp,2); end
    case 2
        if obj.is_sigma_inv_
            if obj.debug; disp('Params - Cov 2 - Inv'); end
            x = (obj.sigma_inv_*obj.diff_')';
            xt = obj.diff_*obj.sigma_inv_;
            log_dp = outer_product(x,xt)/2;
        elseif obj.is_chol_
            if obj.debug; disp('Params - Cov 2 - Chol'); end
            a = linsolve(obj.chol_,obj.diff_', obj.opts_lt_);
            a = linsolve(obj.chol_', a, obj.opts_ut_)';
            log_dp = outer_product(a,a)/2;
        elseif obj.is_sigma_
            if obj.debug; disp('Params - Cov 2 - Sigma'); end
            x = (obj.sigma_\obj.diff_')';
            xt = obj.diff_/obj.sigma_;
            log_dp = outer_product(x,xt)/2;
        else
            error('Missing covariance')
        end
    case 3
        if obj.is_sigma_inv_
            if issparse(obj.sigma_inv_)
                if obj.debug; disp('Params - Cov 3 - Inv - Sparse'); end
                % Also here might be better to revert the spare matrix after
                % the inverse
                O = blk_matrix(outer_product(obj.diff_,obj.diff_));
                log_dp = obj.sigma_inv_*O*obj.sigma_inv_/2;
                log_dp = blk_revert(log_dp, obj.d_);
            else
                if obj.debug; disp('Params - Cov 3 - Inv'); end
                O = outer_product(obj.diff_,obj.diff_);
                log_dp = matrix_prod(obj.sigma_inv_,matrix_prod(O, obj.sigma_inv_))/2;
            end
        elseif obj.is_chol_
            if obj.debug; disp('Params - Cov 3 - Chol'); end
            a = c_reshape(obj.chol_'\(obj.chol_\reshape(obj.diff_', [], 1)), [], obj.d_);
            log_dp = outer_product(a,a)/2;
        elseif obj.is_sigma_
            if obj.debug; disp('Params - Cov 3 - Sigma'); end
            O = blk_matrix(outer_product(obj.diff_,obj.diff_));
            log_dp = obj.sigma_\O/obj.sigma_/2;
        else
            error('Missing covariance')
        end
end
end
