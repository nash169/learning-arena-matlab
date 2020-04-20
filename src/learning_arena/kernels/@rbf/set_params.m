function set_params(obj, varargin)

    for i = 1:2:length(varargin)

        if logical(sum(strcmp(obj.h_params_list_, varargin{i})))
            obj.h_params_.(varargin{i}) = varargin{i + 1};

            if strcmp(varargin{i}, 'sigma')
                obj.is_sigma_ = false;
                obj.is_sigma_inv_ = false;
                obj.is_chol_ = false;
                obj.params_.sigma_inv = false;
                obj.is_covariance_ = false;
            end

        elseif logical(sum(strcmp(obj.params_list_, varargin{i})))
            obj.params_.(varargin{i}) = varargin{i + 1};

            if strcmp(varargin{i}, 'sigma_inv')
                obj.is_sigma_ = false;
                obj.is_sigma_inv_ = false;
                obj.is_chol_ = false;
                obj.is_covariance_ = false;
            end

        else
            error('"%s" parameter not present', varargin{i})
        end

    end

    obj.is_params_ = false;
    obj.reset;
end
