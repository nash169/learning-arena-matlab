function set_params(obj, varargin)
% Set parameters. It is possible to set just the parameters shown
% in 'params_list_'
for i = 1 : 2 : length(varargin)
    assert(logical(sum(strcmp(obj.params_list_, varargin{i}))), '"%s" parameter not present', varargin{i})
    obj.params_.(varargin{i}) = varargin{i+1};
    
    if strcmp('cluster', varargin{i}); obj.is_centroids_ = false; end
end

obj.is_params_ = false;
obj.reset;
end
