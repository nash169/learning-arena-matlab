function params = params(obj, parameter)
% Get the parameters of the kernel.
if nargin < 2 
    params = obj.h_params_;
else
    assert(logical(sum(strcmp(obj.params_list_, parameter))), ...
    '"%s" parameter not present', parameter)

    params = obj.params_.(parameter);
end
end
