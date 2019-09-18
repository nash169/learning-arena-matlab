clear; close all; clc;

%% Check SEDS dependency
seds_path = genpath([userpath,'/seds']);
if isempty(seds_path)
    error('SEDS not found in MATLAB workspace');
else
    addpath(seds_path);
end

%% Define dynamics to load
icub_dim = 39;
dynamics = {'iCub_dyn1.mat','iCub_dyn2.mat'};
label = 2;
ds = load(dynamics{label});
ds.demo_struct(end) = [];

%% Preprocess trajectories
preprocess_options = struct('center_data', true,...
                            'calc_vel', true, ...
                            'tol_cutting', 0.01, ...
                            'smooth_window', 25, ...
                            'reduce_factor', 2 ...
                            );

[X_joints, x0, xT, T_joints, ~] = ProcessDemos(ds.demo_joints, ds.demo_struct, icub_dim, preprocess_options);
x_i = X_joints(1:icub_dim, :)'; %/max(max(X_joints(1:icub_dim, :)));
v_i = X_joints(icub_dim+1:2*icub_dim, :)'; %/max(max(X_joints(icub_dim+1:2*icub_dim, :)));
t_i = X_joints(end-1,:)';
l_i = X_joints(end,:)';

dim_reduced = 3;
X_reduced = [x_i(:,1:dim_reduced)'; v_i(:,1:dim_reduced)'; t_i'; l_i'];

%% Learn DS via SEDS
K = 10;                             % Number of Gaussian funcitons
[Priors_0, Mu_0, Sigma_0] = initialize_SEDS(X_reduced(1:end-2,:), K);

seds_options = struct('tol_mat_bias', 10^-6,...     % Small positive scalar to avoid instabilities in Gaussian kernel
                      'display', 1,...              % Displays the output of each iterations
                      'tol_stopping', 10^-10,...    % Stoppping tolerance
                      'max_iter', 500,...           % Maximum number of iteration for the solver [default: i_max=1000]
                      'objective', 'likelihood' ...        % 'likelihood', 'mse', 'direction'
                      );
[Priors, Mu, Sigma]=SEDS_Solver(Priors_0, Mu_0,Sigma_0, X_reduced(1:end-2,:), seds_options);
f_seds = @(x) ml_gmr_mod(Priors,Mu,Sigma,x-T_joints(:,1:dim_reduced)',1:dim_reduced,dim_reduced+1:2*dim_reduced);

%% Sample point
dt = 0.01;
T = 5;
num_trajs = 3;
demo = cell(num_trajs,1);

for i = 1:num_trajs
   x_0 = x0(1:dim_reduced,i); 
   [x_dot, x_next] = SampleDS(f_seds, x_0, T_joints(:,1:dim_reduced)', dt, T);
   demo{i,1} = [x_next; x_dot; 0:dt:T; label*ones(1,length(0:dt:T))];
end

demo_struct = {'position','velocity','time','labels'};
save('icub_seds_demo','demo','demo_struct');

%% Preprocess sampled trajectories
preprocess_options = struct('center_data', false,...
                            'calc_vel', false, ...
                            'smooth_window', 25 ...
                            );
[X_joints_learned, ~, ~, T_joints_learned, ~] = ProcessDemos(demo, demo_struct, dim_reduced, preprocess_options);

x_i_learned = X_joints_learned(1:dim_reduced, :)';
v_i_learned = X_joints_learned(dim_reduced+1:2*dim_reduced, :)';
t_i_learned = X_joints_learned(end-1,:)';
l_i_learned = X_joints_learned(end,:)';

%% Draw sampled trajectories
plot_dim = 3;
draw_options = struct('plot_pos', true, ...
                      'plot_vel', false ...
                      );
pos_joints = DrawData([(x_i(:,1:plot_dim)+T_joints(:,1:plot_dim))'; v_i(:,1:plot_dim)'; t_i'; l_i'], T_joints(:,1:plot_dim), draw_options);                  
pos_learned = DrawData([x_i_learned(:,1:plot_dim)'; v_i_learned(:,1:plot_dim)'; t_i_learned'; l_i_learned'], T_joints_learned(:,1:plot_dim), draw_options);

%% Plot GMM
fig(1) = figure;
hold on; box on
plotGMM(Mu(1:2,:), Sigma(1:2,1:2,:), [0.6 1.0 0.6], 1,[0.6 1.0 0.6]);
plot(x_i(:,1), x_i(:,2), 'r.');
xlabel('$q_1 (rad)$','interpreter','latex','fontsize',15);
ylabel('$q_2 (rad)$','interpreter','latex','fontsize',15);

fig(2) = figure;
hold on; box on
plotGMM(Mu([1 3],:), Sigma([1 3],[1 3],:), [0.6 1.0 0.6], 1,[0.6 1.0 0.6]);
plot(x_i(:,1), x_i(:,3), 'r.');
xlabel('$q_1 (rad)$','interpreter','latex','fontsize',15);
ylabel('$q_3 (rad)$','interpreter','latex','fontsize',15);

fig(3) = figure;
hold on; box on
plotGMM(Mu([1 4],:), Sigma([1 4],[1 4],:), [0.6 1.0 0.6], 1,[0.6 1.0 0.6]);
plot(x_i(:,1), v_i(:,1), 'r.');
xlabel('$q_1 (rad)$','interpreter','latex','fontsize',15);
ylabel('$\dot{q}_1 (rad)$','interpreter','latex','fontsize',15);

fig(4) = figure;
hold on; box on
plotGMM(Mu([1 5],:), Sigma([1 5],[1 5],:), [0.6 1.0 0.6], 1,[0.6 1.0 0.6]);
plot(x_i(:,1), v_i(:,2), 'r.');
xlabel('$q_1 (rad)$','interpreter','latex','fontsize',15);
ylabel('$\dot{q}_2 (rad)$','interpreter','latex','fontsize',15);

fig(5) = figure;
hold on; box on
plotGMM(Mu([1 6],:), Sigma([1 6],[1 6],:), [0.6 1.0 0.6], 1,[0.6 1.0 0.6]);
plot(x_i(:,1), v_i(:,3), 'r.');
xlabel('$q_1 (rad)$','interpreter','latex','fontsize',15);
ylabel('$\dot{q}_3 (rad)$','interpreter','latex','fontsize',15);