function G = graph_build(data, varargin)
    %GRAPH_BUILD2 Summary of this function goes here
    %   Available parameters: r, k, fun

    % Init parameters structure
    params = struct;

    % Read options if available
    if nargin > 1

        for i = 1:2:length(varargin)
            params.(varargin{i}) = varargin{i + 1};
        end

    end

    % Set default graph build method
    if ~isfield(params, 'type'); params.type = 'eps-neighborhoods'; end

    % Size dataset
    [m, ~] = size(data);

    switch params.type
        case 'eps-neighborhoods'

            % Distance metric
            if isfield(params, 'fun')
                norm_sq = params.fun(data, data);
            else
                norm_sq = sum((repmat(data, m, 1) - repelem(data, m, 1)).^2, 2);
                % norm_sq = vecnorm(repmat(data, m, 1) - repelem(data, m, 1),2,2); % less performance
            end

            % Threshold
            if ~isfield(params, 'r'); params.r = mean(norm_sq); end

            % Build graph
            % G = sparse(repmat((1:m)', m, 1), repelem((1:m)', m, 1), norm_sq <= params.r);
            G = reshape(norm_sq, m, m);
            G = G <= params.r;
            G = sparse(G);

        case 'k-nearest'
            % Number of neighborhoods
            if ~isfield(params, 'k'); params.k = ceil(0.25 * m); end

            % Distance metric
            if isfield(params, 'fun')
                dist = params.fun;
            else
                dist = 'euclidean';
            end

            [mIdx, ~] = knnsearch(data, data, 'K', params.k, 'Distance', dist);
            G = digraph(repelem((1:m)', params.k, 1), c_reshape(mIdx, [], 1));

            G = adjacency(G);
            % G = sparse(G.Edges.EndNodes(:, 1), G.Edges.EndNodes(:, 2), 1);

        otherwise
            error('Case not present')
    end

end
