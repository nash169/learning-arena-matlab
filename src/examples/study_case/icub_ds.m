clear; close all; clc;

%% Load demos
ds1 = load('iCub_dyn1.mat');
ds2 = load('iCub_dyn2.mat');

demo_joints = [ds1.demo_joints; ds2.demo_joints];
demo_obj_pos = [ds1.demo_obj_pos; ds2.demo_obj_pos];
demo_obj_rot = [ds1.demo_obj_rot; ds2.demo_obj_rot];
demo_struct = ds1.demo_struct;
  
joints_dim = 39;
obj_pos_dim = 3;
obj_rot_dim = 3;

%% Load learned demos
% ds1 = load('iCub_dyn1.mat');
% ds2 = load('icub_seds_demo2.mat');

% demo_joints = [ds1.demo_joints];
% demo_joints = [ds1.demo; ds2.demo];
% demo_struct = ds1.demo_struct;
plot_dim = 3;
% joints_dim = 3;

%% Process joints data
preprocess_options = struct('center_data', false,...
                            'calc_vel', true, ...
                            'tol_cutting', 1e-4, ... % 0.01
                            'smooth_window', 25, ...
                            'reduce_factor', 2 ...
                        );
                        
[X_joints, ~, ~, T_joints, ~] = ProcessDemos(demo_joints, demo_struct, joints_dim, preprocess_options);
[X_obj_pos, ~, ~, T_obj_pos, ~] = ProcessDemos(demo_obj_pos, demo_struct, obj_pos_dim, preprocess_options);
[X_obj_rot, ~, ~, T_obj_rot, ~] = ProcessDemos(demo_obj_rot, demo_struct, obj_rot_dim, preprocess_options);

%% Draw data
draw_options = struct('plot_pos', true, ...
                      'plot_vel', false ...
                      );
                  
pos_obj = DrawData(X_obj_pos, T_obj_pos, draw_options);

x_i = X_joints(1:joints_dim, :)';
v_i = X_joints(joints_dim+1:2*joints_dim, :)';
t_i = X_joints(end-1,:)';
l_i = X_joints(end,:)';
pos_joints = DrawData([x_i(:,1:3)'; v_i(:,1:3)'; t_i'; l_i'], T_joints(:,1:3), draw_options);

%% Set kernel sigma
v_norm = v_i./vecnorm(v_i,2,2);
v_norm(isnan(v_norm)) = 0;
[m,~] = size(x_i);

dt = [];
for i = 1:max(l_i)
   t_tmp = t_i(l_i==i);
   dt = [dt; t_tmp(2:end)-t_tmp(1:end-1);0]; 
end

max_d = max(vecnorm(v_i,2,2).*dt);
scale = 1.5;
sigma = 0.5*scale*(max_d/3);