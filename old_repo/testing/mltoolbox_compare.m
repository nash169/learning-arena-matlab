clear; close all; clc;

%% Load demos
load 1attracts_simple.mat;
demo = DataStruct.demo;
demo_struct = DataStruct.demo_struct;
% demo = ReducedData(demo, 25); %25

%% Process data
proc_options = struct('center_data', false,...
                      'tol_cutting', 1.,...
                      'dt', 0.1...
                      );
[X, targets] = ProcessDemos(demo, 2, demo_struct, proc_options);
x_i = X(1:2,:)';
v_i = X(3:4,:)';
[m,~] = size(x_i);

% x_i = x_i(1:136,:);
% v_i = v_i(1:136,:);
% x_i = x_i(1:284,:);
% v_i = v_i(1:284,:);
% x_i = x_i(1:394,:);
% v_i = v_i(1:394,:);

% X(5,85:156) = 2;
% X(5,156:end) = 3;

% X(5,99:167) = 2;
% X(5,168:239) = 3;
% X(5,240:307) = 4;
% X(5,308:396) = 5;
% X(5,396:end) = 6;

%% Draw data
draw_options = struct('plot_pos', true,...  % Draw the demonstrated positions
                      'plot_vel', false...  % Draw the demonstrated velocities
                      );
fig_pos = DrawData(X, targets, draw_options);

%% Problem Data
num_eigen = 15;
num_neighboors = 6;
sigma = 5;
kpar_mat = struct('sigma', sigma);   
[rbf, drbf, d2rbf] = Kernels('gauss', kpar_mat);

%% Compute Laplacian Eigenmap with MLToolbox
[mappedX, mapping] = compute_mapping(x_i, 'LaplacianEigenmaps', num_eigen, num_neighboors, sigma);
eigenData1 = struct('xtrain', x_i, ...
                    'alphas', mappedX, ...
                    'eigens', mapping.val, ...
                    'mappedData', mappedX', ...
                    'gram', mapping.K, ...
                    'kernel', rbf, ...
                    'kernel_dev', drbf ...
                   );

%% Compute Laplacian Eigenmap with my toolbox
% Graph
graph_options = struct('conntype','n-nearest', ... % epsilon - threshold - n-nearest
                       'n_nearest', num_neighboors+1, ...
                       'plot_graph', true, ...
                       'nodes', x_i,...
                       'plot_matrix', false, ...
                       'matrix_type', 'sgn_mat' ... % sgn_mat - real_mat
                      );                 
[W, Z] = GraphBuild2(graph_options, x_i, x_i);
Z = (W.*Z);
Z = max(Z, Z');
max_dist = max(max(Z));

% Gram Matrix
gram_options = struct('norm', false,...
                      'vv_rkhs', false);
K = GramMatrix(rbf, gram_options, x_i, x_i);

% Affinity matrix
S = K.*W;                    % Apply Graph to Gram matrix
% S = S.*~eye(size(S));        % Remove diagonal
% S = nthroot(S,max_dist);     % Normalize the matrix
S = max(S, S');              % Symmetrize the matrix

% S = S.^0.1;

% Degree and Laplacian Matrix
D = diag(sum(S,2));
L = eye(size(S))-D\S;
L(isnan(L)) = 0; D(isnan(D)) = 0;
L(isinf(L)) = 0; D(isinf(D)) = 0;

% S = inv(D)*S*inv(D);
% D = diag(sum(S,2));
% L = (eye(size(S))-D\S)/(2*sigma^2);

% Eigenvalue decomposition
[alpha, lambda] = eigs(L,num_eigen+1,'smallestabs');

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
                      'plot_stream', false,...     % [true,false]
                      'plot_eigens', false,...    % [true,false]
                      'plot_mapped', '3D',...    % ['2D','3D',false]
                      'plot_manifold', false,...  % ['2D','3D',false]
                      'plot_projData', false...   % [true,false]
                      );
                  
PlotEigenfun(eigenData1, plot_options);


labels = X(end,:);
colors = hsv(length(unique(labels)));

% np = 10;
% figure
% for i = 1:np
%    for j = 1:np
%       subplot(np,np,i+np*(j-1))
%       scatter(alpha(:,i),alpha(:,j),20,colors(labels,:),'filled','MarkerEdgeColor',[0 0 0]);
%       grid on;
%    end
% end

%% Plot maps
fig_map = figure;
scatter(alpha(:,2),alpha(:,3),20,colors(labels,:),'filled','MarkerEdgeColor',[0 0 0]);

%%
figure
scatter3(alpha(:,2),alpha(:,3),alpha(:,4),20,colors(labels,:),'filled','MarkerEdgeColor',[0 0 0]);