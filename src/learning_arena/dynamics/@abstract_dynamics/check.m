function check(obj)
% Check data and parameters.
assert(obj.is_data_, "Dataset not present");

if ~obj.is_params_
    for i  = 1 : length(obj.params_list_)
       assert(isfield(obj.params_,obj.params_list_{i}), ...
           "Define %s", obj.params_list_{i});
    end

    obj.is_params_ = true;
end
end