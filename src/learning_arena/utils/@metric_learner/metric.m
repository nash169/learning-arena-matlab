function [h, h_inv] = metric(obj)
    obj.check;

    if ~obj.is_metric_
        s = length(obj.params_.space);

        f = obj.params_.manifold.embedding(obj.params_.space);
        f_i = repmat(f, 1, s);
        f_j = repelem(f, 1, s);

        L = obj.laplace_.infinitesimal;

        h_inv = (L * (f_i .* f_j) - f_i .* (L * f_j) - f_j .* (L * f_i)) / 2;
        h_inv = c_reshape(h_inv, [], s);

        obj.metric_invert(h_inv);

        obj.is_metric_ = true;
    end

    if nargout > 0; h = obj.metric_; end
    if nargout > 1; h_inv = obj.metric_inv_; end
end
