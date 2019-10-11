function fig_options(obj, options)
% Set figure options
obj.fig_options_ = struct;

if isfield(options,'grid')
    obj.fig_options_.grid = num2cell(c_reshape(options.grid,[],1));
    obj.is_grid_ = false;
elseif ~obj.is_grid_
    assert(~isempty(obj.d_), "Don't know the dimension of data")
    obj.fig_options_.grid = num2cell(c_reshape([zeros(obj.d_,1), 100*ones(obj.d_,1)],[],1));
end

if isfield(options,'res'); obj.fig_options_.res = options.res; else
    obj.fig_options_.res = 100;
end

if isfield(options, 'sample')
    obj.fig_options_.sample = options.sample;
end

if isfield(options, 'colors'); obj.fig_options_.colors = options.colors; else
    obj.fig_options_.colors = 'r';
end
end
