clear; close all; clc;

%% Create Dynamics
D = -eye(2);
U = [1 0; 0 1];
beta = 1.;
A = beta*(U*D*U');
x_a = [4,4];
% x_a = [9,9];

param_ds = struct('A', A, ...
                  'x_a', x_a ...
                 );          
f = DynamicalSys('linear',param_ds);

%% Sample point
dt = 0.05;
T = 5;

num_trajs = 3;
label = 1;

radius = 2;
center = [2,8];
X = UniformDisk(center, radius, num_trajs);

demo = cell(num_trajs,1);

for i = 1:num_trajs
   x_0 = X(i,:); 
   [x_dot, x_next] = SampleDS(f, x_0, x_a, dt, T);
   demo{i,1} = [x_next'; x_dot'; 0:dt:T; label*ones(1,size(x_next,1))];
end

demo_struct = {'position','velocity','time','labels'};
save('ds_demo','demo','demo_struct');

%% Preprocess sampled trajectories
dim = 2;

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
axis([0 10 0 10]);

% Sampling area
theta = 0:0.1:2*pi;
plot(center(1) + radius*cos(theta), center(2) + radius*sin(theta),'--k');

% Vector field
x = linspace(0,10,10);
y = linspace(0,10,10);
[X,Y] = meshgrid(x,y);
x_test = [X(:),Y(:)];
x_dot = f(x_test);
streamslice(X,Y,reshape(x_dot(:,1),10,[]), reshape(x_dot(:,2),10,[]));
