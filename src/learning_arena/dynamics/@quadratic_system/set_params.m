function set_params(obj, varargin)
% Set the parameters of the kernel. Set the parameters that you
% like. Every time you set a parameters the kernel will be
% recalculated
set_params@abstract_dynamics(obj, varargin{:});

if logical(sum(strcmp(obj.params_list_, 'a_matrix')))
    obj.d_ = size(obj.params_.a_matrix,1);
end
end
