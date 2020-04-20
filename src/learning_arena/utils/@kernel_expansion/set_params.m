function set_params(obj, varargin)
    % Set the parameters of the kernel. Set the parameters that you
    % like. Every time you set a parameters the kernel will be
    % recalculated
    for i = 1:2:length(varargin)

        if logical(sum(strcmp(obj.h_params_list_, varargin{i})))
            obj.h_params_.(varargin{i}) = varargin{i + 1};
        elseif logical(sum(strcmp(obj.params_list_, varargin{i})))
            obj.params_.(varargin{i}) = varargin{i + 1};
            if strcmp(varargin{i}, 'order'); obj.is_input_ = false; end

            if strcmp(varargin{i}, 'reference')
                [obj.m_, obj.d_] = size(obj.params_.reference);
            end

            if strcmp(varargin{i}, 'kernel')
                obj.is_kernel_input_ = false;
            end

        else
            error('"%s" parameter not present', varargin{i})
        end

    end

    obj.is_params_ = false;
    obj.reset;
end
