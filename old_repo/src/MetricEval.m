function [AttractErr,LyapErr, LyapErr_quad] = MetricEval(xs, ys, alpha, dynamics, param)
%METRICEVAL Summary of this function goes here
%   Detailed explanation goes here

[Xs, Ys] = meshgrid(xs,ys);
x = [Xs(:),Ys(:)];

x_train = dynamics{1};
v_train = dynamics{2}; % v_train = v_train./vecnorm(v_train+1e-3,2,2);
psi = dynamics{4};
phi = dynamics{5};
x_a = dynamics{6};

par_attr.sigma = param.sigma_attract;
[k, dk] = Kernels2('gauss', param);
k_a = Kernels2('gauss', par_attr);

% Attractor Error
traj_length = 0;
for i = 1:size(x_train,1)
   traj_length = traj_length + norm(x_train(i,:) - x_train(i+1,:));
   if norm(v_train(i+1,:)) == 0
       break;
   end
end

attractors = (sum(x_train(vecnorm(v_train,2,2)==0,:))/sum(vecnorm(v_train,2,2)==0))';

N = max(sum(reshape(k(x_train,x), size(x_train,1), [])));
V = sum((1 + 0.9.*k_a(psi,x_a)).*reshape(k(x_train,x), size(x_train,1), []))'/N;
V = -V/max(V) + 1;

[row,col] = find(reshape(V,100,100)==0);
x_attr = [xs(col); ys(row)];

AttractErr = norm(attractors-x_attr)/traj_length;

% Lyapunov Error
dV = -permute(sum((1+alpha.*k_a(psi,x_a)).*reshape(dk(x_train,x_train), size(x_train,1), [], size(x_train,2))), [2 3 1]);

remove = vecnorm(v_train,2,2)==0;
x_train(remove,:) = [];
v_train(remove,:) = [];
dV(remove,:) = [];
m = size(v_train,1);
 
% LyapErr = sum( 1 + sum(dV.*v_train,2)./(vecnorm(dV,2,2).*vecnorm(v_train,2,2)) )/m;
LyapErr = 1 + sum(dV.*v_train,2)./(vecnorm(dV,2,2).*vecnorm(v_train,2,2));

dV_quad = 2*(x_train-x_attr');
% LyapErr_quad = sum( 1 + sum(dV_quad.*v_train,2)./(vecnorm(dV_quad,2,2).*vecnorm(v_train,2,2)) )/m;
LyapErr_quad = 1 + sum(dV_quad.*v_train,2)./(vecnorm(dV_quad,2,2).*vecnorm(v_train,2,2));
end
