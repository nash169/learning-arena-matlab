function J = jacobian(obj, data)
    %VECTOR_FIELD Summary of this function goes here
    %   Detailed explanation goes here
    if nargin > 1
        obj.set_data(data)
    else
        assert(obj.is_data_, "Dataset not present");
    end

    obj.check;

    if ~obj.is_jacobian_
        obj.J_ = obj.calc_jacobian(obj.data_);
        obj.is_jacobian_ = true;
    end

    if nargout > 0; J = obj.J_; end
end
