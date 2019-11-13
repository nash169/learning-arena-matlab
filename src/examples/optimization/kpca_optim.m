clear; close all; clc;

%% Load demos
load 2as_3t.mat;

%% Process data
preprocess_options = struct('center_data', false,...
                            'calc_vel', true, ...
                            'tol_cutting', 0.01, ...
                            'smooth_window', 25 ...
                            );
[data, ~, ~, targets, ~] = ProcessDemos(demo, demo_struct, 2, preprocess_options);
X = data(1:2,:)';
labels = data(end,:)';
colors = hsv(length(unique(labels)));
colors = colors(labels,:);

%% Set optimization
% Number of components to extract
num_comp = 3;
alphas = zeros(size(X,1), num_comp);
% Create kernel
myrbf = rbf;
% Get Gramian
K = myrbf.gramian(X,X);
% Set functional
f = @(x) quadratic(x,K);
fun = @(x) combine_objectives(x, f);
% Set unitarian ball constraint
c1 = @(x) lp_ball(x,2);
c2 = @(x) orthogonal(x, alphas);
nonlcon = @(x) combine_objectives(x, c1, c2);
% Set initial state
alpha0 = rand(size(X,1),1);
% Optimization options
options = optimoptions('fmincon',...
                       'SpecifyObjectiveGradient',true,...
                       'SpecifyConstraintGradient',true);

%% Extract first principal component
for i = 1 : num_comp
    alphas(:,i) = fmincon(fun,x0,[],[],[],[],[],[],nonlcon, options);
    c2 = @(x) orthogonal(x, alphas);
    nonlcon = @(x) combine_objectives(x, c1, c2);
end

%% Plot eigenfunctions
psi = kernel_expansion('kernel', myrbf, 'reference', X);

% First components
for i = 1 : num_comp
    psi.set_params('weights', alphas(:,i));
    psi.plot; psi.contour;
end