function check(obj)

    if ~obj.is_params_

        for i = 1:length(obj.params_name_)
            assert(isfield(obj.params_, obj.params_name_{i}), ...
                '"%s" parameter missing', obj.params_name_{i})
        end

        obj.is_params_ = true;
    end

    if ~obj.is_laplace_
        data = obj.params_.manifold.data;
        obj.laplace_.set_data(data);
        obj.laplace_.set_params('kernel', obj.params_.kernel, ...
            'epsilon', obj.params_.epsilon);
        obj.is_laplace_ = true;
    end

end
