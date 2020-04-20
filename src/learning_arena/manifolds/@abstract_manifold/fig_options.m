function fig_options(obj, options)
    % Set figure options
    obj.fig_options_ = struct;

    if isfield(options, 'grid')
        obj.fig_options_.grid = num2cell(c_reshape(options.grid, [], 1));
        obj.is_grid_ = false;
    elseif ~obj.is_grid_
        obj.fig_options_.grid = obj.extrema_;
    end

    if isfield(options, 'res'); obj.fig_options_.res = options.res; else
        obj.fig_options_.res = 100;
    end

    if isfield(options, 'embedding'); obj.fig_options_.embedding = options.embedding; else
        obj.fig_options_.embedding = true;
    end

    if isfield(options, 'data'); obj.fig_options_.data = options.data; else
        obj.fig_options_.data = false;
    end

    if isfield(options, 'sample'); obj.fig_options_.sample = options.sample; else
        obj.fig_options_.sample = false;
    end

    if isfield(options, 'colors'); obj.fig_options_.colors = options.colors; else
        obj.fig_options_.colors = 'r';
    end

end
