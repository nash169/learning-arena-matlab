function ll_grad = likelihood_grad(obj, varargin)
obj.check;

gauss_grad = obj.gauss_.log_pgradient({'sigma'}, obj.params_.target');
[dK, n] = obj.h_params_.kernel.pgradient(varargin, ...
    obj.params_.reference, obj.params_.reference);

index = 1;
ll_grad = zeros(n,1);
for i = 1 : length(varargin)
    dk_temp = reshape(dK.(varargin{i}), obj.m_, obj.m_, []);
    for j = 1 : size(dk_temp,3)
        ll_grad(index) = trace(gauss_grad.sigma*dk_temp(:,:,j));
        index = index + 1;
    end
end
end

