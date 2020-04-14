function params = params(obj, parameter)

    assert(logical(sum(strcmp(obj.params_name_, parameter))), ...
        '"%s" parameter not present', parameter)

    if nargin < 2
        params = obj.params_;
    else
        params = obj.params_.(parameter);
    end

end
