clear; close all; clc

%% Create dataset
x = (0:0.01:10)';
y = sin(x);
x_sampled = (0:0.5:10)';
y_noisy = sin(x_sampled) + rand(length(x_sampled),1) - 0.5;

%% GP model
noise_std = 0.2;
sigma = 2;
kpar = struct('sigma', sigma);           
[rbf, drbf, d2rbf] = Kernels('gauss', kpar);

gram_options = struct('norm', false,...
                      'vv_rkhs', false);
                  
K = GramMatrix(rbf, gram_options, x_sampled, x_sampled);

alphas = (K + noise_std^2*eye(size(K)))\y_noisy;

K_test = GramMatrix(rbf, gram_options, x, x_sampled);

gp_mean = K_test*alphas;
gp_var = 1 - diag(K_test*((K + noise_std^2*eye(size(K)))\K_test'));

%% Using the ML toolbox
model.X_train   = x_sampled;
model.y_train   = y_noisy;
gp_handle       = @(x_sampled)ml_gpr(x_sampled, [], model, noise_std^2, 4);
[gp_f,~,gp_s]   = gp_handle(x);


%% Plot results
plot(x, y, '--');
hold on;
scatter(x_sampled, y_noisy);
plot(x, gp_mean, 'r', x, gp_mean+3*sqrt(gp_var), '--r', x, gp_mean-3*sqrt(gp_var), '--r')
plot(x, gp_f, 'g', x, gp_f+3*sqrt(gp_s), '--g', x, gp_f-3*sqrt(gp_s), '--g')