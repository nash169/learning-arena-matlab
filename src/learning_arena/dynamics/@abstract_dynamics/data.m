function data = data(obj)
% Get the discrete dataset.
assert(obj.is_data_, "Data not present")
data = obj.data_;
end
