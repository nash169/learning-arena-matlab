function set_params(obj, varargin)
    set_params@kernel_expansion(obj, varargin{:});

    if logical(sum(strcmp(varargin, 'mean')))
        [obj.m_, obj.d_] = size(obj.h_params_.mean);
        obj.params_.('reference') = obj.h_params_.mean;
    end

    obj.is_gauss_ = false;
end
