% Now I want to separate the process of building the affinity in two steps:
% 1. Building the graph
% 2. Calculate the Gram matrix using the heat kernel
% This process can be achieved in one step building the Gram matrix using
% directly the compact support heat kernel proposed by Belkin.
% As far as I understand if we want to achieve the same distribution it's
% necessary to use the eps-neighborhoods approach instead of the k-nearest
% one. This will also generate automatically a symmetric matrix that is not
% case if the k-nearest approach is used. In addition every edge is
% weighted instead of having value equal to 1 or 0 depending on the
% presence of an edge. It is unclear if the must be removed  diagonal (node
% not self connected) and MOREOVER if it is necessary to normalize the
% "distance" matrix before applying the heat kernel on it. It seems that in
% this case the result is not much sensitive to changings of the heat
% kernel hyperparameter.
clear; close all; clc;

%% Load demos
ds = load('2as_3t.mat');
ds_dim = 2;
% demo = ReducedData(demo, 10); %25

%% Process data
preprocess_options = struct('center_data', false,...
                            'calc_vel', true, ...
                            'tol_cutting', 0.01, ...
                            'smooth_window', 25 ...
                            );
[X, ~, ~, targets, ~] = ProcessDemos(ds.DataStruct.demo, ds.DataStruct.demo_struct, ds_dim, preprocess_options);

x_i = X(1:ds_dim, :)';
v_i = X(ds_dim+1:2*ds_dim, :)';
t_i = X(end-2,:)';
dt_i = X(end-1,:)';
l_i = X(end,:)';

% v_norm = v_i./vecnorm(v_i,2,2);
% v_norm(isnan(v_norm)) = 0;
% [m,~] = size(x_i);

%% Draw data
draw_options = struct('plot_pos', true, ...  % Draw the demonstrated positions
                      'plot_vel', false ...  % Draw the demonstrated velocities
                      );
fig_pos = DrawData([x_i'; v_i'; t_i'; l_i'], targets, draw_options);

%% Build Graph
% Sigma estimation based on sample frequency
v_norm = v_i./vecnorm(v_i,2,2);
v_norm(isnan(v_norm)) = 0;
[m,~] = size(x_i);

max_d = max(vecnorm(v_i,2,2).*dt_i);
scale = 1.5;
sigma = scale*(max_d/3);


% Define global kernel options
kpar_graph = struct('sigma', sigma,...
                    'r', 3*sigma,...
                    'sigma_vel', 0.01,...
                    'sigma_attract', 1,...
                    'lambda', 30,... *1/3
                    'degree', 1.,...
                    'const', 1.);
          
% Build locality check graph matrix
graph_options = struct('conntype','threshold', ... % epsilon - threshold - n-nearest
                       'eps', 0.6, ...
                       'thr', 0, ...
                       'n_nearest', 8, ...
                       'isnan_value', 0, ...
                       'kernel', Kernels('gauss_compact', kpar_graph), ...
                       'kparam', kpar_graph, ...
                       'plot_graph', false, ...
                       'nodes', x_i,...
                       'plot_matrix', false, ...
                       'matrix_type', 'sgn_mat' ... % sgn_mat - real_mat
                       );
[W1, D1] = GraphBuild(graph_options, x_i, x_i);

% Build directionality check graph matrix
graph_options.thr = 0.8;
graph_options.isnan_value = 1;
graph_options.kernel = Kernels('cosine_cross');
W2 = GraphBuild(graph_options, x_i, x_i, v_i);

% Build continuity check graph matrix
graph_options.thr = 0.9;
graph_options.isnan_value = 1;
graph_options.kernel = Kernels('cosine');
[W3, D3] = GraphBuild(graph_options, v_i, v_i);

W = W1.*W3;
% GraphDraw(x_i, W);

%% Building Gram Matrix
t = 32; % Time for the heat kernel.

kpar_mat = struct('sigma', sqrt(t/2), ...
                  'r', 30, ...
                  'rot', [0 1;-1 0], ...
                  'lambda', 50, ...
                  'lyap_type', 'transpose', ...
                  'epsilon', 2 ...
                 );           
[rbf, drbf, d2rbf] = Kernels('gauss', kpar_mat);

gram_options = struct('norm', false,...
                      'vv_rkhs', false);
K = GramMatrix(rbf, gram_options, x_i, x_i);

% k_dir_vel = Kernels2('gauss_direct_vel', kpar_mat);
% S = GramMatrix(rbf, gram_options, x_i, x_i, v_norm, v_norm);

%% Building Affinity, Laplacian... matrices
alpha = 1;

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

% Degree "alpha" matrix0.
D_alpha = diag(sum(S_alpha,2));

% Markov chain "alpha" matrix
M_alpha = D_alpha\S_alpha;

% Infinitesimal generator of the Markov Chain
L_alpha = (eye(size(M_alpha)) - M_alpha)/t;

% Laplacian "classic" matrix
L = eye(size(S))-D\S;
% L(isnan(L)) = 0; D(isnan(D)) = 0;
% L(isinf(L)) = 0; D(isinf(D)) = 0;

% Markov chain "classic" matrix
M = D\S;

%% Solve Eigensystem
num_eigen = 15;
% [alpha, lambda] = eigs(L,num_eigen+1,'smallestabs');

[eigvect_r, lambda, eigvect_l] = eig(L_alpha);
[eig_sort, eig_index] = sort(diag(lambda),'ascend');
lambda = diag(eig_sort);
eigvect_r = eigvect_r(:,eig_index);
eigvect_l = eigvect_l(:,eig_index);

eigenData = struct('xtrain', x_i, ...
                    'alphas', eigvect_r(:,1:end), ...
                    'eigens', diag(lambda), ...
                    'mappedData', eigvect_r(:,1:end)', ...
                    'gram', K, ...
                    'kernel', rbf, ...
                    'kernel_dev', drbf ...
                   );
               
%% Plot Eigenfucntions
plot_options = struct('xlims', [0 100],...        % 1x2 vector  
                      'ylims', [0 100],...        % 1x2 vector
                      'resoultion', 'medium',...  % ['low','medium','high']
                      'type', '2D',...            % ['2D','3D']
                      'components', 1:8,...       % 1xn vector or scalar
                      'plot_data', true,...       % [true,false]
                      'labels', X(end,:),...      % 1xm vector 
                      'plot_stream', false,...    % [true,false]
                      'plot_eigens', false,...    % [true,false]
                      'plot_mapped', false,...     % ['2D','3D',false]
                      'plot_manifold', false,...  % ['2D','3D',false]
                      'plot_projData', true...   % [true,false]
                      );
                  
PlotEigenfun(eigenData, plot_options);

%% Scatter
labels = X(end,:);
colors = hsv(length(unique(labels)));
alpha_s = eigvect_r(:,3:end);

np = 8;
h=gcf;
for i = 1:np
   for j = 1:np
      subplot(np,np,i+np*(j-1))
      scatter(alpha_s(:,i),alpha_s(:,j),20,colors(labels,:),'filled','MarkerEdgeColor',[0 0 0]);
      grid on;
   end
end

% set(h,'PaperOrientation','landscape');
% set(h,'PaperUnits','normalized');
% set(h,'PaperPosition', [0 0 1 1]);
% print(h, '-dpdf', 'scatterplot.pdf');

%% Build Lyapunov Function

% [dynamics] = SearchAttractors(x_i,v_i,lambda,eigvect_r,eigvect_l);
% 
% x_res = 100; y_res = 100;
% xs = linspace(0, 100, x_res);
% ys = linspace(0, 100, y_res);
% [Xs, Ys] = meshgrid(xs,ys);
% x = [Xs(:),Ys(:)];
% 
% kpar_rbf = struct('sigma', 0.1); %.05
% 
% kpar_lyap = struct('sigma', 5.5, ...
%                   'lambda', 5, ...
%                   'rot', [0 1;-1 0], ...
%                   'lyap_type', 'transpose', ...
%                   'sigma_attract', .03 ...
%                   );
%%
% [V, dV] = RebuildLyap(x, 2, dynamics(2,:), kpar_lyap);

% k_rbf = Kernels2('gauss', kpar_rbf);
% [k_lyap, dk_lyap] = Kernels2('gauss_anisotr_lyap', kpar_lyap);

% dV = 0;
% for i = 1: size(dynamics{1,1},1)
%     dV = dV + (1+10*k_rbf(dynamics{1,4}(i,:),dynamics{1,6})) ...
%               *dk_lyap(dynamics{1,1}(i,:),x,dynamics{1,2}(i,:));
% end

% f = 0; df = 0;
% for i = 1:size(dynamics{1,1},1)
%    f = f +  k(dynamics{1,1}(i,:),x,dynamics{1,4}(i,:),[-0.00338840682393591,-0.00176517914315017]);
%    f = f + (1+param.lambda*rbf2(dynamics{1,4}(i,:),dynamics{1,6}))*rbf(dynamics{1,1}(i,:),x)*abs(dynamics{1,5}(i));
%    f = f + (1+10*rbf2(dynamics{1,4}(i,:),dynamics{1,6}))*k4(dynamics{1,1}(i,:),x,test(i,:))*norm(test(i,:));
%    f = f + (1+10*k_rbf(dynamics{1,4}(i,:),dynamics{1,6}))*k_lyap(dynamics{1,1}(i,:),x,dynamics{1,2}(i,:));
%    df = df + (1+10*k_rbf(dynamics{1,4}(i,:),dynamics{1,6}))*dk_lyap(dynamics{1,1}(i,:),x,dynamics{1,2}(i,:));
% end
% 
% for i = 1:size(dynamics{2,1},1)
%    f = f +  k(dynamics{1,1}(i,:),x,dynamics{1,4}(i,:),[-0.00338840682393591,-0.00176517914315017]);
%    f = f + (1+param.lambda*rbf2(dynamics{2,4}(i,:),dynamics{2,6}))*rbf(dynamics{2,1}(i,:),x);
%    f = f + k4(dynamics{2,1}(i,:),x,dynamics{2,2}(i,:));
% end

% figure
% hold on;
% contourf(Xs,Ys,reshape(V,100,100),20)
% scatter(x_i(:,1),x_i(:,2),20,colors(labels,:),'filled','MarkerEdgeColor',[0 0 0]);
% streamslice(Xs, Ys, reshape(dV(:,1),100,100), reshape(dV(:,2),100,100));
% colormap hot
% axis square
% colorbar
% 
% figure
% surf(Xs,Ys,reshape(V,100,100))
% colormap hot
% axis square
% 
% [AttractErr,LyapErr,LyapErr_quad] = MetricEval(xs, ys, 0.9, dynamics(2,:), kpar_lyap);

%% Single plot
% fig_map = figure;
% scatter(eigvect_r(:,4),eigvect_r(:,5),20,colors(labels,:),'filled','MarkerEdgeColor',[0 0 0]);
% grid on;