function log_dp = calc_log_pgradient(obj, param)

    switch param
        case 'mean'
            dk = obj.h_params_.kernel.log_gradient;
            log_dp = dk(:, :, 2);
        case 'sigma'

            switch obj.type_cov_
                case 1
                    S_inv = (1 ./ obj.cov_) .* eye(obj.d_);
                case 2
                    S_inv = linsolve(obj.cov_, eye(obj.d_), obj.opts_lt_);
                    S_inv = linsolve(obj.cov_', S_inv, obj.opts_ut_);
                otherwise
                    error('Case not present');
            end

            grad = obj.h_params_.kernel.log_pgradient({'sigma'});
            log_dp = -repmat(S_inv / 2, obj.n_, 1) + grad.sigma;
        otherwise
            error('Derivation not possible')
    end

end
