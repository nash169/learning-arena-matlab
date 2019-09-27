function k_sum = sum_kernels(obj, v)
% Reshape the eigefunction in mxnxd tensor
k_sum = permute(sum(reshape(repmat(obj.h_params_.weights, obj.n_,1).*v, obj.m_, obj.n_, []),1), [2 3 1]);
end
