function set_params(obj, varargin)

    for i = 1:2:length(varargin)
        assert(logical(sum(strcmp(obj.params_name_, varargin{i}))), '"%s" parameter not present', varargin{i})
        obj.params_.(varargin{i}) = varargin{i + 1};
    end

    obj.is_params_ = false;
    obj.reset;
end
