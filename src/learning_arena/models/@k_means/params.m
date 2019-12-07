function params = params(obj, parameter)
% Get the parameters. Not very useful at the moment
assert(logical(sum(strcmp(obj.params_name_, parameter))), ...
    '"%s" parameter not present', parameter)
if nargin < 2 
    params = obj.params_;
else
    params = obj.params_.(parameter);
end
end

