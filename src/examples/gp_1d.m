clear; close all; clc

x_test = linspace(-20,20,1000)';
y_real = sin(x_test);
 
x_train = (-10:0.5:10)';
a = -1; b = 1;
y_noisy = sin(x_train) + a + (b-a).*rand(length(x_train),1);

h = figure;
plot(x_test, y_real,'--r')
hold on
scatter(x_train, y_noisy, 'filled')

length = 3.5;
noise_std = 0.2;
signal_std = 6.2;
myrbf = rbf('sigma', length, 'sigma_n', noise_std, 'sigma_f', signal_std);

mygp = gaussian_process('kernel', myrbf, 'targets', y_noisy);
mygp.set_data(x_train);
mygp.set_grid(1000, -20, 20);

options = struct;
mygp.plot(options, h, 'b');
mygp.likelihood
mygp.likelihood_grad('sigma', 'sigma_f', 'sigma_n')

tic;
x = mygp.optimize('sigma', 'sigma_n','sigma_f');
toc;
mygp.plot(options, h, 'g');

%% Matlab comparison
sigma0 = 0.2;
kparams0 = [3.5, 6.2];
tic;
gprMdl = fitrgp(x_train,y_noisy,'KernelFunction','squaredexponential',...
     'FitMethod','exact','KernelParameters',kparams0,'Sigma',sigma0);
toc;
 
ypred = predict(gprMdl, x_test);
plot(x_test, ypred, 'k');