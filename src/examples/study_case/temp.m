clear; close all; clc;

X = [25,50;
     25,50];
 
V = [1,0;
     -1,0];
 
scatter(X(:,1), X(:,2), 'r', 'filled')
hold on
quiver(X(:,1), X(:,2), V(:,1), V(:,2))
 
sigma = 5.;
my_kernel = velocity_directed('sigma', sigma, 'v_field', {V,V}, 'weight', 0.7);
my_kernel.kernel(X,X)

%%
% load 2as_3t.mat
% 
% dim = 2;
% preprocess_options = struct('center_data', false,...
%                             'calc_vel', true, ...
%                             'tol_cutting', 1e-4, ... % 0.01
%                             'smooth_window', 25 ...
%                         );
%                         
% [X, ~, ~, T, ~] = ProcessDemos(demo, demo_struct, dim, preprocess_options);
% x = X(1:dim, :)';
% v = X(dim+1:2*dim, :)';
% t = X(end-2,:)';
% dt = X(end-1,:)';
% l = X(end,:)';
% 
% [max_d, index] = max(vecnorm(v,2,2).*dt);
% scale = 1;
% sigma = scale*max_d;
% 
% draw_options = struct('plot_pos', true, ...
%                       'plot_vel', false ...
%                       );
%                   
% DrawData(X, T, draw_options);
% hold on;
% scatter(x(index,1), x(index,2), 'b', 'filled')
% scatter(x(index+1,1), x(index+1,2), 'y', 'filled')
% 
% myrbf = rbf('sigma', sigma);
% mycosine = cosine;
% mycosine.set_data(v,v);
% mycosine.plot_gramian;
% 
% myvel = velocity_directed('sigma', sigma, 'v_field', {v,v});
% myvel.set_data(x,x);