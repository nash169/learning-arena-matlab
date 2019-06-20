clear; close all; clc;

%% 3D examples
x = linspace(0,10,10);
y = linspace(0,10,10);
z = linspace(0,10,10);
[X,Y,Z] = meshgrid(x,y,z);
x_test = [X(:),Y(:),Z(:)];

% Build A
D = -eye(3);
U = [1 0 0; 0 1 0; 0 0 1];
A = U*D*U';
x_a = [5,5,5];

param_3d = struct('A', A, ...
                  'x_a', x_a ...
                 );          
f = DynamicalSys('quadratic',param_3d);

x_dot_test = f(x_test);

streamline(X,Y,Z,...
    reshape(x_dot_test(:,1),10,10,[]),...
    reshape(x_dot_test(:,2),10,10,[]),...
    reshape(x_dot_test(:,3),10,10,[]),...
    X(1:2:end,1:2:end,1:2:end),...
    Y(1:2:end,1:2:end,1:2:end),...
    Z(1:2:end,1:2:end,1:2:end));
hold on;
scatter3(sqrt(x_a(1)),sqrt(x_a(2)),sqrt(x_a(3)), 100, 'r','filled', 'MarkerEdgeColor',[0 0 0])

%% Sample point
dt = 0.01;
T = 10;
label = 1;
num_trajs = 3;
dim = 3;
demo = cell(num_trajs,1);

for i = 1:num_trajs
   x_0 = rand(1,3)*10;
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