function log_k = calc_log_kernel(obj)
% Calculate the log of the rbf kernel exponetial
switch obj.type_cov_
    case 1
        if obj.debug; disp('Kernel - Cov 1'); end
        log_k = -sum(obj.diff_.^2.*obj.sigma_inv_,2)/2;
%         log_k = -vecnorm(obj.diff_,2,2).^2*obj.sigma_inv_/2;
    case 2
        if obj.is_sigma_inv_
            if obj.debug; disp('Kernel - Cov 2 - Inv'); end
            log_k = -sum(obj.diff_.*(obj.sigma_inv_*obj.diff_')',2)/2;
        elseif obj.is_chol_
            if obj.debug; disp('Kernel - Cov 2 - Chol'); end
            a = linsolve(obj.chol_,obj.diff_', obj.opts_lt_)';
            log_k = -sum(a.*a,2)/2;
        elseif obj.is_sigma_
            if obj.debug; disp('Kernel - Cov 2 - Sigma'); end
            log_k = -sum(obj.diff_.*(obj.sigma_\obj.diff_')',2)/2;
        else
            error('Missing covariance')
        end
    case 3
        if obj.is_sigma_inv_
            if issparse(obj.sigma_inv_)
                if obj.debug; disp('Kernel - Cov 3 - Inv - Sparse'); end
                log_k = -sum(obj.diff_.*c_reshape(obj.sigma_inv_*reshape(obj.diff_',[],1), [], obj.d_),2)/2;
            else
                if obj.debug; disp('Kernel - Cov 3 - Inv'); end
                log_k = -sum(obj.diff_.*c_reshape(sum(obj.sigma_inv_.*repelem(obj.diff_, obj.d_, 1),2),[], obj.d_),2)/2;
            end
        elseif obj.is_chol_
            if obj.debug; disp('Kernel - Cov 3 - Chol'); end
            assert(issparse(obj.chol_), 'Sparse Cholesky not present')
            a = c_reshape(obj.chol_\reshape(obj.diff_',[],1), [], obj.d_);
            log_k = -sum(a.*a,2)/2;
        elseif obj.is_sigma_
            if obj.debug; disp('Kernel - Cov 3 - Sigma'); end
            assert(issparse(obj.sigma_), 'Sparse Sigma not present')
            log_k = -sum(obj.diff_.*c_reshape(obj.sigma_\reshape(obj.diff_',[],1), [], obj.d_),2)/2;
        else
            error('Missing covariance')
        end
    otherwise
        error('Covariance type not found')
end
end

