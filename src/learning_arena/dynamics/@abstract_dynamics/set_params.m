function set_params(obj, varargin)
% Set the parameters of the kernel. Set the parameters that you
% like. Every time you set a parameters the kernel will be
% recalculated
for i = 1 : 2 : length(varargin)
    assert(logical(sum(strcmp(obj.params_list_, varargin{i}))), '%s parameter not present', varargin{i})
    obj.params_.(varargin{i}) = varargin{i+1};
end

obj.is_params_ = false;
obj.reset;
end
