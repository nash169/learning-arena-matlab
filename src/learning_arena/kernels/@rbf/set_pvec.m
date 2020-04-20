function counter = set_pvec(obj, name, vec, counter)
    obj.set_params(name, vec(counter + 1:counter + obj.num_h_params_)); % name = 'sigma'
    counter = counter + obj.num_h_params_;
end
