function set_weights(obj)
% Set the weights of the gaussian process based on the training
% points and the target besides the kernel's parameters
L = chol(obj.h_params_.kernel.gramian(obj.params_.reference, obj.params_.reference),'lower');
obj.h_params_.weights = L'\(L\obj.params_.target);
% obj.h_params_.weights = obj.h_params_.kernel.gramian(obj.params_.reference, obj.params_.reference)\obj.params_.target;
obj.is_input_ = false;
obj.is_weights_ = true;
end
