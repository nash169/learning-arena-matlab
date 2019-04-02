draw = false;

if draw
    DrawDemos;
else
    clear; close all; clc;
    load CurrentTest.mat;
end

demo = DataStruct.demo;
demo_struct = DataStruct.demo_struct;

%% Pre-porcessing options
process_options.tol_cutting = 1.;
process_options.dt = 0.1;

%% Draw
draw_options.plot_pos = true;
draw_options.plot_vel = false;
[X, targets] = ProcessDemos(demo, 2, demo_struct, process_options);
[fig_pos] = DrawData(X, targets, draw_options);

%% Separate Dynamics
counter = 1;
dynamics = struct(strcat('ds',num2str(counter)),demo(1));
dynamics.ds1 = {dynamics.ds1, demo{2}};
prev_dyn = 0;

for i = 3:length(demo)
    if counter ~= demo{i}(end,1)
        prev_dyn = i-1;
    end
    counter = demo{i}(end,1);
    dynamics.(strcat('ds',num2str(counter))){i-prev_dyn} = demo{i};    
end

%% SEDS options
K = 6;                        % Number of Gaussian funcitons
options.tol_mat_bias = 10^-6; % Small positive scalar to avoid instabilities in Gaussian kernel
options.display = 1;          % Displays the output of each iterations
options.tol_stopping=10^-10;  % Stoppping tolerance
options.max_iter = 500;       % Maximum number of iteration for the solver [default: i_max=1000]
options.objective = 'mse';    % use mean square error as criterion to optimize parameters of GMM

process_options.center_data = true;

%% Simulation options
opt_sim.dt = 0.1;
opt_sim.i_max = 3000;
opt_sim.tol = 0.1;

fields = fieldnames(dynamics);

demos_sim = cell(length(demo),1);

cell_index = 1;
curr_label = 1;

for i=1:length(fields)
    curr_demo = dynamics.(fields{i});
    for j = 1 : length(curr_demo)
        curr_demo{j}(3,:) = 1;
    end
    [X, targets, index] = ProcessDemos(curr_demo, 2, demo_struct, process_options);
    % [X, targets] = ProcessDemos(demo, 2, demo_struct, process_options);
% [fig_pos] = DrawData(X, targets, draw_options);

    Data = X(1:end-1,:);
    [Priors_0, Mu_0, Sigma_0] = initialize_SEDS(Data,K);
    [Priors, Mu, Sigma]=SEDS_Solver(Priors_0,Mu_0,Sigma_0,Data,options);
    
    d = size(Data,1)/2;
    x0_all = Data(1:d,index(1:end-1)); %finding initial points of all demonstrations
    fn_handle = @(x) ml_gmr_mod(Priors,Mu,Sigma,x,1:d,d+1:2*d);
    [x, xd]=Simulation(x0_all,[],fn_handle,opt_sim); %running the simulator
    for j = 1 : size(x,3)
       demos_sim{cell_index} = [x(:,:,j)+targets'; ones(1,size(x(:,:,j),2))*curr_label];
       cell_index = cell_index + 1;
    end
    curr_label = curr_label + 1;
end

%%
process_options.center_data = false;
[X, targets] = ProcessDemos(demos_sim, 2, demo_struct, process_options);

x_i = X(1:2,:)';
v_i = X(3:4,:)';
v_norm = v_i./vecnorm(v_i,2,2);
v_norm(isnan(v_norm)) = 0;
l_i = X(5,:)';
[m,~] = size(x_i);

draw_options = struct('plot_pos', true, ...  % Draw the demonstrated positions
                      'plot_vel', false ...  % Draw the demonstrated velocities
                      );
fig_pos2 = DrawData([x_i'; v_i'./vecnorm(v_i,2,2)'; l_i'], targets, draw_options);

%% Build Graph
% Sigma estimation based on sample frequency
dt = 0.1;
max_v = max(vecnorm(v_i,2,2));
max_d = max_v*dt;
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
W1 = GraphBuild2(graph_options, x_i, x_i);

% Build directionality check graph matrix
graph_options.thr = 0.8;
graph_options.isnan_value = 1;
graph_options.kernel = Kernels('cosine_cross');
W2 = GraphBuild2(graph_options, x_i, x_i, v_i);

% Build continuity check graph matrix
graph_options.thr = 0.9;
graph_options.isnan_value = 1;
graph_options.kernel = Kernels('cosine');
W3 = GraphBuild2(graph_options, v_i, v_i);

W = W1.*W3;
% GraphDraw(x_i, W);

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

% k_dir_vel = Kernels2('gauss_direct_vel', kpar_mat);
% S = GramMatrix(rbf, gram_options, x_i, x_i, v_norm, v_norm);

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
num_eigen = 15;
% [alpha, lambda] = eigs(L,num_eigen+1,'smallestabs');

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
alpha_s = eigvect_r(:,4:end);

np = 8;
h=gcf;
for i = 1:np
   for j = 1:np
      subplot(np,np,i+np*(j-1))
      scatter(alpha_s(:,i),alpha_s(:,j),20,colors(labels,:),'filled','MarkerEdgeColor',[0 0 0]);
      grid on;
   end
end

%% Build Lyapunov Function

[dynamics] = SearchAttractors(x_i,v_i,lambda,eigvect_r,eigvect_l);

x_res = 100; y_res = 100;
xs = linspace(0, 100, x_res);
ys = linspace(0, 100, y_res);
[Xs, Ys] = meshgrid(xs,ys);
x = [Xs(:),Ys(:)];

kpar_rbf = struct('sigma', 0.1); %.05

kpar_lyap = struct('sigma', 5.5, ...
                  'lambda', 5, ...
                  'rot', [0 1;-1 0], ...
                  'lyap_type', 'transpose', ...
                  'sigma_attract', .03 ...
                  );
              
[V, dV] = RebuildLyap(x, 2, dynamics(1,:), kpar_lyap);

figure
hold on;
contourf(Xs,Ys,reshape(V,100,100),20)
scatter(x_i(:,1),x_i(:,2),20,colors(labels,:),'filled','MarkerEdgeColor',[0 0 0]);
streamslice(Xs, Ys, reshape(dV(:,1),100,100), reshape(dV(:,2),100,100));
colormap hot
axis square
colorbar

figure
surf(Xs,Ys,reshape(V,100,100))
colormap hot
axis square