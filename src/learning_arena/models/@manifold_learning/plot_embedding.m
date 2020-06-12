function fig = plot_embedding(obj, space, colors, fig)
    % Plot embedding
    if nargin < 2; space = [1, 2]; end
    if nargin < 4; fig = figure; else; figure(fig); end

    if nargin > 2
        obj.colors_ = colors;
    elseif ~obj.is_colors_
        obj.set_colors(linspace(1, 10, obj.m_));
    end

    assert(length(space) ~= 1, '1D?')
    U = obj.embedding(space);

    if length(space) == 2
        scatter(U(:, 1), U(:, 2), 40, obj.colors_, 'filled');
        % scatter(U(:, 1), U(:, 2), 40, obj.colors_,  'filled',  'MarkerEdgeColor', [0 0 0]);
        title(['Embedding space of eigenvectors:', num2str(space(1)), ' and ', num2str(space(2))]);
    else
        % scatter3(U(:, 1), U(:, 2), U(:, 3), 40, obj.colors_, 'filled');
        scatter3(U(:, 1), U(:, 2), U(:, 3), 40, obj.colors_, 'filled', 'MarkerEdgeColor', [0 0 0]);
        title(['Embedding space of eigenvectors:', num2str(space(1)), ', ', num2str(space(2)), ' and ', num2str(space(3))]);
    end

    grid on;
end
