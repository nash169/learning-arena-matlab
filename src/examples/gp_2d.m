clear; close all; clc;
[X,Y] = meshgrid(-10:.1:10);
Z = Y.*sin(X) - X.*cos(Y);

surf(X,Y,Z,'FaceAlpha',0.5)
hold on;

num_points = 20;

X_sampled = 20*rand(num_points) - 10;
Y_sampled = 20*rand(num_points) - 10;
Z_noisy = Y_sampled.*sin(X_sampled) - X_sampled.*cos(Y_sampled) + rand(num_points) - 0.5;

scatter3(X_sampled(:),Y_sampled(:),Z_noisy(:), 'filled')

sigma = 3.5;
noise_std = 0.2;
signal_std = 6.2;
myrbf = rbf('sigma', sigma, 'sigma_n', noise_std, 'sigma_f', signal_std);

mygp = gaussian_process('kernel', myrbf, 'targets', Z_noisy(:));
mygp.set_data([X_sampled(:),Y_sampled(:)]);
mygp.set_grid(201, -10, 10, -10, 10);

tic;
x = mygp.optimize('sigma', 'sigma_n','sigma_f');
toc;

mygp.plot;

%% Matlab comparison
sigma0 = 0.2;
kparams0 = [3.5, 6.2];
tic;
gprMdl = fitrgp([X_sampled(:),Y_sampled(:)],Z_noisy(:),'KernelFunction','squaredexponential',...
     'FitMethod','exact','KernelParameters',kparams0,'Sigma',sigma0);
toc;
 
zpred = predict(gprMdl, [X(:),Y(:)]);
figure
surf(X, Y, reshape(zpred,201,[]));

data = [X_sampled(:),Y_sampled(:),Z_noisy(:)];
save('data2d_gp.dat', 'data', '-ascii')