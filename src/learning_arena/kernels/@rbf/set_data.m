function set_data(obj, varargin)
set_data@abstract_kernel(obj, varargin{:});
if obj.is_data_dep_; obj.is_covariance_ = false; end
end

