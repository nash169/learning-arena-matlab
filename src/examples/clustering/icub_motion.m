clear; close all; clc;

%% Virtual object trajectories
% init1 = [0.2, -0.2, 0.7
%          0.1, 0.0, 0.7
%          0.3, 0.2, 0.6
%     ];
% end1 = [0.3, 0.0, 0.2];
% dv1 = repmat(end1,3,1) - init1;
% 
% init2 = [0.1, -0.25, 0.45
%          0.2, -0.15, 0.4
%          0.2, -0.05, 0.45
%     ];
% end2 = [0.3, 0.1, 0.9];
% dv2 = repmat(end2,3,1) - init2;
% 
% init3 = [0.1, 0.25, 0.45
%          0.2, 0.15, 0.4
%          0.20, 0.05, 0.45
%     ];
% end3 = [0.3, -0.1, 0.8];
% dv3 = repmat(end3,3,1) - init3;
% 
% quiver3(init1(:,1), init1(:,2), init1(:,3), dv1(:,1), dv1(:,2), dv1(:,3),0)
% hold on
% quiver3(init2(:,1), init2(:,2), init2(:,3), dv2(:,1), dv2(:,2), dv2(:,3),0)
% hold on
% quiver3(init3(:,1), init3(:,2), init3(:,3), dv3(:,1), dv3(:,2), dv3(:,3),0)

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
                            'reduce_factor', 3 ...
                        );
                        
[X_joints, ~, ~, T_joints, ~] = ProcessDemos(demo_joints, demo_struct, joints_dim, preprocess_options);
[X_obj_pos, ~, ~, T_obj_pos, ~] = ProcessDemos(demo_obj_pos, demo_struct, obj_pos_dim, preprocess_options);
[X_obj_rot, ~, ~, T_obj_rot, ~] = ProcessDemos(demo_obj_rot, demo_struct, obj_rot_dim, preprocess_options);

% Obj position
x_obj_pos = X_obj_pos(1:obj_pos_dim, :)';
v_obj_pos = X_obj_pos(obj_pos_dim+1:2*obj_pos_dim, :)';
t_obj_pos = X_obj_pos(end-2,:)';
dt_obj_pos = X_obj_pos(end-1,:)';
l_obj_pos = X_obj_pos(end,:)';

% Obj rotation
x_obj_rot = X_obj_rot(1:obj_rot_dim, :)';
v_obj_rot = X_obj_rot(obj_rot_dim+1:2*obj_rot_dim, :)';
t_obj_rot = X_obj_rot(end-2,:)';
dt_obj_rot = X_obj_rot(end-1,:)';
l_obj_rot = X_obj_rot(end,:)';

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
red_end = 10;
x_joints = x_joints(:,red_start:red_end);
v_joints = v_joints(:,red_start:red_end);
T_joints = T_joints(:,red_start:red_end);

% Set data and normalize
X = (x_joints - mean(x_joints))./std(x_joints);
V = (v_joints - mean(v_joints))./std(v_joints);
dt = dt_joints;
M = size(X,1);


%% Build graph
% Sigma estimation based on sample frequency
v_norm = V./vecnorm(V,2,2);
v_norm(isnan(v_norm)) = 0;
[m,~] = size(X);

max_d = max(vecnorm(V,2,2).*dt);
scale = 1;
sigma = scale*max_d;

% The first graph can be rebuild using epsilon neighborhoods
G1 = graph_build(X, 'type', 'eps-neighborhoods', 'r', sigma);

% The third graph is just epsilon neighborhoods using cosine kernel as
% distance between points
mycosine = cosine('isnan', 1);
G3 = graph_build(V, 'type', 'eps-neighborhoods', 'r', -0.9, 'fun', @(x,y) -mycosine.kernel(x,y));

G = G1.*G3;

%% Manifold Learning
% Create the kernel
myrbf = rbf('sigma', sigma);
myvel = velocity_directed('sigma', sigma, 'v_field', {V,V}, 'weight', 0.5);
% Create object
ke = kernel_eca('kernel', myvel);
% Set the dataset
ke.set_data(X);
% Set the graph
ke.set_graph(G);

%% Plot spectral analysis
% Plot spectrum
ke.plot_spectrum;
% Plot entropy contribution
ke.plot_entropy;
% Plot the embedding
ke.plot_embedding([1,2,3]);
% Plot the eigenvectors
ke.plot_eigenvec([1,2,3]);
% Plot data
% h = ke.plot_data;

%% Clustering
state_dim = 10;
num_ds = 3;
thr = 3e-16;
U = ke.embedding([2,1,3]);

% Cluster
labels_learn = 4*ones(length(l_joints),1);
for i = 1:num_ds
    labels_learn(abs(U(:,i))>thr) = i;
end

% Extract results
correct_class = sum(labels_learn==l_joints)*100/M;
class_start = 1;
class_end = sum(l_joints(l_joints==1));
per_class = zeros(num_ds,3);
for i = 1 : 3
    batch = labels_learn(class_start:class_end);
    correct = sum(batch==i);
    unknown = sum(batch==4);
    wrong = length(batch) - correct - unknown;
    
    per_class(i,1) = correct*100/length(batch);
    per_class(i,2) = wrong*100/length(batch);
    per_class(i,3) = unknown*100/length(batch);
    
    if i~=3
        class_start = class_start + sum(l_joints(l_joints==i)/i);
        class_end = class_end + sum(l_joints(l_joints==i+1)/(i+1));
    end
end

%% Attractor
x_attractor = zeros(num_ds,state_dim);
n = 10;
for i = 1:num_ds
    [~, index] = sort(abs(U(:,i)),'descend');
    x_attractor(i,:) = mean(x_joints(index(1:n), :));
end
mse_attractor = vecnorm((x_attractor-T_joints)./3/std(x_joints),2,2);

%% Plot results
plot_start = 1;
plot_end = 3;
data_joints(end,:) = labels_learn';
DrawData(data_joints, x_attractor(:,plot_start:plot_end), draw_options);

%% K-Means comparison
km = k_means('cluster', 3, 'step', 50, 'norm', 2, 'soft', true);
km.set_data(X);
[labels_km, centroids] = km.cluster;
correct_class_km = sum(labels_km==l_joints)*100/M;
data_joints(end,:) = labels_km';
DrawData(data_joints, x_attractor(:,plot_start:plot_end), draw_options);