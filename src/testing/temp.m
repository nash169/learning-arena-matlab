clear; clc; close all;

X = [25,50; 30, 50; 35,40; 40,30; 50,30; 60,30];
V = [1,0;0,1;0,1;0,1;0,1;0,1];
W = [1,1,1,1,1,1]';

myrbf = rbf('sigma', 5);
mylyap = lyapunov('kernel', myrbf, 'v_field', V, 'sym_weight', 1, 'asym_weight', 0.5, 'isnan', 1, 'normalize', true);
mydir_lyap = lyapunov_directed('sigma', 5., 'v_field', V, 'angle', pi/2);
mydir_vel = velocity_directed('sigma', 5., 'v_field', {V,V}, 'angle', pi/2);
mypol = polynomial('degree',2);

psi = kernel_expansion('kernel', mypol, 'reference', X, 'weights', W);

psi.plot

psi.contour
hold on
scatter(X(:,1),X(:,2), 'r', 'filled')
quiver(X(:,1),X(:,2),V(:,1),V(:,2), 'r')

% Directed Lyapunov
sigma = 1;
theta_ref = pi/2;
alpha = 2/(1-cos(theta_ref));
theta = 0:0.01:2*pi;

x = @(theta) cos(theta);
f = @(x) (1-x)*1.5*sigma;
g = @(f) alpha*f;

figure
plot(theta, x(theta))
hold on
plot(theta, f(x(theta)))
plot(theta, g(f(x(theta))))

scatter(theta_ref, g(f(x(theta_ref))), 'r', 'filled')

G = graph_build(X, 'type', 'eps-neighborhoods', 'r', -0.6, 'fun', @(x,y) -mydir_lyap.kernel(x,y));
dm = diffusion_maps('kernel', myrbf, 'alpha', 1, 'epsilon', 2*sigma^2, 'operator', 'transport');
dm.set_data(X);
dm.set_graph(G);

% %% Create position dataset
% step = 3;
% num_points = 9;
% x = [10 25; 
%      40 55; 
%      70 75; 
%      35 10; 
%      50 40; 
%      75 70;
%      80 10; 
%      70 35; 
%      80 70];
% 
% theta = pi;
% trasl = [90,-50];
% R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
% xr = (R*(x-mean(x))')' + mean(x) + trasl;
% X = [x;xr];
% labels = [ones(size(x,1),1); 2*ones(size(xr,1),1)];
% colors = hsv(length(unique(labels)));
% colors = colors(labels,:);
% 
% %% Create graph
% G = 0.5*eye(num_points);
% G(1,2) = 1; G(2,3) = 1;
% G(4,5) = 1; G(5,6) = 1;
% G(7,8) = 1; G(8,9) = 1;
% G(3,6) = 1; G(6,9) = 1; G(3,9) = 1;
% G = G+G';
% G = blkdiag(G,G);
% 
% %% Randomize data
% % idx = randperm(size(X,1));
% % X = X(idx, :);
% % labels = labels(idx);
% % G = G(idx,idx);
% 
% %% Create kernel
% sigma = 15.;
% myrbf = rbf('sigma', sigma);
% 
% dm = diffusion_maps('kernel', myrbf, 'alpha', 1, 'epsilon', 2*sigma^2, 'operator', 'transport');
% dm.set_data(X);
% dm.set_graph(G);
% 
% dm.plot_spectrum;
