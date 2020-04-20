function dk = calc_gradient(obj)
    dk = obj.calc_log_gradient .* obj.calc_kernel;
end
