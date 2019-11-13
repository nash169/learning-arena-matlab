clear; close all; clc;

%% Second order dynamics
theta = 1; phi = 0.5;

omega_0 = sqrt(theta);
phi_c = 2*sqrt(theta);
csi = phi/phi_c;

A = [0 1; 
    -theta -phi];
x_a = [0, 0];

myds = linear_system('a_matrix', A, 'attractor', x_a);

%% Analysis of the eigen-values
lambda_1 = (-csi + 1i*sqrt(1-csi^2))*omega_0;
lambda_2 = (-csi - 1i*sqrt(1-csi^2))*omega_0;

[V, D] = eig(A);

%% Sample DS
x0 = [3,0]; % position, velocity of the ds
T = 20;
dt = 0.01;
X = myds.sample(x0,T,dt);

%% Plot phase diagram
myds.plot_field;

%% Plot respone
plot(0:dt:T, X(:,1))