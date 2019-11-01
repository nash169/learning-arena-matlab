num_points = 4;

A = randn(num_points);
% A = 0.5*(A+A') + eye(num_points)*num_points;

L = tril(A);

v = exp(diag(L));

L = L - diag(diag(L)) + diag(v);

A = L*L';

eig(A)

% [x,y] = meshgrid(linspace(0,100,100), linspace(0,100,100));
% x_a = [50, 50];
% X = [x(:), y(:)];
% 
% x_dot = (A*(x_a-X)')';

x_s = rand(1,4).*100. - 50.;
x_s(:,3:4) = 0.;

X = [x_s];
dt = 0.001;

for i=1:20000,
    x_s = x_s - (A * x_s')'.*dt;
    X = [X;x_s];
end

plot(X(:,1), X(:,2))
axis([-50, 50, -50, 50])

