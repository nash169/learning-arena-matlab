clear; close all; clc;

%% Second order dynamics
dim = 2;
theta = 1; phi = 0.5;

omega_0 = sqrt(theta);
phi_c = 2*sqrt(theta);
csi = phi/phi_c;

A = zeros(dim);
B = eye(dim);
C = theta*eye(dim);
D = phi*eye(dim);

A_full = [A,B;-C,-D];
x_a = [0, 0, 0, 0];

myds = linear_system('a_matrix', A_full, 'attractor', x_a);

%% Analysis of the eigen-values
lambda_1 = (-csi + 1i*sqrt(1-csi^2))*omega_0;
lambda_2 = (-csi - 1i*sqrt(1-csi^2))*omega_0;

[U, D] = eig(A);

%% Sample DS
scale = 10;
x0 = 2*scale*rand(1,2*dim) - scale; % position, velocity of the ds
T = 10;
dt = 0.01;
X = myds.sample(x0,T,dt);

%% Phase diagram
res = 50;
myds.set_data(res, -20, 20, -20, 20, -20, 20, -20, 20);
V = myds.vector_field;

%% Plot
t = 0:dt:T;
grid = myds.grid;
V_cell = cell(2*dim,1);
for i = 1 : 2*dim
   V_cell{i} = reshape(V(:,i),res,res,res,[]); 
end

% Response
figure (1)
subplot(4,1,1)
plot(t, X(:,1))
title('Position x1 response');
subplot(4,1,2)
plot(t, X(:,2))
title('Position x2 response');
subplot(4,1,3)
plot(t, X(:,3))
title('Velocity v1 response');
subplot(4,1,4)
plot(t, X(:,4))
title('Velocity v2 response');

% Vector field
figure (2)
subplot(3,2,1)
streamslice(grid{1}(:,:,1,1), grid{2}(:,:,1,1), V_cell{1}(:,:,1,1), V_cell{2}(:,:,1,1))
title('x1-x2 field');
subplot(3,2,2)
streamslice(grid{1}(:,:,1,1), grid{2}(:,:,1,1), V_cell{3}(:,:,1,1), V_cell{4}(:,:,1,1))
title('x1-x2 field');
subplot(3,2,3)
streamslice(grid{1}(:,:,1,1), grid{3}(:,:,1,1), V_cell{1}(:,:,1,1), V_cell{3}(:,:,1,1))
title('x1-x2 field');
subplot(3,2,4)
streamslice(grid{1}(:,:,1,1), grid{2}(:,:,1,1), V_cell{2}(:,:,1,1), V_cell{4}(:,:,1,1))
title('x1-x2 field');
subplot(3,2,5)
streamslice(grid{1}(:,:,1,1), grid{2}(:,:,1,1), V_cell{1}(:,:,1,1), V_cell{4}(:,:,1,1))
title('x1-x2 field');
subplot(3,2,6)
streamslice(grid{1}(:,:,1,1), grid{2}(:,:,1,1), V_cell{2}(:,:,1,1), V_cell{3}(:,:,1,1))
title('x1-x2 field');

% Trajectory
figure (3)
plot(X(:,1),X(:,2));
