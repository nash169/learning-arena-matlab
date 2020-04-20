function check(obj)
    % Check data and parameters.
    if ~obj.is_params_

        for i = 1:length(obj.h_params_list_)
            assert(isfield(obj.h_params_, obj.h_params_list_{i}), ...
                "Define %s", obj.h_params_list_{i});
        end

        for i = 1:length(obj.params_list_)
            assert(isfield(obj.params_, obj.params_list_{i}), ...
                "Define %s", obj.params_list_{i});
        end

        obj.is_params_ = true;
    end

end
