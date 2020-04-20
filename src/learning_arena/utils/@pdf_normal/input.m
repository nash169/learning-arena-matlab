function input(obj)
    input@kernel_expansion(obj);

    if ~obj.is_gauss_; obj.set_gauss; end
end
