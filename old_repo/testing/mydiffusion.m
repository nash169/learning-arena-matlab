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
v_i = X(3:4,:)';
% v_i = X(3:4,:)'./vecnorm(X(3:4,:)',2,2);
% v_i(isnan(v_i)) = 0;
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

%% Building Transport Matrix
t = 50; % Time for the heat kernel.

kpar_mat = struct('sigma', sqrt(t/2), ...
                  'r', 30, ...
                  'rot', [0 1;-1 0], ...
                  'lambda', 0.5, ...
                  'lyap_type', 'transpose' ...
                 );
             
k = Kernels2('gauss', kpar_mat);
k_lyap = Kernels2('gauss_lyapunov', kpar_mat);
k_vel = Kernels2('gauss_anisotr_vel', kpar_mat);

gram_options = struct('norm', false,...
                      'vv_rkhs', false);
                  
alpha = 0;

K = GramMatrix(k, gram_options, x_i, x_i);
K2 = GramMatrix(k_vel, gram_options, x_i, x_i, v_i);

% Affinity matrix - Apply Graph to Gram matrix
S = K2;

% Remove diagonal
% S = S.*~eye(size(S));

% Normalize the "distance" matrix
% Z = (W.*Z);
% Z = max(Z, Z');
% max_dist = max(max(Z));
% S = nthroot(S,max_dist);

% Symmetrize the matrix
% S = max(S, S');

% Degree matrix
D = diag(sum(S,2));

% Symmetric normalized kernel matrix
S_alpha = inv(D^alpha)*S*inv(D^alpha);

% Degree "alpha" matrix
D_alpha = diag(sum(S_alpha,2));

% Markov chain "alpha" matrix
M_alpha = D_alpha\S_alpha;

%% Extract eigenvectors
num_eigen = 15;

[eigvect_r, lambda, eigvect_l] = eig(S);
[eig_sort, eig_index] = sort(diag(lambda),'descend');
lambda = diag(eig_sort);
eigvect_r = eigvect_r(:,eig_index);
eigvect_l = eigvect_l(:,eig_index);

eigenData = struct('xtrain', x_i, ...
                    'alphas', eigvect_r(:,1:end), ...
                    'eigens', diag(lambda), ...
                    'mappedData', eigvect_r(:,1:end)', ...
                    'kernel', k ...
                   );
               
%% Plot results
plot_options = struct('xlims', [0 100],...        % 1x2 vector  
                      'ylims', [0 100],...        % 1x2 vector
                      'resoultion', 'medium',...  % ['low','medium','high']
                      'type', '2D',...            % ['2D','3D']
                      'components', 1:4,...       % 1xn vector or scalar
                      'plot_data', true,...       % [true,false]
                      'labels', X(end,:),...      % 1xm vector 
                      'plot_stream', false,...    % [true,false]
                      'plot_eigens', false,...    % [true,false]
                      'plot_mapped', false,...     % ['2D','3D',false]
                      'plot_manifold', false,...  % ['2D','3D',false]
                      'plot_projData', true...   % [true,false]
                      );
                  
h = PlotEigenfun(eigenData, plot_options);