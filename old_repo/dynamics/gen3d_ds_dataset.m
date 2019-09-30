clear; close all; clc;

%% Create Dynamics
beta = -1.;
D = beta*eye(3);
U = [1 0 0; 0 1 0; 0 0 1];
A = U*D*U';
x_a = [8,8,8];

param_ds = struct('A', A, ...
                  'x_a', x_a ...
                 );          
f = DynamicalSys('linear',param_ds);

%% Sample point
dt = 0.01;
T = 10;

num_trajs = 3;
label = 2;

radius = 2;
center = [8,2,2];
X = UniformBall(center, radius, num_trajs);

demo = cell(num_trajs,1);

for i = 1:num_trajs
   x_0 = X(i,:); 
   [x_dot, x_next] = SampleDS(f, x_0, x_a, dt, T);
   demo{i,1} = [x_next'; x_dot'; 0:dt:T; label*ones(1,size(x_next,1))];
end

demo_struct = {'position','velocity','time','labels'};
save('ds_demo','demo','demo_struct');

%% Preprocess sampled trajectories
dim = 3;

preprocess_options = struct('center_data', false,...
                            'calc_vel', false, ...
                            'tol_cutting', 0.01, ...
                            'smooth_window', 25 ...
                            );

[x_train, x0, xT, targets, ~] = ProcessDemos(demo, demo_struct, dim, preprocess_options);

%% Draw sampled trajectories & vector field
draw_options = struct('plot_pos', true, ...
                      'plot_vel', false ...
                      );
                  
pos_obj = DrawData(x_train, targets, draw_options);
hold on;
axis([0 10 0 10 0 10]);

% Sampling area
[theta, phi] = meshgrid(linspace(0,pi,100),linspace(0,2*pi,100));
X = center(1) + radius*sin(theta).*cos(phi);
Y = center(2) + radius*sin(theta).*sin(phi);
Z = center(3) + radius*cos(theta);

surf(X, Y, Z);
alpha 0.3

% % Vector field
% x = linspace(0,10,10);
% y = linspace(0,10,10);
% [X,Y] = meshgrid(x,y);
% x_test = [X(:),Y(:)];
% x_dot = f(x_test);
% streamslice(X,Y,reshape(x_dot(:,1),10,[]), reshape(x_dot(:,2),10,[]));
