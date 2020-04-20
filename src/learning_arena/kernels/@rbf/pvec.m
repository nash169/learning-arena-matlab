function [vec, counter] = pvec(obj, name, vec, counter)
    vec(counter + 1:counter + obj.num_h_params_) = ...
        c_reshape(obj.h_params_.(name), [], 1); % name = 'sigma'
    counter = counter + obj.num_h_params_;
end
