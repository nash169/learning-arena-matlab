clear; close all; clc;

%% Load demos
load 2as_3t.mat;
demo = DataStruct.demo;
demo_struct = DataStruct.demo_struct;

%% Process data
preprocess_options = struct('center_data', false,...
                            'calc_vel', true, ...
                            'tol_cutting', 0.01, ...
                            'smooth_window', 25 ...
                            );
[X, ~, ~, targets, ~] = ProcessDemos(demo, demo_struct, 2, preprocess_options);
xtrain = X(1:2,:)';

%% Draw data
draw_options = struct('plot_pos', true,...  % Draw the demonstrated positions
                      'plot_vel', false...  % Draw the demonstrated velocities
                      );
fig_pos = DrawData(X, targets, draw_options);

%% Learning
learn_options = struct('num_eigen',4,... % coponent's number
                       'ktype', 'gauss_vv',... % kernel type
                       'kpar', struct('sigma', 5, 'r', 25),... % kernel param
                       'vv_rkhs', true... % vector-valued rkhs
                       );
keca = KernelECA(xtrain, learn_options);

%% Plot results

plot_options = struct('xlims', [0 100],...        % 1x2 vector  
                      'ylims', [0 100],...        % 1x2 vector
                      'resoultion', 'medium',...  % ['low','medium','high']
                      'components', 1:4,...       % 1xn vector or scalar
                      'plot_data', true,...       % [true,false]
                      'labels', X(end,:),...      % 1xm vector 
                      'plot_eigens', true...     % [true,false]
                      );
PlotEigVecFun(keca, plot_options);