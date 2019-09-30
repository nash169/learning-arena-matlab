function check(obj)
assert(obj.is_data_, "Data not present");

if ~obj.is_params_
    for i  = 1 : length(obj.params_name_)
       assert(isfield(obj.params_,obj.params_name_{i}), ...
           '"%s" parameter missing', obj.params_name_{i})
    end
    obj.is_params_ = true;
end

if ~obj.is_expansion_
    obj.expansion_ = kernel_expansion('kernel', obj.params_.kernel, 'reference', obj.data_);
    obj.is_expansion_ = true;
end
end

