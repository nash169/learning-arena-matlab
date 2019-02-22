clear; close all; clc;

%% Load demos
load 2attracts_simple.mat;
demo = DataStruct.demo;
demo_struct = DataStruct.demo_struct;
% demo = ReducedData(demo, 10);

%% Process data
proc_options = struct('center_data', false,...
                      'tol_cutting', 1.,...
                      'dt', 0.1...
                      );
[X, targets] = ProcessDemos(demo, 2, demo_struct, proc_options);
x = X(1:2,:)';
v = X(3:4,:)';
[m,~] = size(x);

%% Draw data
draw_options = struct('plot_pos', true,...  % Draw the demonstrated positions
                      'plot_vel', false...  % Draw the demonstrated velocities
                      );
% fig_pos = DrawData(X, targets, draw_options);

%% Build Graph

% Sigma estimation based on sample frequency
dt = 0.1;
max_v = max(vecnorm(v,2,2));
max_d = max_v*dt;
scale = 1.5;
sigma = scale*(max_d/3);
% max_d = 5;

% Define global kernel options
kpar = struct('sigma', sigma,...
              'r', 3*sigma,...
              'sigma_vel', 0.01,...
              'sigma_attract', 1,...
              'lambda', 30,... *1/3
              'degree', 1.,...
              'const', 1.);
          
% Build locality check graph matrix
rbf_c = Kernels('gauss_compact', kpar);

graph_options = struct('conntype','threshold', ... % epsilon - threshold - n-nearest
                       'eps', 0.6, ...
                       'thr', 0, ...
                       'n_nearest', 8, ...
                       'isnan_value', 0, ...
                       'kernel', rbf_c, ...
                       'kparam', kpar, ...
                       'plot_graph', false, ...
                       'nodes', x,...
                       'plot_matrix', false, ...
                       'matrix_type', 'sgn_mat' ... % sgn_mat - real_mat
                       );

W1 = GraphBuild2(graph_options, x, x);

% Build directionality check graph matrix
ck_cross = Kernels('cosine_cross');

graph_options.thr = 0.99;
graph_options.kernel = ck_cross;

W2 = GraphBuild2(graph_options, x, x, v);


% Build continuity check graph matrix
ck = Kernels('cosine');

graph_options.thr = 0.6;
graph_options.isnan_value = 1;
graph_options.kernel = ck;

W3 = GraphBuild2(graph_options, v, v);


% Draw final graph
GraphDraw(x, W1.*W2.*W3);


%% Build matrices
gram_options = struct('norm', false,...
                      'vv_rkhs', false);


K0 = GramMatrix(rbf_c, gram_options, x, x);
K0_mod = K0>0;
% figure
% imagesc(K0_mod)
% colorbar
% [nx,ny] = size(K0);
% set(gca,'xtick', linspace(0.5,nx+0.5,nx+1), 'ytick', linspace(0.5,ny+.5,ny+1));
% set(gca,'xgrid', 'on', 'ygrid', 'on', 'gridlinestyle', '-', 'xcolor', 'k', 'ycolor', 'k');

% GraphDraw(x, K0_mod);

K1 = GramMatrix(ck_cross, gram_options, x, x, v);
K1_mod = K1>0.99;
% figure
% imagesc(K1_mod)
% colorbar
% [nx,ny] = size(K1);
% set(gca,'xtick', linspace(0.5,nx+0.5,nx+1), 'ytick', linspace(0.5,ny+.5,ny+1));
% set(gca,'xgrid', 'on', 'ygrid', 'on', 'gridlinestyle', '-', 'xcolor', 'k', 'ycolor', 'k');

% GraphDraw(x, K1_mod);

K2 = GramMatrix(ck, gram_options, v, v);
K2(isnan(K2)) = 1;
K2_mod = K2>0.6;
% figure
% imagesc(K2)
% colorbar
% [nx,ny] = size(K2);
% set(gca,'xtick', linspace(0.5,nx+0.5,nx+1), 'ytick', linspace(0.5,ny+.5,ny+1));
% set(gca,'xgrid', 'on', 'ygrid', 'on', 'gridlinestyle', '-', 'xcolor', 'k', 'ycolor', 'k');

% GraphDraw(x, K2_mod);


GraphDraw(x, K1_mod.*K0_mod.*K2_mod);

% e_k = Kernels('euclid_dist');
% G = GramMatrix(e_k, gram_options, x,x);
% S = K1_mod.*K0_mod.*G;
% 
% D = ShortestPath(S);
% 
% GraphDraw(x, D);
