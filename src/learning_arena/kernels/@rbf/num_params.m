function d = num_params(obj, name)
d = length(name);

if logical(sum(strcmp(name, 'sigma')))
    assert(isfield(obj.h_params_, 'sigma'), 'Sigma not defined')
    assert(~obj.params_.sigma_inv, 'Sigma inverese defined')
    obj.num_h_params_ = numel(obj.h_params_.sigma);
    d = d - 1 + numel(obj.h_params_.sigma);
end

end

