clear; close all; clc;

%% Load demos
ds1 = load('iCub_dyn1.mat');
ds2 = load('iCub_dyn2.mat');
ds3 = load('iCub_dyn3.mat');

demo_joints = [ds1.demo_joints; 
               ds2.demo_joints; 
               ds3.demo_joints];
           
demo_obj_pos = [ds1.demo_obj_pos; 
                ds2.demo_obj_pos; 
                ds3.demo_obj_pos];
            
demo_obj_rot = [ds1.demo_obj_rot; 
                ds2.demo_obj_rot; 
                ds3.demo_obj_rot];

demo_struct = ds1.demo_struct;
  
joints_dim = 39;
obj_pos_dim = 3;
obj_rot_dim = 3;


%% Process joints data
preprocess_options = struct('center_data', false,...
                            'calc_vel', true, ...
                            'tol_cutting', 1e-3, ... % 0.01
                            'smooth_window', 25, ...
                            'reduce_factor', 4 ...
                        );
                        
[X_joints, ~, ~, T_joints, ~] = ProcessDemos(demo_joints, demo_struct, joints_dim, preprocess_options);
[X_obj_pos, ~, ~, T_obj_pos, ~] = ProcessDemos(demo_obj_pos, demo_struct, obj_pos_dim, preprocess_options);
% [X_obj_rot, ~, ~, T_obj_rot, ~] = ProcessDemos(demo_obj_rot, demo_struct, obj_rot_dim, preprocess_options);

% Obj position
x_obj_pos = X_obj_pos(1:obj_pos_dim, :)';
v_obj_pos = X_obj_pos(obj_pos_dim+1:2*obj_pos_dim, :)';
t_obj_pos = X_obj_pos(end-2,:)';
dt_obj_pos = X_obj_pos(end-1,:)';
l_obj_pos = X_obj_pos(end,:)';

% Obj rotation
% x_obj_rot = X_obj_rot(1:obj_rot_dim, :)';
% v_obj_rot = X_obj_rot(obj_rot_dim+1:2*obj_rot_dim, :)';
% t_obj_rot = X_obj_rot(end-2,:)';
% dt_obj_rot = X_obj_rot(end-1,:)';
% l_obj_rot = X_obj_rot(end,:)';

% Joints
x_joints = X_joints(1:joints_dim, :)';
v_joints = X_joints(joints_dim+1:2*joints_dim, :)';
t_joints = X_joints(end-2,:)';
dt_joints = X_joints(end-1,:)';
l_joints = X_joints(end,:)';

%% Draw data
plot_start = 7;
plot_end = 9;
draw_options = struct('plot_pos', true, ...
                      'plot_vel', false ...
                      );
                  
DrawData(X_obj_pos, T_obj_pos, draw_options);

data_joints = [x_joints(:,plot_start:plot_end)'; v_joints(:,plot_start:plot_end)'; t_joints'; l_joints'];
DrawData(data_joints, T_joints(:,plot_start:plot_end), draw_options);

%% Set data space
% Remove non configuration space and fixed joints
x_joints(:,10:12) = []; x_joints(:,1:6) = [];
v_joints(:,10:12) = []; v_joints(:,1:6) = [];
T_joints(:,10:12) = []; T_joints(:,1:6) = [];

% Joints dimension
red_start = 1;
red_end = 3;
x_joints = x_joints(:,red_start:red_end);
v_joints = v_joints(:,red_start:red_end);
T_joints = T_joints(:,red_start:red_end);

% Set data and normalize
X = (x_joints - mean(x_joints))./std(x_joints);
V = (v_joints - mean(v_joints))./std(v_joints);
dt = dt_joints;
M = size(X,1);

% Sigma estimation based on sample frequency
v_norm = V./vecnorm(V,2,2);
v_norm(isnan(v_norm)) = 0;
[m,~] = size(X);

max_d = max(vecnorm(V,2,2).*dt);
scale = 3;
sigma = scale*max_d;

%% Create kernels
% RBF kernel
myrbf = rbf('sigma', 0.5);

% Velocity-augmented kernel
myvel = velocity_augmented('sigma', sigma, 'v_field', {V,V}, 'weight', 0.5);

% Lyapunov kernel
mylyap = lyapunov('kernel', rbf('sigma', sigma), 'v_field', V, 'sym_weight', 0, 'isnan', 1, 'normalize', true);

% Lyapunov directed kernel
mydir_lyap = lyapunov_directed('sigma', sigma, 'v_field', V, 'angle', pi/2, 'isnan', 1);

% Velocity directed kernel
mydir_vel = velocity_directed('sigma', sigma, 'v_field', {V,V}, 'angle', pi/2);

% Cosine kernel
mycosine = cosine('isnan', 1);

%% Build graph
% The first graph can be rebuild using epsilon neighborhoods
G1 = graph_build(X, 'type', 'eps-neighborhoods', 'r', sigma);

% For the second graph it is necessary to use epsilon neighborhoods with
% non-euclidean distance (lyapunov kernel - with symmetric part set to zero)
G2 = graph_build(X, 'type', 'eps-neighborhoods', 'r', -0.8, 'fun', @(x,y) -mylyap.kernel(x,y));

% The third graph is just epsilon neighborhoods using cosine kernel as
% distance between points
G3 = graph_build(V, 'type', 'eps-neighborhoods', 'r', -0.9, 'fun', @(x,y) -mycosine.kernel(x,y));


G4 = graph_build(X, 'type', 'eps-neighborhoods', 'r', -0.8, 'fun', @(x,y) -mydir_lyap.kernel(x,y));

G5 = graph_build(X, 'type', 'eps-neighborhoods', 'r', -0.95, 'fun', @(x,y) -mydir_vel.kernel(x,y));

% Total graph
G = G1.*G3;

%% Manifold Learning
% Create object
dm = diffusion_maps('kernel', myrbf, 'alpha', 1, 'epsilon', 2*sigma^2, 'operator', 'transport');

% Set the dataset
dm.set_data(X);

% Set the graph
dm.set_graph(G4);

[D,R,L] = dm.eigensolve;

%% Plot spectral analysis
% Plot spectrum
dm.plot_spectrum;