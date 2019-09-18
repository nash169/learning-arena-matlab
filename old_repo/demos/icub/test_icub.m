clear; close all; clc;

%% Load demos
ds1 = load('iCub_dyn1.mat');
ds2 = load('iCub_dyn2.mat');

demo_joints = [ds1.demo_joints; ds2.demo_joints];
demo_obj_pos = [ds1.demo_obj_pos; ds2.demo_obj_pos];
demo_obj_rot = [ds1.demo_obj_rot; ds2.demo_obj_rot];
demo_struct = ds1.demo_struct;
  
joints_dim = 39;
obj_pos_dim = 3;
obj_rot_dim = 3;

%% Load learned demos
% ds1 = load('iCub_dyn1.mat');
% ds2 = load('icub_seds_demo2.mat');

% demo_joints = [ds1.demo_joints];
% demo_joints = [ds1.demo; ds2.demo];
% demo_struct = ds1.demo_struct;
plot_dim = 3;
% joints_dim = 3;

%% Process joints data
preprocess_options = struct('center_data', false,...
                            'calc_vel', true, ...
                            'tol_cutting', 1e-4, ... % 0.01
                            'smooth_window', 25, ...
                            'reduce_factor', 2 ...
                        );
                        
[X_joints, ~, ~, T_joints, ~] = ProcessDemos(demo_joints, demo_struct, joints_dim, preprocess_options);
[X_obj_pos, ~, ~, T_obj_pos, ~] = ProcessDemos(demo_obj_pos, demo_struct, obj_pos_dim, preprocess_options);
[X_obj_rot, ~, ~, T_obj_rot, ~] = ProcessDemos(demo_obj_rot, demo_struct, obj_rot_dim, preprocess_options);

%% Draw data
draw_options = struct('plot_pos', true, ...
                      'plot_vel', false ...
                      );
                  
pos_obj = DrawData(X_obj_pos, T_obj_pos, draw_options);

x_i = X_joints(1:joints_dim, :)';
v_i = X_joints(joints_dim+1:2*joints_dim, :)';
t_i = X_joints(end-1,:)';
l_i = X_joints(end,:)';
pos_joints = DrawData([x_i(:,1:3)'; v_i(:,1:3)'; t_i'; l_i'], T_joints(:,1:3), draw_options);


%% Build Graph (from now only joints are considered)
v_norm = v_i./vecnorm(v_i,2,2);
v_norm(isnan(v_norm)) = 0;
[m,~] = size(x_i);

dt = [];
for i = 1:max(l_i)
   t_tmp = t_i(l_i==i);
   dt = [dt; t_tmp(2:end)-t_tmp(1:end-1);0]; 
end

max_d = max(vecnorm(v_i,2,2).*dt);
scale = 1.5;
sigma = 0.5*scale*(max_d/3);

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
W1 = GraphBuild2(graph_options, x_i, x_i);

% Build directionality check graph matrix
graph_options.thr = 0.9;
graph_options.isnan_value = 1;
graph_options.kernel = Kernels('cosine_cross');
W2 = GraphBuild2(graph_options, x_i, x_i, v_i);

% Build continuity check graph matrix
graph_options.thr = 0.9;
graph_options.isnan_value = 1;
graph_options.kernel = Kernels('cosine');
W3 = GraphBuild2(graph_options, v_i, v_i);

W = W1.*(W2+W2');

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
labels = X_joints(end,:);
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