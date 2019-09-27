function d2k = calc_hessian(obj)
d2k = obj.calc_log_hessian.*repelem(obj.calc_kernel, obj.d_,1);
end
