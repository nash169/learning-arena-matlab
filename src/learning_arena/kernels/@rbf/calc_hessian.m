function d2k = calc_hessian(obj)
    d2k = obj.calc_log_hessian .* obj.calc_kernel;
end
