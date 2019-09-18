clear; close all; clc;

%% Load demos
load 2attracts_simple.mat;
demo = DataStruct.demo;
demo_struct = DataStruct.demo_struct;
% demo = ReducedData(demo, 3);

%% Process data
proc_options = struct('center_data', false,...
                      'tol_cutting', 1.,...
                      'dt', 0.1...
                      );
[X, targets] = ProcessDemos(demo, 2, demo_struct, proc_options);
x_i = X(1:2,:)';

%% Draw data
draw_options = struct('plot_pos', true,...  % Draw the demonstrated positions
                      'plot_vel', false...  % Draw the demonstrated velocities
                      );
fig_pos = DrawData(X, targets, draw_options);

%% Learning
learn_options = struct('num_eigen',8, ... 
                       'ktype', 'gauss', ... 
                       'kpar', struct('sigma', 5, 'r', 25), ...
                       'normalize', false ...
                       );
graph_options = struct('conntype','n-neighbors', ... % 'n-neighbors'
                       'epsilon', 5.3, ... 
                       'num_nb', 6, ...
                       'plot_graph', true ...
                       );
lem = LaplacianEM(x_i, learn_options, graph_options);

%% Plot results
plot_options = struct('xlims', [0 100],...        % 1x2 vector  
                      'ylims', [0 100],...        % 1x2 vector
                      'resoultion', 'medium',...  % ['low','medium','high']
                      'type', '2D',...            % ['2D','3D']
                      'components', 1:4,...       % 1xn vector or scalar
                      'plot_data', true,...       % [true,false]
                      'labels', X(end,:),...      % 1xm vector 
                      'plot_stream', true,...     % [true,false]
                      'plot_eigens', true,...     % [true,false]
                      'plot_mapped', false,...     % ['2D','3D',false]
                      'plot_projData', false...   % [true,false]
                      );
PlotEigenfun(lem, plot_options);
