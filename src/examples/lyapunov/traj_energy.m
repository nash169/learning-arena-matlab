clear; close all; clc;

%% Load demos
load 'DS_demo.mat'


%% Process joints data
dim = 2;
preprocess_options = struct('center_data', false,...
                            'calc_vel', true, ...
                            'tol_cutting', 1e-4, ... % 0.01
                            'smooth_window', 25, ...
                            'reduce_factor', 1 ...
                        );
                        
[data, ~, ~, targets, ~] = ProcessDemos(demo, demo_struct, dim, preprocess_options);

% Extract data
x = data(1:dim, :)';
v = data(dim+1:2*dim, :)';
dt = data(end-1,:)';
labels = data(end,:)';
colors = hsv(length(unique(labels)));
colors = colors(labels,:);
M = size(x,1);

% Normalize
X = x;
V = v;
% X = (x - mean(x))./std(x);
% V = (v - mean(v))./std(v);

% Sigma estimation based on sample frequency
v_norm = V./vecnorm(V,2,2);
v_norm(isnan(v_norm)) = 0;
[m,~] = size(X);

max_d = max(vecnorm(V,2,2).*dt);
scale = 3;
sigma = scale*max_d;

%% Draw data
draw_options = struct('plot_pos', true, ...
                      'plot_vel', false ...
                      );
                  
DrawData(data, targets, draw_options);

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

G5 = graph_build(X, 'type', 'eps-neighborhoods', 'r', -0.8, 'fun', @(x,y) -mydir_vel.kernel(x,y));

% Total graph
G = G1.*G3;

G_all = ones(M);

%% Manifold Learning
% Create object
dm = diffusion_maps('kernel', myrbf, 'alpha', 1, 'epsilon', 2*sigma^2, 'operator', 'transport');

% Set the dataset
dm.set_data(X);

% Set the graph
dm.set_graph(G4);

%% Plot spectral analysis
% Plot spectrum
dm.plot_spectrum;

% Get embedding
[D,R,L] = dm.eigensolve;

% Plot embedding
% dm.plot_embedding([3,4]);

%% Search attractor
[dynamics] = SearchAttractors(X,V,D,R,L);

dyn = 1;

dist_a = vecnorm(dynamics{dyn,7}-dynamics{dyn,4},2,2);
dist_a = -dist_a + max(dist_a);
weights = zeros(M,1);
% weights(dynamics{dyn,6}) = dist_a;
weights(dynamics{dyn,6}) = 1;

% r_kernel  = lyapunov_directed('sigma', 10., 'v_field', V, 'angle', pi);
r_kernel  = rbf('sigma', 4.);

psi = kernel_expansion('kernel', r_kernel, ...
                       'reference', X, ...
                       'weights', weights);

ops_psi = struct( ...
    'plot_data', true, ...
    'plot_stream', true, ...
    'colors', colors ...
    );
fig1 = psi.plot(ops_psi);
fig2 = psi.contour(ops_psi);

%%
% sigma_gp = 3.5;
% noise_std = 0.2;
% signal_std = 6.2;
% 
% mygp = gaussian_process('kernel', rbf('sigma', sigma, 'sigma_n', noise_std, 'sigma_f', signal_std), ...
%                         'target', weights, ...
%                         'reference', X);
% % mygp.optimize({'sigma', 'sigma_f', 'sigma_n'});
% mygp.plot(ops_psi)
% mygp.contour(ops_psi)