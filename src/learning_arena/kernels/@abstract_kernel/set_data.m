function set_data(obj, varargin)
% Set the data. Here you have to pass all the data at
% once. You can't set just part of the data right now. Maybe it
% will be made more flexible in the future.
[obj.m_, obj.d_] = size(varargin{1});
[obj.n_, d_check] = size(varargin{2});
assert(obj.d_ == d_check, 'Dimension not compatible');

obj.data_ = varargin;
obj.Data_{1} = repmat(varargin{1},obj.n_,1);
obj.Data_{2} = repelem(varargin{2},obj.m_,1);
obj.diff_ = obj.Data_{1}-obj.Data_{2};

obj.is_data_ = true;
obj.reset;
end

