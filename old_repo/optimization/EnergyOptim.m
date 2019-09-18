function constr_handle = EnergyOptim()
%ENERGYOPTIM Summary of this function goes here
%   Detailed explanation goes here
%% Load demos
load('1attracts_simple.mat', '-mat', 'DataStruct');
demo = DataStruct.demo;
demo_struct = DataStruct.demo_struct;
% demo = ReducedData(demo, 3); %25

%% Process data
proc_options = struct('center_data', false,...
                      'tol_cutting', 1.,...
                      'dt', 0.1...
                      );
[X, ~] = ProcessDemos(demo, 2, demo_struct, proc_options);
x_i = X(1:2,:)';
[m,~] = size(x_i);

%% Draw data
% draw_options = struct('plot_pos', true,...  % Draw the demonstrated positions
%                       'plot_vel', false...  % Draw the demonstrated velocities
%                       );
% fig_pos = DrawData(X, targets, draw_options);

% sigma0 = 10;
alpha = -ones(m,1);

% obj_handle = @(sigma) sigmaMin_obj(sigma);
constr_handle = @(sigma) sigmaMin_constr(sigma, alpha, x_i, x_i);

end

function [f, g] = sigmaMin_obj(sigma)
    f = sigma;
    g = 1;
end

function [c] = sigmaMin_constr(sigma, alpha, xtrain, xtest)

[m, d] = size(xtrain);
[n, ~] = size(xtest);

kpar.sigma = sigma;
[~, ~ , k] = Kernels('gauss', kpar);

d2eigfun = reshape(sum(reshape(repmat(alpha,n,1).*k(xtrain,xtest), m, [])), [], d^2);
M = BlkMatrix(d2eigfun);
c = -eig(full(M));

end
