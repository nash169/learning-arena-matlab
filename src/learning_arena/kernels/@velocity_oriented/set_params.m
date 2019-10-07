function set_params(obj, varargin)
set_params@abstract_kernel(obj, varargin{:});

if logical(sum(strcmp(varargin(1:2:end), 'v_field'))) || ...
    logical(sum(strcmp(varargin(1:2:end), 'weights'))) || ...
    logical(sum(strcmp(varargin(1:2:end), 'weight_fun')))
    obj.is_sigma_inv_ = false;
end
end

