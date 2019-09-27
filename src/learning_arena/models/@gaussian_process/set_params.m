function set_params(obj, varargin)
set_params@kernel_expansion(obj, varargin{:});

if logical(sum(strcmp(varargin, 'reference')))
    obj.gauss_.set_params('mean', zeros(1,obj.m_));
end

obj.is_gauss_ = false;
end
