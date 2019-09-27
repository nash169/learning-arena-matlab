function reset(obj)
% Reset bools
obj.is_kernel_ = false;
obj.is_gradient_ = false;
obj.is_hessian_ = false;
obj.is_gramian_ = false;
obj.dp_ = struct;
end
