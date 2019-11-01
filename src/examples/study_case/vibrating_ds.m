clear; close all; clc;

m = 1; k = 1; r = 2;

omega_0 = sqrt(k/m);
r_c = 2*sqrt(m*k);
csi = r/r_c;

lambda_1 = (-csi + 1i*sqrt(1-csi^2))*omega_0;
lambda_2 = (-csi - 1i*sqrt(1-csi^2))*omega_0;

A = [0 1; -k/m -r/m];
x_a = [50, 50];
[V, D] = eig(A);

B = [-2 0; 0, -1];
v1 = [1,1]';
v2 = [-1,1]';
U = [v1/norm(v1), v2/norm(v2)];
B = U*B*inv(U);

myds1 = linear_system('a_matrix', B, 'attractor', x_a);
myds1.plot_field;