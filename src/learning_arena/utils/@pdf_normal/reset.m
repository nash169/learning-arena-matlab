function reset(obj)
    reset@kernel_expansion(obj);
    obj.is_log_psi_ = false;
    obj.is_log_dp_ = false;
    obj.log_dp_ = struct;
end
