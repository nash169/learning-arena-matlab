function check(obj)
    % Check data and parameters.
    assert(obj.is_data_, "Data not present");

    if ~obj.is_params_

        for i = 1:length(obj.h_params_list_)
            assert(isfield(obj.h_params_, obj.h_params_list_{i}), ...
                "Define %s", obj.h_params_list_{i});
        end

        for i = 1:length(obj.params_list_)
            assert(isfield(obj.params_, obj.params_list_{i}), ...
                "Define %s", obj.params_list_{i});
        end

        if ~obj.h_params_.sigma_n; obj.h_params_.sigma_n = 1e-8; end

        obj.is_params_ = true;
    end

end
