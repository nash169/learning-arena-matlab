function fig = plot(obj, colors, fig)
    % Plot embedding
    if nargin < 3; fig = figure; else; figure(fig); end

    if nargin > 1
        obj.colors_ = colors;
    elseif ~obj.is_colors_
        obj.set_colors(linspace(1, 10, obj.m_));
    end

    U = obj.embedding;

    if size(U,2) == 2
        % scatter(U(:, 1), U(:, 2), 40, obj.colors_, 'filled');
        scatter(U(:, 1), U(:, 2), 40, obj.colors_,  'filled',  'MarkerEdgeColor', [0 0 0]);
        title('Corrected embedding space');
    else
        %         scatter3(U(:, 1), U(:, 2), U(:, 3), 40, obj.colors_, 'filled');
        scatter3(U(:, 1), U(:, 2), U(:, 3), 40, obj.colors_,  'filled',  'MarkerEdgeColor', [0 0 0]);
        title('Corrected embedding space');
    end

    grid on;
end
