clear; close all; clc;

%% Load demos
load 2as_3t.mat;
demo = DataStruct.demo;
demo_struct = DataStruct.demo_struct;
% If you want to consider only a reduced number of data points for each
% demonstrated trajectory -> demo = ReducedData(demo, num_points);

%% Process data
preprocess_options = struct('center_data', false,...
                            'calc_vel', true, ...
                            'tol_cutting', 0.01, ...
                            'smooth_window', 25 ...
                            );
[X, ~, ~, targets, ~] = ProcessDemos(demo, demo_struct, 2, preprocess_options);
x_i = X(1:2,:)';

%% Draw data
draw_options = struct('plot_pos', true,...  % Draw the demonstrated positions
                      'plot_vel', false...  % Draw the demonstrated velocities
                      );
fig_pos = DrawData(X, targets, draw_options);

%% Normalize and Center input space
% x_i = MeanScale(x_i,'center'); % Nothing changes
% x_i = x_i(xtrain,'scale'); % Speed up the Eigenvalue/Optimization problem

%% Hyperparameters Search
kernel_type = 'gauss';
normalize = true;
range = 2:7;
hyperpar = HyperparSearch(x_i, kernel_type, range, normalize);

%% Learning
learn_options = struct('num_eigen',8,... 
                       'ktype', 'gauss',... 
                       'kpar', struct('sigma', 5, 'r', 25),...
                       'vv_rkhs', false...
                       );
kpca = KernelPCA(x_i, learn_options);

%% Plot results
plot_options = struct('xlims', [0 100],...        % 1x2 vector  
                      'ylims', [0 100],...        % 1x2 vector
                      'resoultion', 'medium',...  % ['low','medium','high']
                      'type', '2D',...            % ['2D','3D']
                      'components', 1:2,...       % 1xn vector or scalar
                      'plot_data', true,...       % [true,false]
                      'labels', X(end,:),...      % 1xm vector 
                      'plot_stream', true,...     % [true,false]
                      'plot_eigens', true,...    % [true,false]
                      'plot_mapped', '3D',...     % ['2D','3D',false]
                      'plot_projData', false...   % [true,false]
                      );
PlotEigenfun(kpca, plot_options);
