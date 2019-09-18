function L = LaplacianWalk(X, eps, norm)
%LAPLACIANGRAPH Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
    norm = false;
end

% Build graph
graph_options = struct('conntype','eps-neighbor', ...
                       'epsilon', eps, ...
                       'plot_graph', true ...
                       ); 
W = GraphBuild(X, graph_options);

% Build kernel matrix 
par.sigma = sqrt(eps)/2;
k_heat = Kernels('gauss', par);
gram_options = struct('norm', false, 'vv_rkhs', false);
K = GramMatrix(k_heat, gram_options, X, X);

% Build weighted graph
K = K.*W;

% Build degree matrix
T = diag(sum(K,2));

if norm
    K = (T\K)/T;
    T = diag(sum(K,2));
end

L = (eye(size(X,1))-T\K)/eps;
end