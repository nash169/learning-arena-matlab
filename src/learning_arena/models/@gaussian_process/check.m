function check(obj)
check@kernel_expansion(obj);
if ~obj.is_weights_; obj.set_weights; end
if ~obj.is_gauss_; obj.set_gauss; end
end

