clear; close all; clc;

%% Load demos
load pendulum.mat;

%% Process data
dim = 2;
preprocess_options = struct('center_data', false,...
                            'calc_vel', true, ...
                            'tol_cutting', 0.001, ...
                            'smooth_window', 25, ...
                            'reduce_factor', 2 ...
                            );
[X, ~, ~, targets, ~] = ProcessDemos(demo, demo_struct, dim, preprocess_options);

% Position
position = X(1:dim, :)';

% Velocity
velocity = X(dim+1:2*dim, :)';

% Time
time = X(end-dim,:)';

% Time interval
delta = X(end-1,:)';

% Labela & colors
labels = X(end,:)';
colors = hsv(length(unique(labels)));
colors = colors(labels,:);

% Sigma estimation based on sample frequency
max_d = max(vecnorm(velocity,2,2).*delta);
scale = 1.5;
sigma = scale*(max_d/3);

%% Build Graph

% The first graph can be rebuild using epsilon neighborhoods
G1 = graph_build(position, 'type', 'eps-neighborhoods', 'r', 3*sigma);
% G1 = graph_build(position, 'type', 'k-nearest', 'k', 5);

% For the second graph it is necessary to use epsilon neighborhoods with
% non-euclidean distance (lyapunov kernel)
mylyap = lyapunov('kernel', rbf('sigma', sigma), 'v_field', velocity, 'sym_weight', 0, 'isnan', 1, 'normalize', true);
% G2 = graph_build(position, 'type', 'eps-neighborhoods', 'r', -0.8, 'fun', @(x,y) -mylyap.kernel(x,y));
G2 = graph_build(position, 'type', 'k-nearest', 'k', 5, 'fun', @(x,y) mylyap.kernel(x,y));

% The third graph is just epsilon neighborhoods using cosine kernel as
% distance between points
mycosine = cosine('isnan', 1);
G3 = graph_build(velocity, 'type', 'eps-neighborhoods', 'r', -0.99, 'fun', @(x,y) -mycosine.kernel(x,y));

% Graph built using the velocity-oriented kernel as a distance measure. The
% principal axis (direction and magnitude) of the covariance matrices are
% determined thorugh the points velocities and sampling frequency.
% myrbfvel = velocity_oriented('v_field', velocity, 'weights', [sigma^2,0.05*sigma^2]);
% G4 = graph_build(position, 'type', 'eps-neighborhoods', 'r', -0.01, 'fun', @(x,y) -myrbfvel.kernel(x,y));

%% Manifold Learning
% Create kernel
keca_kernel = rbf('sigma', 3*sigma);
% Create object
ke = kernel_eca('kernel', keca_kernel);
% Set the dataset
ke.set_data(position);
% Set colors
ke.set_colors(colors);
% Set graph options
ke.set_graph(G1); % ke.graph_options('type', 'eps-neighborhoods', 'r', 3*sigma); (G2+G2')
% Solve the eigendecomposition
[D_ke,V_ke,W_ke] = ke.eigensolve;

% % Plot the eigenfunctions
% ke.plot_eigenfun([1,2], 'plot_stream', true, 'grid', [-2*pi, 4*pi, -2, 2], 'plot_data', true, 'colors', colors);
% % Plot eigenvec
% ke.plot_eigenvec;
% % Plot entropy
% ke.plot_entropy;
% % Plot spectrum
% ke.plot_spectrum;
% % Plot graph
% ke.plot_graph;
% % Plot data
% h = ke.plot_data;

%% Velocity-oriented kernel
% myrbfvel = velocity_oriented('v_field', velocity(2,:), 'weights', [sigma^2,0.05*sigma^2]);
% 
% % Options of the expansion plot
% ops_exps = struct( ...
%     'grid', [-2*pi, 4*pi, -2, 2], ...
%     'res', 100, ...
%     'plot_data', false, ...
%     'plot_stream', true ...
%     );
% psi = kernel_expansion('reference', position(2,:), 'weights', 1);
% psi.set_data(100, -2*pi, 4*pi, -2, 2);
% psi.set_params('kernel', myrbfvel);
% 
% % psi.plot;
% h = psi.contour(ops_exps);
% scatter(position(:,1), position(:,2), 40, colors, 'filled','MarkerEdgeColor',[0 0 0])