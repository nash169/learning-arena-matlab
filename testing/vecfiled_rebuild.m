clear; clc; close all;

%% Get Data
load 1attracts_simple.mat;
demo = DataStruct.demo;
demo_struct = DataStruct.demo_struct;
% demo = ReducedData(demo, 5);

% Process data
proc_options = struct('center_data', false,...
                      'tol_cutting', 1.,...
                      'dt', 0.1...
                      );
[X, targets] = ProcessDemos(demo, 2, demo_struct, proc_options);
x_i = X(1:2,:)';
% v_i = X(3:4,:)';
v_i = X(3:4,:)'./vecnorm(X(3:4,:)',2,2);
v_i(isnan(v_i)) = 0;
[m,~] = size(x_i);

% Draw data
X(3:4,:) = v_i';
draw_options = struct('plot_pos', true,...  % Draw the demonstrated positions
                      'plot_vel', false...  % Draw the demonstrated velocities
                      );
fig_pos = DrawData(X, targets, draw_options);

%% Building Graph
graph_options = struct('conntype','epsilon', ... % epsilon - threshold - n-nearest
                       'eps', 10, ...
                       'isnan_value', 0, ...
                       'plot_graph', true, ...
                       'nodes', x_i,...
                       'plot_matrix', false, ...
                       'matrix_type', 'sgn_mat' ... % sgn_mat - real_mat
                       );

[W, Z] = GraphBuild2(graph_options, x_i, x_i);

%% Building Gram Matrix
t = 0.1; % Time for the heat kernel.

kpar_mat = struct('sigma', sqrt(t/2), 'lyap_type', 'asymmetric');
k = Kernels2('gauss_lyapunov', kpar_mat);

gram_options = struct('norm', false,...
                      'vv_rkhs', false);

%% Build H_aa(1)                  
A = GramMatrix(k, gram_options, x_i, x_i, v_i, v_i);
P = diag(sum(A,2));
T = P\A/P;
P_1 = diag(sum(T,2));
H1_aa = P_1\T;

%% Build H_ss(1)
S = (A + A')/2;
Q = diag(sum(S,2));
V = Q\S/Q;
Q_1 = diag(sum(V,2));
H1_ss = Q_1\V;

%% Compute eigenvalues and right eigenvectors of H_ss(1)
[eigvect_r, lambda, eigvect_l] = eig(H1_ss);
[eig_sort, eig_index] = sort(diag(lambda),'descend');
lambda = diag(eig_sort);
eigvect_r = eigvect_r(:,eig_index);
eigvect_l = eigvect_l(:,eig_index);

%% Select the embedding
lambda = lambda(2:3,2:3);
eigvect_r = eigvect_r(:,2:3);

%% Rebuild vector field
R = (eigvect_r*lambda - H1_aa*eigvect_r)/2;
X(3:4,:) = R';
h = DrawData(X, targets, draw_options);
