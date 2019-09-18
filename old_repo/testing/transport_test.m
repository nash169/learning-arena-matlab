clear; close all; clc;

%% Get Data
load 2attracts_simple.mat;
demo = DataStruct.demo;
demo_struct = DataStruct.demo_struct;
% demo = ReducedData(demo, 10);

% Process data
proc_options = struct('center_data', false,...
                      'tol_cutting', 1.,...
                      'dt', 0.1...
                      );
[X, targets] = ProcessDemos(demo, 2, demo_struct, proc_options);
x_i = X(1:2,:)';
v_i = X(3:4,:)';
[m,~] = size(x_i);

% Draw data
draw_options = struct('plot_pos', true,...  % Draw the demonstrated positions
                      'plot_vel', false...  % Draw the demonstrated velocities
                      );
fig_pos = DrawData(X, targets, draw_options);

%% Building Graph
graph_options = struct('conntype','epsilon', ... % epsilon - threshold - n-nearest
                       'eps', 3, ...
                       'isnan_value', 0, ...
                       'plot_graph', true, ...
                       'nodes', x_i,...
                       'plot_matrix', false, ...
                       'matrix_type', 'sgn_mat' ... % sgn_mat - real_mat
                       );

[W, Z] = GraphBuild2(graph_options, x_i, x_i);

%% Building Gram Matrix
t = 0.5; % Time for the heat kernel.

kpar_mat = struct('sigma', sqrt(t/2));
[rbf, drbf, d2rbf] = Kernels('gauss', kpar_mat);

gram_options = struct('norm', false,...
                      'vv_rkhs', false);
K = GramMatrix(rbf, gram_options, x_i, x_i);

%% Building Affinity, Laplacian... matrices
alpha = 0;

% Affinity matrix - Apply Graph to Gram matrix
S = K.*W;

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


%% Solve Eigensystem
num_eigen = 15;
% [alpha, lambda] = eigs(L,num_eigen+1,'smallestabs');

[alpha, lambda] = eig(M_alpha^100);
[eig_sort, eig_index] = sort(diag(lambda),'descend');
lambda = diag(eig_sort);
alpha = alpha(:,eig_index);

eigenData2 = struct('xtrain', x_i, ...
                    'alphas', alpha(:,2:end), ...
                    'eigens', diag(lambda), ...
                    'mappedData', alpha(:,2:end)', ...
                    'gram', K, ...
                    'kernel', rbf, ...
                    'kernel_dev', drbf ...
                   );
               
%% Plot results
plot_options = struct('xlims', [0 100],...        % 1x2 vector  
                      'ylims', [0 100],...        % 1x2 vector
                      'resoultion', 'medium',...  % ['low','medium','high']
                      'type', '3D',...            % ['2D','3D']
                      'components', 1:4,...       % 1xn vector or scalar
                      'plot_data', true,...       % [true,false]
                      'labels', X(end,:),...      % 1xm vector 
                      'plot_stream', false,...    % [true,false]
                      'plot_eigens', false,...    % [true,false]
                      'plot_mapped', '3D',...     % ['2D','3D',false]
                      'plot_manifold', false,...  % ['2D','3D',false]
                      'plot_projData', false...   % [true,false]
                      );
                  
% PlotEigenfun(eigenData2, plot_options);

%% Scatter
labels = X(end,:);
colors = hsv(length(unique(labels)));
alpha_s = alpha(:,3:end);

np = 10;
figure
for i = 1:np
   for j = 1:np
      subplot(np,np,i+np*(j-1))
      scatter(alpha_s(:,i),alpha_s(:,j),20,colors(labels,:),'filled','MarkerEdgeColor',[0 0 0]);
      grid on;
   end
end