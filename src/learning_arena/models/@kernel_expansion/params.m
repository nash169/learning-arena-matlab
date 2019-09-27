function [params, params_aux] = params(obj, parameter)
% Get the parameters of the kernel.
assert(logical(sum(strcmp(obj.h_params_list_, parameter))), ...
    '"%s" parameter not present', parameter)
if nargin < 2 
    params = obj.h_params_;
    if nargout > 1; params_aux = obj.params_; end
else
    assert(nargout < 2, 'Just one output allowed')

    if logical(sum(strcmp(obj.h_params_list_, parameter)))
        params = obj.h_params_.(parameter);
    elseif logical(sum(strcmp(obj.params_list_, parameter)))
        params = obj.params_.(parameter);
    else
        error('"%s" parameter not present', parameter)
    end

end
end
