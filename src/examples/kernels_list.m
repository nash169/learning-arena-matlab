clear; close all; clc;

% Data
res = 200;
x_train = [25., 50.; 50, 50; 75, 50];
v_field = [10,10; 0, 10; 10, 0];
weights = [0; 1; 0];

% Kernels' parameters
U = gs_orthogonalize([1,1]);
D1 = [1/5^2;1/4^2].*eye(2);
% D1 = [3^2;2^2].*eye(2);
D2 = [1/2^2;1/3^2].*eye(2);
D3 = [1/5^2;1/4^2].*eye(2);
S1 = U'*D1*U;
S2 = U'*D2*U;
S3 = U'*D3*U;

sigma_iso = 5.;
sigma_isod = [2; 3; 4];
sigma_diag = [2;3];
sigma_diagd = [2;3;4;3;2;5];
sigma_full = S1;
sigma_fulld = [S1; S2; S3];

% Options of the expansion plot
ops_exps = struct( ...
    'grid', [0 100; 0 100], ...
    'res', res, ...
    'plot_data', false, ...
    'plot_stream', true ...
    );
psi = kernel_expansion('reference', x_train, 'weights', weights);
psi.set_data(res, 0, 100, 0, 100);

%% RBF isotropic
myrbf = rbf;
myrbf.set_params('sigma', sigma_iso, 'sigma_f', 1., 'sigma_n', 0.); % , 'sigma_inv', sigma_full, 'compact', 0.05
psi.set_params('kernel', myrbf);
psi.plot;
psi.contour(ops_exps);

%% Velocity oriented RBF
myrbfvel = velocity_oriented('v_field', v_field);
psi.set_params('kernel', myrbfvel);
psi.plot;
psi.contour(ops_exps);

%% Cosine kernel
mycosine = cosine;
psi.set_params('kernel', mycosine);
psi.plot;
psi.contour;

%% Lyapunov kernel RBF
myrbflyap = lyapunov('kernel', myrbfvel, 'v_field', v_field);
psi.set_params('kernel', myrbflyap);
psi.plot;
psi.contour(ops_exps);