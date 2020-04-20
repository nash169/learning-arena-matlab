function fig = plot(obj, options, fig, varargin)
    %PLOT_EMBEDDING Summary of this function goes here
    %   Detailed explanation goes here
    if nargin < 3; fig = figure; else; figure(fig); hold on; end

    if nargin < 2; options = struct; end
    obj.fig_options(options);

    switch obj.dim_
        case 1

            if obj.fig_options_.embedding
                if ~obj.is_grid_; obj.set_data(obj.fig_options_.res, obj.fig_options_.grid{:}); end
                phi = obj.embedding;
                plot(phi{1}, phi{2}, varargin{:});
                hold on;
            end

            if obj.fig_options_.sample
                if ~obj.is_sampled_; error('Samples not present'); end
                scatter(obj.samples_{1}, obj.samples_{2}, 40, obj.fig_options_.colors, 'filled', 'MarkerEdgeColor', [0 0 0])
                axis equal
            end

        otherwise

            if obj.fig_options_.embedding
                if ~obj.is_grid_; obj.set_data(obj.fig_options_.res, obj.fig_options_.grid{:}); end
                phi = obj.embedding;
                surf(phi{1}, phi{2}, phi{3}, 'FaceAlpha', 0.5, varargin{:})
                shading interp
                axis equal
                hold on;
            end

            if obj.fig_options_.sample
                if ~obj.is_sampled_; error('Samples not present'); end
                scatter3(obj.samples_{1}, obj.samples_{2}, obj.samples_{3}, 40, obj.fig_options_.colors, 'filled', 'MarkerEdgeColor', [0 0 0])
                colorbar
                axis equal
            end

    end

end
