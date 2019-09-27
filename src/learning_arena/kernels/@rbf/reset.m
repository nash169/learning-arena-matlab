function reset(obj)
reset@abstract_kernel(obj);
obj.is_log_k_ = false;
obj.is_log_dk_ = false;
obj.is_log_d2k_ = false;
obj.log_dp_ = struct;
end