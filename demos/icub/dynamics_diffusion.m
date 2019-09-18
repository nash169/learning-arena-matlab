clear; close all; clc;

%% Load learned demos
ds1 = load('ds_linear1_3d.mat');
ds2 = load('ds_linear2_3d.mat');

demo = [ds1.demo; ds2.demo];
demo_struct = ds1.demo_struct;
dim = 3; %2

%% Process joints data
preprocess_options = struct('center_data', false,...
                            'calc_vel', false, ...
                            'tol_cutting', 0.01, ...
                            'smooth_window', 25 ... % 'reduce_factor', 2, ...
                            );
                        
[X, ~, ~, T, ~] = ProcessDemos(demo, demo_struct, dim, preprocess_options);

%% Draw data
draw_options = struct('plot_pos', true, ...
                      'plot_vel', true ...
                      );
                  
fig_pos = DrawData(X, T, draw_options);

x_i = X(1:dim, :)';
v_i = X(dim+1:2*dim, :)';
t_i = X(end-2,:)';
dt_i = X(end-1,:)';
l_i = ones(size(x_i,1),1); % l_i = X(end,:)';

%% Build Graph (from now only joints are considered)
v_norm = v_i./vecnorm(v_i,2,2);
v_norm(isnan(v_norm)) = 0;
[m,~] = size(x_i);

max_d = max(vecnorm(v_i,2,2).*dt_i);
scale = 1.5;% 1.5;
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
[W1, D1] = GraphBuild2(graph_options, x_i, x_i);

% Build directionality check graph  matrix
graph_options.thr = 0.99;
graph_options.isnan_value = 1;
graph_options.kernel = Kernels('cosine_cross');
[W2, D2] = GraphBuild2(graph_options, x_i, x_i, v_i);

% Build continuity check graph matrix
graph_options.thr = 0.9;
graph_options.isnan_value = 1;
graph_options.kernel = Kernels('cosine');
[W3, D3] = GraphBuild2(graph_options, v_i, v_i);

W =  W1.*(W2+W2');
% GraphDraw(x_i, W1.*W2.*W3);
% figure
% imagesc(W1);
% figure
% imagesc(W);

%% Building Gram Matrix
t = 0.5; % Time for the heat kernel.

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

%% Building Affinity, Laplacian... matrices
alpha = 1;

% Affinity matrix - Apply Graph to Gram matrix
S = K.*W;

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

%% Solve Eigensystem
[eigvect_r, lambda, eigvect_l] = eig(M_alpha);
[eig_sort, eig_index] = sort(diag(lambda),'descend');
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
%% Spectrum
np = 8;
l = diag(lambda);
figure
plot(1:np,l(1:np),'-o')

%% Scatter
labels = X(end,:);
colors = hsv(length(unique(labels)));
alpha_s = eigvect_r(:,3:end);

% h=gcf;
figure
for i = 1:np
   for j = 1:np
      subplot(np,np,i+np*(j-1))
      scatter(alpha_s(:,i),alpha_s(:,j),20,colors(labels,:),'filled','MarkerEdgeColor',[0 0 0]);
      grid on;
   end
end