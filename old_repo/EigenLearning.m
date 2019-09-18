clear; close all; clc;

%% Load demos
load 2attracts_simple.mat;
demo = DataStruct.demo;
demo_struct = DataStruct.demo_struct;
% demo = ReducedData(demo, 3); %25

%% Process data
proc_options = struct('center_data', false,...
                      'tol_cutting', 1.,...
                      'dt', 0.1...
                      );
[X, targets] = ProcessDemos(demo, 2, demo_struct, proc_options);
x_i = X(1:2,:)';
v_i = X(3:4,:)';
a_i = X(1:4,:)';
[m,~] = size(x_i);

%% Draw data
draw_options = struct('plot_pos', true,...  % Draw the demonstrated positions
                      'plot_vel', false...  % Draw the demonstrated velocities
                      );
fig_pos = DrawData(X, targets, draw_options);

%% Build Graph
% Sigma estimation based on sample frequency
dt = 0.1;
max_v = max(vecnorm(v_i,2,2));
max_d = max_v*dt;
scale = 1.5;
sigma = scale*(max_d/3);
% max_d = 5;

% Define global kernel options
kpar_graph = struct('sigma', sigma,...
                    'r', 3*sigma,...
                    'sigma_vel', 0.01,...
                    'sigma_attract', 1,...
                    'lambda', 30,... *1/3
                    'degree', 1.,...
                    'const', 1.);
          
% Build locality check graph matrix
rbf_c = Kernels('gauss_compact', kpar_graph);

graph_options = struct('conntype','threshold', ... % epsilon - threshold - n-nearest
                       'eps', 0.6, ...
                       'thr', 0, ...
                       'n_nearest', 8, ...
                       'isnan_value', 0, ...
                       'kernel', rbf_c, ...
                       'kparam', kpar_graph, ...
                       'plot_graph', false, ...
                       'nodes', x_i,...
                       'plot_matrix', false, ...
                       'matrix_type', 'sgn_mat' ... % sgn_mat - real_mat
                       );

W1 = GraphBuild2(graph_options, x_i, x_i);

% Build directionality check graph matrix
ck_cross = Kernels('cosine_cross');

graph_options.thr = 0.999;
graph_options.isnan_value = 1;
graph_options.kernel = ck_cross;

W2 = GraphBuild2(graph_options, x_i, x_i, v_i);


% Build continuity check graph matrix
ck = Kernels('cosine');

graph_options.thr = 0.8;
graph_options.isnan_value = 1;
graph_options.kernel = ck;

W3 = GraphBuild2(graph_options, v_i, v_i);

% Create & Draw final graph
W = W1; % eye(m) 
GraphDraw(x_i, W);

%% Build matrices
kpar_mat = struct('sigma', 5,...
                  'r', 3*5,...
                  'sigma_vel', 0.01,...
                  'sigma_attract', 1,...
                  'lambda', 30,... *1/3
                  'degree', 1.,...
                  'const', 1.);
           
[rbf, drbf, d2rbf] = Kernels('gauss', kpar_mat);

[rbf_v, drbf_v] = Kernels('gauss_vel', kpar_mat);
rbf_v = @(x,y) rbf_v(x,y,v_i);
drbf_v = @(x,y) drbf_v(x,y,v_i);

gram_options = struct('norm', false,...
                      'vv_rkhs', false);
   
csi = 20; % Scaling parameter 
K = GramMatrix(rbf, gram_options, x_i, x_i);
C = GramMatrix(ck, gram_options, v_i, v_i);
C(isnan(C)) = 1;
normed_vel = v_i./vecnorm(v_i,2,2);
normed_vel(isnan(normed_vel)) = 0;
G = ColVelMatrix(x_i, normed_vel, drbf, false);
S = K; %W % K.*W;
M = (G*G').*W;
D = diag(sum(S,2));
L = D-S;

%% Extract feauture
num_eigen = 4;

% Problem statement: A*v = lambda*B*v
A = D\S; % K; % D\S; % + csi*diag(sum(M,2))\M;
B = eye(m);

% Solver 'eigs'
[V_eigs,T_eigs] = eigs(A,B,num_eigen);
% Solver 'eig'
[V_eig,T_eig] = eig(A,B);
[eig_sort, eig_index] = sort(diag(T_eig),'descend');
T_eig = diag(eig_sort);
V_eig = V_eig(:,eig_index);
% Solver 'svd'
[V_svd,T_svd,U_svd] = svd(A);

eigenData = struct('xtrain', x_i, ...
                   'alphas', -V_eig, ...
                   'eigens', diag(T_eig), ...
                   'mappedData', sqrt(T_eig)*V_eig', ...
                   'gram', K, ...
                   'kernel', rbf, ...
                   'kernel_dev', drbf ...
                   );
               
%% Plot results
plot_options = struct('xlims', [0 100],...        % 1x2 vector  
                      'ylims', [0 100],...        % 1x2 vector
                      'resoultion', 'medium',...  % ['low','medium','high']
                      'type', '2D',...            % ['2D','3D']
                      'components', 1:2,...       % 1xn vector or scalar
                      'plot_data', true,...       % [true,false]
                      'labels', X(end,:),...      % 1xm vector 
                      'plot_stream', true,...     % [true,false]
                      'plot_eigens', false,...    % [true,false]
                      'plot_mapped', false,...    % ['2D','3D',false]
                      'plot_projData', true...   % [true,false]
                      );
PlotEigenfun(eigenData, plot_options);