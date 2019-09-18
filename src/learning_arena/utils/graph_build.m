function G = graph_build(data, varargin)
%GRAPH_BUILD2 Summary of this function goes here
%   Available parameters: r, k, fun
params = struct;
if nargin > 1 
    for i = 1 : 2 : length(varargin)
        params.(varargin{i}) = varargin{i+1}; 
    end
end
if ~isfield(params, 'type'); params.type = 'eps-neighborhoods'; end

[m, ~] = size(data);

switch params.type
    case 'eps-neighborhoods'
        if isfield(params, 'fun')
            norm_sq = params.fun(data,data);
        else
            norm_sq = sum((repmat(data, m, 1) - repelem(data, m, 1)).^2,2);
        end
        
        if ~isfield(params, 'r'); params.r = mean(norm_sq); end
        
        G = reshape(norm_sq, m, m);
        G = G < params.r;
        
    case 'k-nearest'
        if ~isfield(params, 'k'); params.k = ceil(0.25*m); end
        if isfield(params, 'fun')
            dist = params.fun;
        else
            dist = 'euclidean';
        end
        
        [mIdx,~] = knnsearch(data, data, 'K', params.k, 'Distance', dist);
        G = digraph(repelem(mIdx(:,1), params.k, 1),c_reshape(mIdx, [], 1));
        G = adjacency(G);     
        
    otherwise
        error('Case not present')
end

end
