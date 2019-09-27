function input(obj)
assert(obj.is_data_, "Test set not present");

if ~obj.is_input_
    switch obj.params_.order
        case 'ref-test'
            obj.input_ = {obj.params_.reference, obj.data_};
            obj.dev_ = 2;
        case 'test-ref'
            obj.input_ = {obj.data_, obj.params_.reference};
            obj.dev_ = 1;
        otherwise
            error('Case not found')
    end
    
    obj.is_input_ = true;
end

if ~obj.is_kernel_input_
    obj.h_params_.kernel.set_data(obj.input_{:});
    obj.is_kernel_input_ = false;
end
end

