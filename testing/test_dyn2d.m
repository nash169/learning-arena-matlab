clear; close all; clc;

%% 2D examples
x = linspace(0,10,10);
y = linspace(0,10,10);
[X,Y] = meshgrid(x,y);
x_test = [X(:),Y(:)];

% Build A
D = -eye(2);
U = [1 0; 0 1];
A = U*D*U';
x_a = [2,2];

param_2d = struct('A', A, ...
                  'x_a', x_a ...
                 );          
f = DynamicalSys('quadratic',param_2d);

x_dot_test = f(x_test);

streamslice(X,Y,reshape(x_dot_test(:,1),10,[]), reshape(x_dot_test(:,2),10,[]));
hold on;

%% Sample point
dt = 0.01;
T = 5;
label = 1;
num_trajs = 3;
dim = 2;
demo = cell(num_trajs,1);

radius = 2;
center = [6,8];

X = UniformDisk(center, radius, num_trajs);

for i = 1:num_trajs
%    x_0 = rand(1,2)*10;
   x_0 = X(i,:); 
   [x_dot, x_next] = SampleDS(f, x_0, dt, T);
   demo{i,1} = [x_next'; x_dot'; 0:dt:T; label*ones(1,size(x_next,1))];
end

demo_struct = {'position','velocity','time','labels'};

preprocess_options = struct('center_data', false,...
                      'calc_vel', false, ...
                      'tol_cutting', 0.01, ...
                      'smooth_window', 25 ...
                      );

[x_train, ~, ~, targets, ~] = ProcessDemos(demo, demo_struct, dim);

draw_options = struct('plot_pos', true, ...
                      'plot_vel', false ...
                      );
                  
pos_obj = DrawData(x_train, targets, draw_options);
hold on;
axis([0 10 0 10]);
theta = 0:0.1:2*pi;
plot(center(1) + radius*cos(theta),center(2) + radius*sin(theta));



