function check(obj)

    if ~obj.is_params_

        for i = 1:length(obj.params_name_)
            assert(isfield(obj.params_, obj.params_name_{i}), ...
                '"%s" parameter missing', obj.params_name_{i})
        end

        obj.is_params_ = true;
    end

end
