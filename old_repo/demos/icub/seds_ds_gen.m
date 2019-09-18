clear; close all; clc;

%% Create a Dynamics
D = -eye(2);
U = [1 0; 0 1];
A = U*D*U';
x_a = [2,2];

param_2d = struct('A', A, ...
                  'x_a', x_a ...
                 );          
f = DynamicalSys('quadratic',param_2d);

%% Sample point
dt = 0.01;
T = 5;

num_trajs = 3;
label = 1;

radius = 2;
center = [6,8];
X = UniformDisk(center, radius, num_trajs);

demo = cell(num_trajs,1);

for i = 1:num_trajs
   x_0 = X(i,:); 
   [x_dot, x_next] = SampleDS(f, x_0, dt, T);
   demo{i,1} = [x_next'; x_dot'; 0:dt:T; label*ones(1,size(x_next,1))];
end

demo_struct = {'position','velocity','time','labels'};

%% Preprocess sampled trajectories
dim = 2;

preprocess_options = struct('center_data', true,...
                            'calc_vel', false, ...
                            'tol_cutting', 0.01, ...
                            'smooth_window', 25 ...
                            );

[x_train, x0, xT, targets, ~] = ProcessDemos(demo, demo_struct, dim, preprocess_options);

%% Draw sampled trajectories
draw_options = struct('plot_pos', true, ...
                      'plot_vel', false ...
                      );
                  
pos_obj = DrawData(x_train, targets, draw_options);
hold on;
axis([0 10 0 10]);
theta = 0:0.1:2*pi;
plot(center(1) + radius*cos(theta), center(2) + radius*sin(theta));

%% Learn DS via SEDS
K = 6;                             % Number of Gaussian funcitons
[Priors_0, Mu_0, Sigma_0] = initialize_SEDS(x_train(1:end-2,:), K);

seds_options = struct('tol_mat_bias', 10^-6,...     % Small positive scalar to avoid instabilities in Gaussian kernel
                      'display', 1,...              % Displays the output of each iterations
                      'tol_stopping', 10^-10,...    % Stoppping tolerance
                      'max_iter', 500,...           % Maximum number of iteration for the solver [default: i_max=1000]
                      'objective', 'mse' ...        % use mean square error as criterion to optimize parameters of GMM
                      );
[Priors, Mu, Sigma]=SEDS_Solver(Priors_0, Mu_0,Sigma_0, x_train(1:end-2,:), seds_options);
f_seds = @(x) ml_gmr_mod(Priors,Mu,Sigma,x-targets',1:dim,dim+1:2*dim);

%% Draw learned vs original dynamics
x = linspace(0,10,10);
y = linspace(0,10,10);
[X,Y] = meshgrid(x,y);
x_test = [X(:),Y(:)];

origin_field = f(x_test);
seds_field = f_seds(x_test')';

figure
streamslice(X,Y,reshape(origin_field(:,1),10,[]), reshape(origin_field(:,2),10,[]));
axis([0 10 0 10]);

figure
streamslice(X,Y,reshape(seds_field(:,1),10,[]), reshape(seds_field(:,2),10,[]));
axis([0 10 0 10]);

%% Sample point
% dt = 0.01;
% T = 5;
% label = 1;
% num_trajs = 3;
% dim = 2;
% demo = cell(num_trajs,1);
% 
% radius = 2;
% center = [6,8];
% 
% X = UniformDisk(center, radius, num_trajs);
% 
% for i = 1:num_trajs
%    x_0 = X(i,:); 
%    [x_dot, x_next] = SampleDS(f, x_0, dt, T);
%    demo{i,1} = [x_next'; x_dot'; 0:dt:T; label*ones(1,size(x_next,1))];
% end
% 
% demo_struct = {'position','velocity','time','labels'};