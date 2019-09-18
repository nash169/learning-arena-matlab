function [W, D] = GraphBuild2(options, varargin)
%GRAPHBUILD Summary of this function goes here
%   Detailed explanation goes here

% Cheking connection method options
if isfield(options,'conntype')
    connType = options.conntype;
    switch connType
        case 'epsilon' % epsilon-neighborhoods method
            if isfield(options,'eps')
                eps = options.eps;
            else
                error('Define epsilon value (eps)');
            end
            
        case 'threshold'
            if isfield(options,'thr')
                thr = options.thr;
            else
                error('Define threshold value (thr)');
            end
            
        case 'n-nearest' % n nearest neighborhoods method
            if isfield(options,'n_nearest')
                n_nearest = options.n_nearest;
            else
                error('Define number of nearest neighborhoods (n_nearest)');
            end
            
        otherwise
            error('Define connection method (conntype)');
    end
else
    error('Connection type not defined');
end

% Check isnan value to set
if isfield(options,'isnan_value')
    isnan_value = options.isnan_value;
else
    isnan_value = 0;
end

% Checking kernel options
if isfield(options,'kernel')
    if isa(options.kernel,'function_handle')
        f = options.kernel;
    else
        if isfield(options,'kparam')
            f = Kernels(option.kernel, option.kparam);
        else
            error('Define kernel parameteres (kparam)');
        end
    end
else
    f = Kernels('euclid_dist');
end

% Cheking graph & matrix plot options
if isfield(options,'plot_graph')
    plot_graph = options.plot_graph;
    if isfield(options,'nodes')
        nodes = options.nodes;
    else
        error('Define nodes for plotting the graph (nodes)');
    end
else
    plot_graph = false;
end

if isfield(options,'plot_matrix')
    plot_matrix = options.plot_matrix;
    if isfield(options, 'matrix_type')
        matrix_type = options.matrix_type;
    else
        matrix_type = 'sgn_mat';
    end
else
    plot_matrix = false;
end


gram_options = struct('norm', false,...
                      'vv_rkhs', false);
                  
D = GramMatrix(f, gram_options, varargin{:});
D(isnan(D)) = isnan_value;

switch connType
    case 'epsilon' 
        W = D < eps;
        
    case 'threshold'
        W = D > thr;
        
    case 'n-nearest'
        [~,index] = sort(D, 2, 'ascend');
        W = zeros(size(D));
        idx = sub2ind(size(W), ...
                      repmat((1:size(W,1))',1,n_nearest), ...
                      index(:,1:n_nearest));
        W(idx) = true;
        
    otherwise
        error('Error');
end

if plot_graph
    GraphDraw(nodes, W);
end

if plot_matrix
    switch matrix_type
        case 'sgn_mat'
            GraphMatrix(W);
            
        case 'real_mat'
            GraphMatrix(D);
    end
end

end


