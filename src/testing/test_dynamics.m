clear; clc

% Points
step = 3;
num_points = 9;
x = [10 25; 
     40 55; 
     70 75; 
     35 10; 
     50 40; 
     75 70;
     80 10; 
     70 35; 
     80 70];
b = num2str([1:num_points]'); c = cellstr(b);
dx = 0.5; dy = 0.5;
figure
scatter(x(:,1), x(:,2), 'filled')
text(x(:,1)+dx, x(:,2)+dy, c)
axis([0 100 0 100])
grid on
hold on

% Velocities
v = [];
for i=1:3:size(x,1)
    v = [v; (x(i+1:i+step-1,:) - x(i:i+step-2,:)) ./ vecnorm(x(i+1:i+step-1,:) - x(i:i+step-2,:),2,2); 0 0];
end

lambdas = [3,2,1,3,2,1,3,2,1];
v = lambdas'.*v;
quiver(x(:,1), x(:,2), v(:,1), v(:,2))

% Graphs
G = 0.5*eye(num_points);
G(1,2) = 1; G(2,3) = 1;
G(4,5) = 1; G(5,6) = 1;
G(7,8) = 1; G(8,9) = 1;
G(3,6) = 1; G(6,9) = 1; G(3,9) = 1;
G = G+G';
h = figure;
scatter(x(:,1), x(:,2), 'filled')
axis([0 100 0 100])
grid on
GraphDraw(x,G,h);

% Kernel
length = 20.;
myrbf = rbf;
myrbf.set_params('sigma', 15.);
K = myrbf.gramian(x,x);
myrbf.plot_gram;

% Diffusion maps
alpha = 0;
epsilon = 2*length^2;
S = K.*G;
D = diag(sum(S,2));
S_alpha  = D^-alpha*S*D^-alpha;
D_alpha = diag(sum(S_alpha,2));
M_alpha = D_alpha\S_alpha;
L_alpha = (eye(size(M_alpha)) - M_alpha); %/epsilon;
L = eye(size(S)) - D\S;

[V,D,W] = eig(L);
[a, b] = sort(diag(D),'ascend');
D = diag(a);
V = V(:,b);
W = W(:,b);

x_a = ([V(3,2), V(3,3)] + [V(6,2), V(6,3)] + [V(9,2), V(9,3)])/3;
figure
plot(1:num_points, diag(D), '-o')
figure
scatter(V(:,2), V(:,3), 'filled')
hold on
scatter(x_a(:,1), x_a(:,2), 'filled', 'r')
dx = 0.005; dy = 0.005;
text(V(:,2)+dx, V(:,3)+dy, c)

% Buil GP
y = vecnorm(x-x_a, 2, 2);
myrbf.set_params('sigma_n', 0.2, 'sigma_f', 1);
mygp = gaussian_process('kernel', myrbf, 'targets', y);
mygp.set_data(x);
mygp.set_grid(100, 0, 100, 0, 100);

ops_exps = struct( ...
    'grid', [0 100; 0 100], ...
    'res', 100, ...
    'plot_data', true, ...
    'plot_stream', true ...
    );
mygp.plot;
g = mygp.contour(ops_exps);
hold on
scatter(x(:,1), x(:,2), 'filled', 'r', 'LineWidth', 0.75)
