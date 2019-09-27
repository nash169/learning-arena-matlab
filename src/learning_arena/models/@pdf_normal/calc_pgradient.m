function dp = calc_pgradient(obj, param)
dp = obj.calc_log_pgradient(param).*repelem(obj.expansion, obj.d_, 1);
end

