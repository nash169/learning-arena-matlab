function dp = calc_pgradient(obj, name)
    assert(strcmp(name, 'sigma'), 'Parameter not found')

    if obj.type_cov_ == 1
        dp = obj.calc_log_pgradient .* obj.calc_kernel;
    else
        dp = obj.calc_log_pgradient .* repelem(obj.calc_kernel, obj.d_, 1);
    end

end
