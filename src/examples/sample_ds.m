clear; close all; clc;

%% Sample points
myds = pendulum('length', 1, 'friction', 0.2);
myds.set_data(100, -2*pi, 4*pi, -1, 1);

dt = 0.1;
T = 40;
time = 0:dt:T;

center_sampling = [2,-0.9; 2.5, 0.8];
radius = 0.3;
num_trajs = 3;

label = 1;
counter = 1;
demo = cell(num_trajs*size(center_sampling,1),1);
demo_struct = {'position','velocity','time','labels'};

for i = 1 : size(center_sampling,1)
    x0 = ball_uniform(center_sampling(i,:), radius, num_trajs);
    for j = 1 : num_trajs
        demo{counter,1} = [myds.sample(x0(j,:), T, dt)'; time; label*ones(1,length(time))];
        counter = counter + 1;
    end
    label = label + 1;
end

%% Load samples
% load pendulum.mat

%% Preprocess sampled trajectories
dim = 2;
preprocess_options = struct('center_data', false,...
                            'calc_vel', false, ...
                            'tol_cutting', 0.001, ...
                            'smooth_window', 25 ...
                            );

[X, x0, xT, targets, ~] = ProcessDemos(demo, demo_struct, dim, preprocess_options);

%% Plot
h = myds.plot_field;
hold on;
labels = X(end,:)';
colors = hsv(length(unique(labels)));
scatter(X(1,:)', X(2,:)', 20, colors(labels,:), 'filled', 'MarkerEdgeColor', [0 0 0])

theta = 0:0.1:2*pi;
for i = 1 : size(center_sampling,1)
   plot(center_sampling(i,1) + radius*cos(theta), center_sampling(i,2) + radius*sin(theta),'--k'); 
end
axis([-2*pi, 4*pi, -1, 1])

%% Save data
% save('ds_demo','demo','demo_struct');
