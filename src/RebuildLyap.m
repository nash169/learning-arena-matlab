function [V, dV] = RebuildLyap(x, alpha, dynamics, param)
%REBUILD_LYAP Summary of this function goes here
%   Detailed explanation goes here

par_attr.sigma = param.sigma_attract;
        
% [k, dk] = Kernels2('gauss_anisotr_lyap', param);
% [k, dk] = Kernels2('gauss_anisotr_vel', param);
% [k, dk] = Kernels2('gauss_lyapunov', param);
[k, dk] = Kernels2('gauss', param);
[k_a, dk_a] = Kernels2('gauss', par_attr);

% [dynamics] = RegularizeData(dynamics);

x_train = dynamics{1};
v_train = dynamics{2}; v_train = v_train./vecnorm(v_train+1e-3,2,2);
psi = dynamics{4};
phi = dynamics{5};
x_a = dynamics{6};

N = max(sum(reshape(k(x_train,x), size(x_train,1), [])));

V = sum((1 + 0.9.*k_a(psi,x_a)).*reshape(k(x_train,x), size(x_train,1), []))'/N;

V = -V/max(V) + 1;

% V_quad = k_a(psi,x_a);
% V_quad = -V_quad/max(V_quad) + 1;

index = k_a(psi,x_a)>0.1;
figure
scatter(x_train(index,1),x_train(index,2))

if nargout > 1
    dV = permute(sum((1+alpha.*k_a(psi,x_a)).*reshape(dk(x_train,x), size(x_train,1), [], size(x_train,2))), [2 3 1]);
%     dV_quad = dk_a(psi,x_a);
end

end
