function ll = likelihood(obj)
obj.check;
ll = obj.gauss_.log_expansion(obj.params_.target');
end

