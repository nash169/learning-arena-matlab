function fig = plot_similarity(obj)
    % Plot similarity matrix
    S = obj.similarity;
    fig = figure;
    pcolor([S, zeros(size(S, 1), 1); zeros(1, size(S, 2) + 1)])
    title('Similarity matrix');
    axis image
    axis ij
    colorbar
end
