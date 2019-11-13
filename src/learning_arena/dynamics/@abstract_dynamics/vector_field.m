function X = vector_field(obj, varargin)
%VECTOR_FIELD Summary of this function goes here
%   Detailed explanation goes here
if nargin > 1
    obj.set_data(varargin{:})
else
    assert(obj.is_data_, "Dataset not present");
end

obj.check;

if ~obj.is_field_
   obj.X_ = obj.calc_field(obj.data_);
   obj.is_field_ = true;
end

if nargout > 0; X = obj.X_; end
end

