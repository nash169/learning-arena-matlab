function fig = plot(obj, options, fig, varargin)
    % Surface plot of the kernel expansion.
    if nargin < 3; fig = figure; else; figure(fig); end

    if nargin < 2; options = struct; end
    obj.fig_options(options);

    if ~obj.is_grid_; obj.set_data(obj.fig_options_.res, obj.fig_options_.grid{:}); end

    psi = obj.expansion;

    switch obj.d_
        case 1
            plot(obj.grid_{1}, psi, varargin{:});
        otherwise
            dim = num2cell(size(obj.grid_{1}));
            Psi = reshape(psi, dim{:});
            surf(obj.grid_{1}(:, :, 1), obj.grid_{2}(:, :, 1), ...
                Psi(:, :, 1))
    end

end
